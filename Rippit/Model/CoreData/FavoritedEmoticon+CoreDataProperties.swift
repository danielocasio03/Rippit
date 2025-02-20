//
//  FavoritedEmoticon+CoreDataProperties.swift
//  Rippit
//
//  Created by Daniel Efrain Ocasio on 10/22/24.
//
//

import Foundation
import CoreData
import UIKit
import Messages


extension FavoritedEmoticon {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoritedEmoticon> {
        return NSFetchRequest<FavoritedEmoticon>(entityName: "FavoritedEmoticon")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String
    @NSManaged public var imageData: Data?
	@NSManaged public var isAnimated: Bool

	// Computed property to convert imageData back to MSSticker
	public var sticker: MSSticker? {
		guard let imageData = imageData else { return nil }
		
		// Create a temporary URL to hold the image data
		let tempDirectoryURL = FileManager.default.temporaryDirectory
		let fileURL = tempDirectoryURL.appendingPathComponent("\(UUID().uuidString).gif")
		
		do {
			// Write image data to a temporary file
			try imageData.write(to: fileURL)
			
			// Create and return an MSSticker from the temporary file
			let sticker = try MSSticker(contentsOfFileURL: fileURL, localizedDescription: "Emoticon Sticker")
			return sticker
		} catch {
			print("Error creating MSSticker from image data: \(error.localizedDescription)")
			return nil
		}
	}
	
}

extension FavoritedEmoticon : Identifiable {

}
