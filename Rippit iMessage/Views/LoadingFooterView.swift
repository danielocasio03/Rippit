//
//  LoadingFooterView.swift
//  Rippit
//
//  Created by Daniel Efrain Ocasio on 10/15/24.
//

import Foundation
import UIKit

//Footerview in collectionview that houses loading indicator showen when emoticons are being fetched
class LoadingFooterView: UICollectionReusableView {
	
	//MARK: - Declarations
	
	static let identifier = "LoadingFooterView"
	
	//Loading Indicator
	let spinner: UIActivityIndicatorView = {
		let spinner = UIActivityIndicatorView(style: .large)
		spinner.color = DesignManager.shared.navyBlueText
		spinner.translatesAutoresizingMaskIntoConstraints = false
		spinner.startAnimating()
		return spinner
	}()
	//No Emoticons Status Message
	let noEmoticonsLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.isHidden = true
		label.text = ""
		label.textAlignment = .center
		label.font = UIFont(name: "AvenirNext-Bold", size: 15)
		label.textColor = .gray
		return label
	}()
	
	
	//MARK: - Override init
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		// Add Subviews and configure constraints
		addSubview(spinner)
		addSubview(noEmoticonsLabel)
		NSLayoutConstraint.activate([
			spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
			spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
			noEmoticonsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			noEmoticonsLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}
	
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
