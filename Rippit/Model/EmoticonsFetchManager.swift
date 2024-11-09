////
////  EmoticonsFetchManager.swift
////  Rippit
////
////  Created by Daniel Efrain Ocasio on 10/9/24.
////
//import Foundation
//import Combine
//import UIKit
//import ImageIO
//
//class EmoticonsFetchManager {
//	
//	// Fetch Error Handler
//	enum EmoticonsFetchErrors: Error {
//		case failedToCreateURL(for: String)
//		case failedToFetchEmoticons(error: Error)
//		case failedToDownloadImage
//	}
//	
//	// MARK: - Fetch Methods
//	
//	func fetchEmoticons(category: String, searchTerm: String?, pageToLoad: Int) -> AnyPublisher<[Emoticon], EmoticonsFetchErrors> {
//		
//		// Determine the URL based on category
//		let urlString: String
//		if category == "popular" {
//			urlString = "https://api.frankerfacez.com/v1/emoticons?page=\(pageToLoad)&sort=count-desc#"
//		} else if category == "new" {
//			urlString = "https://api.frankerfacez.com/v1/emoticons?page=\(pageToLoad)&sort=created-desc#"
//		} else {
//			urlString = "https://api.frankerfacez.com/v1/emoticons?q=\(searchTerm ?? "")&page=\(pageToLoad)"
//		}
//		
//		// Ensure URL is valid
//		guard let url = URL(string: urlString) else {
//			return Fail(error: EmoticonsFetchErrors.failedToCreateURL(for: urlString))
//				.eraseToAnyPublisher()
//		}
//		
//		return URLSession.shared.dataTaskPublisher(for: url)
//			.subscribe(on: DispatchQueue.global(qos: .userInitiated)) // Ensuring we perform network,  decoding, and download on background thread
//			.map(\.data)
//			.decode(type: EmoticonsResponse.self, decoder: JSONDecoder())
//			.mapError { EmoticonsFetchErrors.failedToFetchEmoticons(error: $0) }
//			.flatMap { response in
//				self.downloadAllImages(for: response.emoticons) //Calling the method that downloads images for each Emoticon object. Returning the images to each Emoticon
//			}
//			.receive(on: DispatchQueue.main)
//			.eraseToAnyPublisher()
//	}
//	
//	
//	// MARK: - Private Helper Methods
//	
//	
//	// helper method that takes emoticons and begins downloading images for each, handling both static and animated options.
//	private func downloadAllImages(for emoticons: [Emoticon]) -> AnyPublisher<[Emoticon], Never> {
//		let publishers = emoticons.map { emoticon in
//			self.downloadImage(for: emoticon) //Calling method to download image for each Emoticon object passed in
//				.map { image in
//					var emoticonWithImage = emoticon
//					emoticonWithImage.image = image
//					return emoticonWithImage //Returning the Emoticon now with the image downlaodede
//				}
//				.eraseToAnyPublisher()
//		}
//		
//		return Publishers.MergeMany(publishers)
//			.collect()
//			.eraseToAnyPublisher()
//	}
//	
//	
//	// This method determines the best URL to download (animated, high-res, low-res etc.) based on what’s available for each Emoticon. and handles thw download accordingly
//	private func downloadImage(for emoticon: Emoticon) -> AnyPublisher<UIImage?, Never> {
//		// Priority order for URLs
//		let urlString = emoticon.animated?.animatedurl3 ??
//		emoticon.animated?.animatedurl2 ??
//		emoticon.animated?.animatedurl1 ??
//		emoticon.urls.url4 ??
//		emoticon.urls.url2 ??
//		emoticon.urls.url1
//		
//		guard let url = URL(string: urlString) else {
//			return Just(nil).eraseToAnyPublisher()
//		}
//		
//		// Check if the URL is animated; if so, handle as an animated image using the respective method
//		if urlString.contains("animated") {
//			return downloadAnimatedImage(from: url)
//		} else {
//			return downloadStaticImage(from: url)
//		}
//	}
//	
//	
//	// Download static image
//	private func downloadStaticImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
//		return URLSession.shared.dataTaskPublisher(for: url)
//			.map { data, _ in UIImage(data: data) }
//			.replaceError(with: nil)
//			.eraseToAnyPublisher()
//	}
//	
//	// Download animated image and create an array of frames
//	private func downloadAnimatedImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
//		return URLSession.shared.dataTaskPublisher(for: url)
//			.compactMap { data, _ -> UIImage? in
//				self.createAnimatedImage(from: data)
//			}
//			.replaceError(with: nil)
//			.eraseToAnyPublisher()
//	}
//	
//	// Create an animated UIImage from data (GIF or WebP)
//	private func createAnimatedImage(from data: Data) -> UIImage? {
//		guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
//			print("Failed to create image source")
//			return nil
//		}
//		
//		let frameCount = CGImageSourceGetCount(imageSource)
//		var frames: [UIImage] = []
//		var totalDuration: TimeInterval = 0.0
//		
//		//For loop that for each frame found in imageSource calculared the duration for the frame and appends to the total frams
//		for index in 0..<frameCount {
//			guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, index, nil) else {
//				continue
//			}
//			
//			let frameDuration = getFrameDuration(from: imageSource, at: index) // Calling the method that calculates the frame duration
//			totalDuration += frameDuration
//			
//			let frame = UIImage(cgImage: cgImage)
//			frames.append(frame)
//		}
//		
//		//returns animated image with the calculated image frames and duration for eacdh frame
//		let animatedImage = UIImage.animatedImage(with: frames, duration: totalDuration)
//		return animatedImage
//	}
//	
//	
//	// Get frame duration from GIF properties
//	private func getFrameDuration(from source: CGImageSource, at index: Int) -> TimeInterval {
//		var frameDuration: TimeInterval = 0.1
//		
//		guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
//			  let gifProperties = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any] else {
//			return frameDuration
//		}
//		
//		if let delay = gifProperties[kCGImagePropertyGIFUnclampedDelayTime] as? TimeInterval {
//			frameDuration = delay
//		} else if let delay = gifProperties[kCGImagePropertyGIFDelayTime] as? TimeInterval {
//			frameDuration = delay
//		}
//		
//		if frameDuration < 0.1 {
//			frameDuration = 0.1
//		}
//		
//		return frameDuration
//	}
//}

