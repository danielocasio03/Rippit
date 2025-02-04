import Foundation
import Combine
import Messages

class EmoticonsFetchManager {
	
	// Fetch Error Handler
	enum EmoticonsFetchErrors: Error {
		case failedToCreateURL(for: String)
		case failedToFetchEmoticons(error: Error)
		case failedToDownloadSticker
	}
	
	// MARK: - Fetch Methods
	
	func fetchEmoticons(category: String, searchTerm: String?, pageToLoad: Int) -> AnyPublisher<[Emoticon], EmoticonsFetchErrors> {
		
		// Determine the URL based on category
		let urlString: String
		if category == "popular" {
			urlString = "https://api.frankerfacez.com/v1/emoticons?page=\(pageToLoad)&sort=count-desc#"
		} else if category == "new" {
			urlString = "https://api.frankerfacez.com/v1/emoticons?page=\(pageToLoad)&sort=created-desc#"
		} else {
			urlString = "https://api.frankerfacez.com/v1/emoticons?q=\(searchTerm ?? "")&page=\(pageToLoad)"
		}
		
		// Ensure URL is valid
		guard let url = URL(string: urlString) else {
			return Fail(error: EmoticonsFetchErrors.failedToCreateURL(for: urlString))
				.eraseToAnyPublisher()
		}
		
		return URLSession.shared.dataTaskPublisher(for: url)
			.subscribe(on: DispatchQueue.global(qos: .userInitiated))
			.map(\.data)
			.decode(type: EmoticonsResponse.self, decoder: JSONDecoder())
			.mapError { EmoticonsFetchErrors.failedToFetchEmoticons(error: $0) }
			.flatMap { response in
				self.downloadAllStickers(for: response.emoticons)
			}
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}
	
	// MARK: - Private Helper Methods
	
	private func downloadAllStickers(for emoticons: [Emoticon]) -> AnyPublisher<[Emoticon], Never> {
		//Downloading the sticker for each emoticon that was fetched
		let publishers = emoticons.map { emoticon in
			self.downloadSticker(for: emoticon)
		}
		
		//Returning all the emoticons with the now added stickers
		return Publishers.MergeMany(publishers)
			.collect()
			.eraseToAnyPublisher()
	}
	
	
	// Determines the best URL to download as an `MSSticker` (animated or static) based on availability.
	private func downloadSticker(for emoticon: Emoticon) -> AnyPublisher<Emoticon, Never> {
		var urlString: String
		var fileType: String
		let emoticonCopy = emoticon  // Create a copy to modify properties
		
		// Check for animated URLs
		if let animatedUrl = emoticon.animated?.animatedurl3 ?? emoticon.animated?.animatedurl2 ?? emoticon.animated?.animatedurl1 {
			urlString = animatedUrl
			fileType = "gif"  // Animated URL should be a gif file
		} else {
			// Default to static URLs if animated isn't available
			urlString = emoticon.urls.url4 ?? emoticon.urls.url2 ?? emoticon.urls.url1
			fileType = "png"  // Static URL should be a png file
		}
		
		guard let url = URL(string: urlString) else {
			return Just(emoticonCopy).eraseToAnyPublisher()
		}
		
		// Downloading/creating sticker then returning emoticon with sticker
		return createSticker(url: url, id: emoticon.id, fileType: fileType) // Download/Create sticker
			.map { sticker in
				var updatedEmoticon = emoticonCopy
				updatedEmoticon.sticker = sticker
				return updatedEmoticon // returning emoticon with sticker
			}
			.eraseToAnyPublisher()
	}
	
	// Download the image as an `MSSticker`.
	private func createSticker(url: URL, id: Int, fileType: String) -> AnyPublisher<MSSticker?, Never> {
		//Cache management
		let fileManager = FileManager.default
		let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
		let tempURL = cacheDirectory.appendingPathComponent("\(id).\(fileType)")
		
		//Download and cache sticker, then return
		return URLSession.shared.dataTaskPublisher(for: url)
			.compactMap { data, _ -> MSSticker? in
				do {
					if !fileManager.fileExists(atPath: tempURL.path) {
						try data.write(to: tempURL)
					}
					let sticker = try MSSticker(contentsOfFileURL: tempURL, localizedDescription: "Emote Sticker")
					return sticker
				} catch {
					print("Error creating sticker: \(error.localizedDescription)")
					return nil
				}
			}
		
			.replaceError(with: nil)
			.eraseToAnyPublisher()
	}
	
}
