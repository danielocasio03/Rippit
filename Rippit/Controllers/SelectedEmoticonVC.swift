//
//  SelectedEmoticonVc.swift
//  Rippit
//
//  Created by Daniel Efrain Ocasio on 10/17/24.
//

import Foundation
import UIKit

class SelectedEmoticonVC: UIViewController {
	
	//MARK: - Declarations
	
	var selectedEmoticon: Emoticon
	
	//Reference to coredata persistent container
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	//Image for the Emoticon
	lazy var emoticonImage: UIImageView = {
		let image = UIImageView()
		image.translatesAutoresizingMaskIntoConstraints = false
		image.contentMode = .scaleAspectFit
		image.image = selectedEmoticon.image

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
		label.text = "Emote Name: \(selectedEmoticon.name)"
		
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
		
		return button
	}()
	
	lazy var favoriteButton: FavoriteButton = {
		
		let button = FavoriteButton(frame: .zero, color: DesignManager.shared.lightBgColor)
		button.addTarget(self, action: #selector(favoritesTapped), for: .touchUpInside)
		
		return button
	}()
	
	

	
	
	//MARK: -  Init and Override
	
	//Custom Initializer for taking in the selected Emoticons Data; then assigning injected data to our local variable
	init(selectedEmoticon: Emoticon) {
		
		self.selectedEmoticon = selectedEmoticon
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
		view.addSubview(emoticonImage)


		NSLayoutConstraint.activate([
			//ContainerView
			containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.40),
			containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			//Emoticon Image
			emoticonImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			emoticonImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
			emoticonImage.bottomAnchor.constraint(equalTo: containerView.topAnchor),
			emoticonImage.widthAnchor.constraint(greaterThanOrEqualTo: view.widthAnchor, multiplier: 0.40),
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
	
	
	//MARK: - Action and Helper Methods
	
	//Method called when favorite button is tapped; saving emoticon to coredata
	@objc func favoritesTapped() {
		favoriteButton.isSelected = true
		let favoritedEmoticon = FavoritedEmoticon(context: context)
		
		favoritedEmoticon.id = Int32(selectedEmoticon.id)
		favoritedEmoticon.name = selectedEmoticon.name
		favoritedEmoticon.imageData = selectedEmoticon.image?.pngData()
		
		do {
			try context.save()
			print("Successfully saved Emoticon")
		} catch {
			print("Failed to save emoticon: \(error)")
		}
		
	}
	
	
}
