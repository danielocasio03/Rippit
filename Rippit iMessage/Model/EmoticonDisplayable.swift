//
//  EmoticonDisplayable.swift
//  Rippit iMessage
//
//  Created by Daniel Efrain Ocasio on 1/14/25.
//

import Foundation
import Messages


//Protocol grouping shared properties between displayable Emoticon objects
protocol EmoticonDisplayable {
	var id: Int32 { get }
	var sticker: MSSticker? { get }
	var isAnimated: Bool { get }
	var name: String { get }
}

extension Emoticon: EmoticonDisplayable {}
extension FavoritedEmoticon: EmoticonDisplayable {}