//
//  EmoticonsFetchManager.swift
//  Rippit
//
//  Created by Daniel Efrain Ocasio on 10/9/24.
//

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
		let publishers = emoticons.map { emoticon in
			self.downloadSticker(for: emoticon)
		}
		
		return Publishers.MergeMany(publishers)
			.collect()
			.eraseToAnyPublisher()
	}
	
	
	// Determines the best URL to download as an `MSSticker` (animated or static) based on availability.
	private func downloadSticker(for emoticon: Emoticon) -> AnyPublisher<Emoticon, Never> {
		var urlString: String
		var fileType: String
		var emoticonCopy = emoticon  // Create a copy to modify properties
		
		// Check for animated URLs
		if let animatedUrl = emoticon.animated?.animatedurl3 ?? emoticon.animated?.animatedurl2 ?? emoticon.animated?.animatedurl1 {
			urlString = animatedUrl
			fileType = "gif"  // Animated URL should be a gif
			emoticonCopy.isAnimated = true  // Set isAnimated to true
		} else {
			// Default to static URLs
			urlString = emoticon.urls.url4 ?? emoticon.urls.url2 ?? emoticon.urls.url1
			fileType = "png"  // Static URL should be a png
			emoticonCopy.isAnimated = false  // Set isAnimated to false
		}
		
		guard let url = URL(string: urlString) else {
			return Just(emoticonCopy).eraseToAnyPublisher()
		}
		
		return createSticker(url: url, id: emoticon.id, fileType: fileType)
			.map { sticker in
				var updatedEmoticon = emoticonCopy
				updatedEmoticon.sticker = sticker
				return updatedEmoticon
			}
			.eraseToAnyPublisher()
	}
	
	// Download the image as an `MSSticker`.
	private func createSticker(url: URL, id: Int, fileType: String) -> AnyPublisher<MSSticker?, Never> {
		let fileManager = FileManager.default
		let tempURL = fileManager.temporaryDirectory.appendingPathComponent("\(id).\(fileType)")
		
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
