//
//  EmoticonsModel.swift
//  Rippit
//
//  Created by Daniel Efrain Ocasio on 10/9/24.
//

import Foundation
import UIKit
import Combine

struct EmoticonsModel {
	let emoticonsResponse: EmoticonsResponse
}


struct EmoticonsResponse: Codable {
	
	let pages: Int
	
	let total: Int
	
	let emoticons: [Emoticon]
	
	enum CodingKeys: String, CodingKey {
		case pages = "_pages"
		case total = "_total"
		case emoticons
	}
}

struct Emoticon: Codable {
	
	let id: Int
	
	let name: String
	
	let urls: Urls
	
	let createdAt: String
	
	let lastUpdated: String
	
	var image: UIImage? = nil

	enum CodingKeys: String, CodingKey {
		case id, name, urls
		case createdAt = "created_at"
		case lastUpdated = "last_updated"
	}
}


struct Urls: Codable {
	
	let url1: String
	
	let url2: String?
	
	let url4: String?
	
	enum CodingKeys: String, CodingKey {
		case url1 = "1"
		case url2 = "2"
		case url4 = "4"
	}
}
