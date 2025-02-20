//
//  EmoticonsCell.swift
//  Rippit
//
//  Created by Daniel Efrain Ocasio on 10/7/24.
//

import Foundation
import UIKit
import Messages

class EmoticonCell: UICollectionViewCell {
	
	//MARK: - Declarations
	
	//Call back closure for tap action
	public typealias OnFavoriteInteraction = () -> Void
	var onFavoriteTap: OnFavoriteInteraction?
	
	//Subviews
	lazy var emoticonStickerView = FFZStickerView()
	lazy var favoriteButton: UIButton = {
		let button = UIButton(type: .custom)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.imageView?.contentMode = .scaleAspectFit
		button.setImage(UIImage(systemName: "heart"), for: .normal)
		button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
		button.tintColor = DesignManager.shared.navyBlueText
		//Add gesture recognizer for tap
		let tapped = UITapGestureRecognizer(target: self, action: #selector(favoriteButtonTapped))
		button.addGestureRecognizer(tapped)
		return button
	}()
	
	
	//MARK: - init
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupCell()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	//MARK: - Setup Methods
	
	func setupCell() {
		// Self
		self.backgroundColor = DesignManager.shared.grayAccent
		self.layer.cornerRadius = 5
		// Shadow
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOpacity = 0.3
		layer.shadowOffset = CGSize(width: -2, height: 2)
		layer.shadowRadius = 5
		// Subviews
		self.contentView.addSubview(emoticonStickerView)
		self.contentView.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 20, right: 20)
		self.contentView.addSubview(favoriteButton)
		
		NSLayoutConstraint.activate([
			emoticonStickerView.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
			emoticonStickerView.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor),
			emoticonStickerView.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
			emoticonStickerView.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor),
			favoriteButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -3),
			favoriteButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -3),
			favoriteButton.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 0.25)
		])
	}
	
	//Tap Action Method
	@objc func favoriteButtonTapped() {
		onFavoriteTap?()
	}
}


//Custom Sticker View with tap methods
public class FFZStickerView: MSStickerView {
	
	//Call back closure for handling tap actions
	public typealias OnInteraction = () -> Void
	var onTap: OnInteraction?
	
	//Init
	init() {
		super.init(frame: .zero)
		// General Setup
		contentMode = .scaleAspectFit
		translatesAutoresizingMaskIntoConstraints = false
		clipsToBounds = true
		// Add gesture recognizer for tap
		let tapped = UITapGestureRecognizer(target: self, action: #selector(stickerTapped))
		self.addGestureRecognizer(tapped)
	}
	
	//Tap action method
	@objc func stickerTapped() {
		onTap?()
	}
	
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
