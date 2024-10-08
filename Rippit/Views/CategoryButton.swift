//
//  CategoryButton.swift
//  Rippit
//
//  Created by Daniel Efrain Ocasio on 10/7/24.
//

import Foundation
import UIKit

class CategoryButton: UIButton {
	
	//MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupButton()
	}
	
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	//MARK: - Setup Methods
	
	// Set up the button's default styles
	private func setupButton() {
		self.translatesAutoresizingMaskIntoConstraints = false
		self.layer.cornerRadius = 10
		self.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 15)
		self.backgroundColor = .lightGray
		self.setTitleColor(DesignManager.shared.grayText, for: .normal)
		self.setTitleColor(DesignManager.shared.navyBlueText, for: .selected)
	}
	
	// Ammends the appearance when selected - shows blue when selected, grey when not
	override var isSelected: Bool {
		didSet {
			backgroundColor = isSelected ? DesignManager.shared.selectedBlueAccent : DesignManager.shared.grayAccent
		}
	}
	
}
