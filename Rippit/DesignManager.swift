//
//  DesignManager.swift
//  Rippit
//
//  Created by Daniel Efrain Ocasio on 10/7/24.
//

import Foundation
import UIKit

class DesignManager {
	
	//MARK: - Declarations
	
	// Singleton instance
	public static let shared = DesignManager()
	
	//The light color used in the apps background
	let lightBgColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)
	
	//The color of the apps title text and some of the larger heading text
	let navyBlueText = UIColor(red: 50/255, green: 64/255, blue: 84/255, alpha: 1.0)
	
	//The color of the apps deselected Text
	let grayText = UIColor(red: 131/255, green: 136/255, blue: 145/255, alpha: 1.0)
	
	//The accent color for selected objects
	let selectedBlueAccent = UIColor(red: 202/255, green: 216/255, blue: 228/255, alpha: 1.0)
	
	//Gray Accent
	let grayAccent = UIColor(red: 199/255, green: 199/255, blue: 199/255, alpha: 1.0)
}
