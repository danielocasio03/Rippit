//
//  EmoticonsFetchManager.swift
//  Rippit
//
//  Created by Daniel Efrain Ocasio on 10/9/24.
//
import Foundation
import Combine
import UIKit


class EmoticonsFetchManager {
	
	//Fetch Error Handler
	enum EmoticonsFetchErrors: Error {
		case failedToCreateURL(for: String)
		case failedToFetchEmoticons(error: Error)
		case failedToDownloadImage
	}
	
	//MARK: - Fetch Methods
	
	//Function that fetches the database for its Emoticons data, returns array of type [Emoticon] or a fetch error in case of failure
	func fetchEmoticons(category: String, searchTerm: String?, pageToLoad: Int) -> AnyPublisher<[Emoticon], EmoticonsFetchErrors> {
		
		//checking which category the fetch is for so we know which URL to use
		let urlString: String
		if category == "popular" {
			urlString = "https://api.frankerfacez.com/v1/emoticons?page=\(pageToLoad)&sort=count-desc#"
		} else if category == "new" {
			urlString = "https://api.frankerfacez.com/v1/emoticons?page=\(pageToLoad)&sort=created-desc#"
		} else {
			urlString = "https://api.frankerfacez.com/v1/emoticons?q=\(searchTerm ?? "")&page=\(pageToLoad)"
		}
				
		//unwrapping url string to URL object
		guard let url = URL(string: urlString) else {
			return Fail(error: EmoticonsFetchErrors.failedToCreateURL(for: urlString))
				.eraseToAnyPublisher()
		}
		
		// Fetch emoticons and download their images
		return URLSession.shared.dataTaskPublisher(for: url)
			.map(\.data)
			.decode(type: EmoticonsResponse.self, decoder: JSONDecoder())
			.mapError { EmoticonsFetchErrors.failedToFetchEmoticons(error: $0) }
			.flatMap { response in
				// Download images for each emoticon
				self.downloadImages(for: response.emoticons)
			}
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}
	
	
	//MARK: - Private Helper Methods
	
	// Helper method to download images for all emoticons; returns array of Emoticons now with the image in place.
	private func downloadImages(for emoticons: [Emoticon]) -> AnyPublisher<[Emoticon], Never> {
		let publishers = emoticons.map { emoticon in
			let selectedUrl = emoticon.urls.url4 ?? emoticon.urls.url2 ?? emoticon.urls.url1
			return self.downloadSingleImage(from: selectedUrl)
				.map { image in
					var emoticonWithImage = emoticon
					emoticonWithImage.image = image
					return emoticonWithImage
				}
				.eraseToAnyPublisher()
		}
		// Merges each of the emoticon Publishers that now have images back into one Publisher; [Emoticons]
		return Publishers.MergeMany(publishers)
			.collect()
			.eraseToAnyPublisher()
	}
	
	
	// Helper method to load a single image from a URL
	private func downloadSingleImage(from urlString: String) -> AnyPublisher<UIImage?, Never> {
		guard let url = URL(string: urlString) else {
			return Just(nil).eraseToAnyPublisher()
		}
		
		return URLSession.shared.dataTaskPublisher(for: url)
			.map { data, _ in UIImage(data: data) }
			.replaceError(with: nil)
			.eraseToAnyPublisher()
	}
}
