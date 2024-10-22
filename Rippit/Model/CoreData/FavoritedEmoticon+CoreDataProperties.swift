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


extension FavoritedEmoticon {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoritedEmoticon> {
        return NSFetchRequest<FavoritedEmoticon>(entityName: "FavoritedEmoticon")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var imageData: Data?

	// Computed property to convert imageData back to UIImage
	public var image: UIImage? {
		guard let imageData = imageData else { return nil }
		return UIImage(data: imageData)
	}
	
}

extension FavoritedEmoticon : Identifiable {

}
