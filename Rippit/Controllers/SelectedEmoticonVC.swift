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
import Messages

class SelectedEmoticonVC: UIViewController {
	
	//MARK: - Declarations
	
	var emoticonID: Int
	
	var emoticonName: String
	
	var emoticonSticker: MSSticker
	
	var isEmoticonAnimated: Bool
	
	var didUpdateEmote: (() -> Void)?
		
	//Reference to coredata persistent container
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	//sticker for the Emoticon
	lazy var emoticonStickerView: MSStickerView = {
		let sticker = MSStickerView()
		sticker.translatesAutoresizingMaskIntoConstraints = false
		sticker.contentMode = .scaleAspectFit
		sticker.sticker = emoticonSticker
		if isEmoticonAnimated {
			sticker.startAnimating()
		}
		
		return sticker
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
	
	//Button for copying the selected sticker
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
	init(id: Int, name: String, sticker: MSSticker, isAnimated: Bool) {
		
		self.emoticonID = id
		self.emoticonName = name
		self.emoticonSticker = sticker
		self.isEmoticonAnimated = isAnimated
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
		//Emoticon sticker
		view.addSubview(emoticonStickerView)


		NSLayoutConstraint.activate([
			//ContainerView
			containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.40),
			containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			//Emoticon sticker
			emoticonStickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			emoticonStickerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
			emoticonStickerView.bottomAnchor.constraint(equalTo: containerView.topAnchor),
			emoticonStickerView.widthAnchor.constraint(greaterThanOrEqualTo: view.widthAnchor, multiplier: 0.40),
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
	
	
	//Action function called when the favorites button is tapped
	@objc func copyTapped() {
		let imageFileURL = emoticonSticker.imageFileURL
		let imageToCopy: Data
		var fileType: String
		
		do {
			// Load the image data from the file URL
			let imageData = try Data(contentsOf: imageFileURL)
			guard let image = UIImage(data: imageData) else {return}
			
			if isEmoticonAnimated {
				imageToCopy = imageData
				fileType = UTType.gif.identifier
			} else {
				imageToCopy = resizeImage(image) //Resizing the image to a more suitable size for imessage
				fileType = UTType.png.identifier
			}
			
			// Copy the image data to the clipboard
			UIPasteboard.general.setData(imageToCopy, forPasteboardType: fileType)
			
			// Show an alert confirming the copy
			let alert = UIAlertController(title: "Copied!", message: "The emoticon is copied and ready to paste", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			present(alert, animated: true, completion: nil)
		} catch {
			print("Failed to load image data from sticker: \(error)")
		}
		
	}
	
	
	//MARK: - Helper Methods
	
	// Helper function to resize a static image while maintaining the aspect ratio
	func resizeImage(_ image: UIImage) -> Data {
		let maxDimension: CGFloat = 180
		
		// Get the original image's size
		let originalSize = image.size
		
		// Calculate the scaling factor to maintain aspect ratio
		let scaleFactor = min(maxDimension / originalSize.width, maxDimension / originalSize.height)
		
		// Calculate the new size maintaining the aspect ratio
		let newWidth = originalSize.width * scaleFactor
		let newHeight = originalSize.height * scaleFactor
		let newSize = CGSize(width: newWidth, height: newHeight)
		
		// Use UIGraphicsImageRenderer to resize the image
		let renderer = UIGraphicsImageRenderer(size: newSize)
		
		let resizedImage = renderer.image { (context) in
			image.draw(in: CGRect(origin: .zero, size: newSize))
		}
		
		guard let resizedImageData = resizedImage.pngData() else {
			return image.pngData()!
		}
		
		return resizedImageData
	}
	
	
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
				newFavorite.isAnimated = isEmoticonAnimated
				
				do {
					// Convert the sticker's image URL to Data
					let imageData = try Data(contentsOf: emoticonSticker.imageFileURL)
					newFavorite.imageData = imageData // Store the binary data in Core Data
					
					didUpdateEmote?()
					print("Added Emoticon to favorites")
					
				} catch {
					print("Failed to load image data for saving: \(error)")
				}
			}
		} else {
			// Remove it from favorites if it exists
			if let existingFavorite = results.first {
				context.delete(existingFavorite)
				didUpdateEmote?()
				print("Removed Emoticon from favorites")
			}
		}
		
		// Save changes
		do {
			try context.save()
		} catch {
			print("Failed to save context: \(error)")
		}
	}

	
}


