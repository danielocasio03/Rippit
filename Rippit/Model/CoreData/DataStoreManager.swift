//
//  DataStoreManager.swift
//  Rippit
//
//  Created by Daniel Efrain Ocasio on 11/19/24.
//

import Foundation
import CoreData

class DataStoreManager {
	
	static let shared = DataStoreManager()
	
	private init() {}
	
	lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "Favorites")  // Model name
		
		// Get the App Group container URL
		let appGroupID = "group.DanielOcasio.Rippit"
		
		// Use `guard` to unwrap the optional URL returned by `containerURL(forSecurityApplicationGroupIdentifier:)`
		guard let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
			fatalError("App Group URL could not be found!")
		}
		
		// Using appGroupURL
		let storeURL = appGroupURL.appendingPathComponent("sharedData.sqlite")
		let description = NSPersistentStoreDescription(url: storeURL)
		
		container.persistentStoreDescriptions = [description]
		
		container.loadPersistentStores { (storeDescription, error) in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		}
		
		return container
	}()
	
	func saveContext() {
		let context = persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}
	
	func fetchData<T: NSManagedObject>(_ entity: T.Type) -> [T]? {
		let fetchRequest = NSFetchRequest<T>(entityName: String(describing: entity)) // Explicitly define the entity name
		
		do {
			let results = try persistentContainer.viewContext.fetch(fetchRequest)
			return results
		} catch {
			// Log or handle the error
			print("Failed to fetch data: \(error)")
			return nil // or return an empty array depending on needs
		}
	}
}
