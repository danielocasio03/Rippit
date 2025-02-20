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

	lazy var emoticonStickerView = FFZStickerView()
	
	//MARK: - Override
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupCell()
	}
	
	
	//MARK: - Setup Functions
	
	func setupCell() {
		//Cell properties
		self.backgroundColor = DesignManager.shared.grayAccent
		self.layer.cornerRadius = 5
		// Shadow settings
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOpacity = 0.3
		layer.shadowOffset = CGSize(width: -2, height: 2)
		layer.shadowRadius = 5
		
		//Emoticon sticker
		self.contentView.addSubview(emoticonStickerView)
		self.contentView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		
		NSLayoutConstraint.activate([
			//Emoticon sticker
			emoticonStickerView.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor, constant: 10),
			emoticonStickerView.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor, constant: -10),
			emoticonStickerView.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor, constant: 10),
			emoticonStickerView.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor, constant: -10)

		])
		
	}
	
	
	
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

//Custom Sticker view class with tap methods
public class FFZStickerView: MSStickerView {
	
	//Call back closure for handling tap actions
	public typealias OnInteraction = () -> Void
		
	var onTap: OnInteraction?
		
	init() {
		super.init(frame: .zero)
		// General setup
		contentMode = .scaleAspectFit
		translatesAutoresizingMaskIntoConstraints = false
		clipsToBounds = true
		
		//Adding gesture recognizer for tap
		let tapped = UITapGestureRecognizer(target: self, action: #selector(stickerTapped))
		self.addGestureRecognizer(tapped)
		
	}
	
	//Tap action method
	@objc func stickerTapped() {
		onTap?()
	}
	
	//Tap action method
	public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		onTap?()
	}
	
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
}
