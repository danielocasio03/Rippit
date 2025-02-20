//
//  EmoticonsModel.swift
//  Rippit
//
//  Created by Daniel Efrain Ocasio on 10/9/24.
//

import Foundation
import UIKit
import Combine
import Messages

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
	
	let id: Int32
	
	let name: String
	
	let urls: Urls
	
	let animated: animatedUrls?
	
	let createdAt: String
	
	let lastUpdated: String
	
	var sticker: MSSticker? = nil
	
	var isAnimated: Bool {
		return animated?.animatedurl1 != nil ||
		animated?.animatedurl2 != nil ||
		animated?.animatedurl3 != nil
	}

	enum CodingKeys: String, CodingKey {
		case id, name, urls, animated
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

struct animatedUrls: Codable {
	
	let animatedurl1: String?
	
	let animatedurl2: String?
	
	let animatedurl3: String?
	
	enum CodingKeys: String, CodingKey {
		case animatedurl1 = "1"
		case animatedurl2 = "2"
		case animatedurl3 = "4"
	}
	
}

