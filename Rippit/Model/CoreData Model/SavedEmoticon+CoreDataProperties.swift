//
//  SavedEmoticon+CoreDataProperties.swift
//  Rippit
//
//  Created by Daniel Efrain Ocasio on 10/22/24.
//
//

import Foundation
import CoreData


extension SavedEmoticon {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedEmoticon> {
        return NSFetchRequest<SavedEmoticon>(entityName: "SavedEmoticon")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var imageData: Data?

}

extension SavedEmoticon : Identifiable {

}
