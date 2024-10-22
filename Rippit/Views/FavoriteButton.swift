//
//  FavoriteButton.swift
//  Rippit
//
//  Created by Daniel Efrain Ocasio on 10/22/24.
//

import Foundation
import UIKit

class FavoriteButton: UIButton {
	
	init(frame: CGRect, color: UIColor) {
		super.init(frame: frame)
		self.translatesAutoresizingMaskIntoConstraints = false
		// Set the button images config (normal and selected states)
		let configuration = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
		self.setImage(UIImage(systemName: "heart", withConfiguration: configuration), for: .normal)
		self.setImage(UIImage(systemName: "heart.fill", withConfiguration: configuration), for: .selected)
		self.tintColor = DesignManager.shared.navyBlueText
		self.backgroundColor = color
		self.layer.cornerRadius = 10
		
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
