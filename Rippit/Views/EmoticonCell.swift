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
	
	//Emoticon image
//	lazy var EmoticonImage: UIImageView = {
//		let image = UIImageView()
//		image.translatesAutoresizingMaskIntoConstraints = false
//		image.contentMode = .scaleAspectFit
//		image.clipsToBounds = true
//		
//		return image
//	}()
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
		
		//Emoticon Image
		self.addSubview(EmoticonSticker)
		
		NSLayoutConstraint.activate([
			//Emoticon Image
			EmoticonSticker.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			EmoticonSticker.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			EmoticonSticker.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.60)
		])
		
	}
	
	
	
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
