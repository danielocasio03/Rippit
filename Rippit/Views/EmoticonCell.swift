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

	lazy var EmoticonSticker: MSStickerView = {
		let sticker = MSStickerView()
		sticker.translatesAutoresizingMaskIntoConstraints = false
		sticker.contentMode = .scaleAspectFit
		sticker.clipsToBounds = true
		
		return sticker
	}()
	
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
		self.contentView.addSubview(EmoticonSticker)
		self.contentView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		
		NSLayoutConstraint.activate([
			//Emoticon sticker
			EmoticonSticker.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
			EmoticonSticker.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor),
			EmoticonSticker.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
			EmoticonSticker.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor)

		])
		
	}
	
	
	
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
