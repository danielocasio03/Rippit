//
//  SelectedEmoticonVc.swift
//  Rippit
//
//  Created by Daniel Efrain Ocasio on 10/17/24.
//

import Foundation
import UIKit
import CoreData
import ImageIO
import UniformTypeIdentifiers

class SelectedEmoticonVC: UIViewController {
	
	//MARK: - Declarations
	
	var emoticonID: Int
	
	var emoticonName: String
	
	var emoticonImage: UIImage
	
	var didUpdateEmote: (() -> Void)?
		
	//Reference to coredata persistent container
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	//Image for the Emoticon
	lazy var emoticonImageView: UIImageView = {
		let image = UIImageView()
		image.translatesAutoresizingMaskIntoConstraints = false
		image.contentMode = .scaleAspectFit
		image.image = emoticonImage

		return image
	}()
	
	
	lazy var containerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .white
		
		return view
	}()
	
	//Label for the emoticon name
	lazy var emoticonNameLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont(name: "AvenirNext-Bold", size: 20 )
		label.textColor = DesignManager.shared.navyBlueText
		label.text = "Emote Name: \(emoticonName)"
		
		return label
	}()
	
	//Button for copying the selected image
	lazy var copyButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("Copy", for: .normal)
		button.setTitleColor(DesignManager.shared.navyBlueText, for: .normal)
		button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 18)
		button.backgroundColor = DesignManager.shared.selectedBlueAccent
		button.layer.cornerRadius = 10
		button.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)
		
		return button
	}()
	
	lazy var favoriteButton: FavoriteButton = {
		
		let button = FavoriteButton(frame: .zero, color: DesignManager.shared.lightBgColor)
		button.addTarget(self, action: #selector(favoritesTapped), for: .touchUpInside)
		button.isSelected = isEmoticonFavorited()
		
		return button
	}()
	
	

	
	
	//MARK: -  Init and Override
	
	//Custom Initializer for taking in the selected Emoticons Data; then assigning injected data to our local variable
	init(id: Int, name: String, image: UIImage) {
		
		self.emoticonID = id
		self.emoticonName = name
		self.emoticonImage = image
		super.init(nibName: nil, bundle: nil)
		
	}
	
	//ViewDidLoad
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupView()
		setupContainerView()
		
	}
	
	//req init
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	//MARK: - Setup Methods
	
	//Method to setup the general view
	func setupView() {
		
		self.view.backgroundColor = DesignManager.shared.lightBgColor
		
		// Define custom detent
		let customDetent = UISheetPresentationController.Detent.custom { context in
			return context.maximumDetentValue * 0.50
		}
		//Use detents so the VC only comes up about halfway, also enabling the grabber to be shown
		self.sheetPresentationController?.detents = [customDetent]
		self.sheetPresentationController?.prefersGrabberVisible = true
		
		//ContainerView
		view.addSubview(containerView)
		//Emoticon Image
		view.addSubview(emoticonImageView)


		NSLayoutConstraint.activate([
			//ContainerView
			containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.40),
			containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			//Emoticon Image
			emoticonImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			emoticonImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
			emoticonImageView.bottomAnchor.constraint(equalTo: containerView.topAnchor),
			emoticonImageView.widthAnchor.constraint(greaterThanOrEqualTo: view.widthAnchor, multiplier: 0.40),
		])
	}
	
	//Method to setup the containerview
	func setupContainerView() {
		
		//Emoticon Label
		containerView.addSubview(emoticonNameLabel)
		//Copy Button
		containerView.addSubview(copyButton)
		//Favorite Button
		containerView.addSubview(favoriteButton)
		
		NSLayoutConstraint.activate([
			//Emoticon Label
			emoticonNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
			emoticonNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
			//Copy Button
			copyButton.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.30),
			copyButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.70),
			copyButton.topAnchor.constraint(equalTo: emoticonNameLabel.bottomAnchor, constant: 30),
			copyButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
			//Favorite Button
			favoriteButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.15),
			favoriteButton.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.30),
			favoriteButton.topAnchor.constraint(equalTo: copyButton.topAnchor),
			favoriteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
		])
		
	}
	
	
	//MARK: - Action Methods
	
	//Action function called when the favorites button is tapped
	@objc func favoritesTapped() {
		favoriteButton.isSelected.toggle()
		toggleFavoriteInCoreData(isFavorited: favoriteButton.isSelected)
	}
	
	//Action function called when the favorites button is tapped //review
	@objc func copyTapped() {
		if let animatedData = emoticonImage.toGIFData() {
			// Copy GIF data to the clipboard
			UIPasteboard.general.setData(animatedData, forPasteboardType: "com.compuserve.gif")
			
			let alert = UIAlertController(title: "Copied!", message: "The animated emoticon has been copied to your clipboard.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			present(alert, animated: true, completion: nil)
		} else {
			// Copy static image directly if not animated
			UIPasteboard.general.image = emoticonImage
			let alert = UIAlertController(title: "Copied!", message: "The emoticon has been copied to your clipboard.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			present(alert, animated: true, completion: nil)
		}
	}
	
	
	//MARK: - Helper Methods
	
	//Checks if an emoticon exists in coredata and returns true or false
	private func isEmoticonFavorited() -> Bool {
		return fetchFavoritedEmoticons().isEmpty == false
	}
	
	//Fetches Emoticon from coredata with a predicate of the selectedEmoticonsID. if the Emoticon exists in coredata it returns an array with it inside. Else it returns an empty array
	private func fetchFavoritedEmoticons() -> [FavoritedEmoticon] {
		let fetchRequest: NSFetchRequest<FavoritedEmoticon> = FavoritedEmoticon.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "id == %d", emoticonID)
		
		do {
			return try context.fetch(fetchRequest)
		} catch {
			print("Failed to fetch emoticons: \(error)")
			return []
		}
	}
	
	//handles deleting or saving an Emoticon from Coredata based on whether its already favorited/saved or not
	private func toggleFavoriteInCoreData(isFavorited: Bool) {
		let results = fetchFavoritedEmoticons()
		
		if isFavorited {
			// Save it as a favorite if it doesn't already exist
			if results.isEmpty {
				let newFavorite = FavoritedEmoticon(context: context)
				newFavorite.id = Int32(emoticonID)
				newFavorite.name = emoticonName
				newFavorite.imageData = emoticonImage.pngData()
				didUpdateEmote?()
				print("Added Emoticon to favorites")
			}
		} else {
			// Remove it from favorites if it exists
			if let existingFavorite = results.first {
				context.delete(existingFavorite)
				didUpdateEmote?()
				print("Removed Emoticon from favorites")
			}
		}
		
		// Save changes after add/remove
		do {
			try context.save()
		} catch {
			print("Failed to save context: \(error)")
		}
	}

	
}


//Review
extension UIImage {
	
	//This is an extension method to UIImage that converts imamges into animated images
	func toGIFData() -> Data? {
		guard let images = self.images, images.count > 1 else {
			return nil // Only proceed if it's an animated UIImage
		}
		
		let frameDelay = self.duration / Double(images.count)
		
		let data = NSMutableData()
		
		guard let destination = CGImageDestinationCreateWithData(data as CFMutableData, UTType.gif.identifier as CFString, images.count, nil) else {
			return nil
		}
		
		let properties = [kCGImagePropertyGIFDictionary: [
			kCGImagePropertyGIFLoopCount: 0 // Loop indefinitely
		]]
		CGImageDestinationSetProperties(destination, properties as CFDictionary)
		
		for image in images {
			guard let cgImage = image.cgImage else { continue }
			let frameProperties = [kCGImagePropertyGIFDictionary: [
				kCGImagePropertyGIFDelayTime: frameDelay
			]]
			CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
		}
		
		if CGImageDestinationFinalize(destination) {
			return data as Data
		} else {
			return nil
		}
	}
}
