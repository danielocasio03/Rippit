//
//  LoadingFooterView.swift
//  Rippit
//
//  Created by Daniel Efrain Ocasio on 10/15/24.
//

import Foundation
import UIKit

//This is the footerview for our collectionview that houses the loading indicator showen when emoticons are being fetched
class LoadingFooterView: UICollectionReusableView {
	
	//MARK: - Declarations
	static let identifier = "LoadingFooterView"
	
	//This is the loading indicator shown when emoticons are being fetched
	let spinner: UIActivityIndicatorView = {
		let spinner = UIActivityIndicatorView(style: .large)
		spinner.color = DesignManager.shared.navyBlueText
		spinner.translatesAutoresizingMaskIntoConstraints = false
		spinner.startAnimating()
		return spinner
	}()
	
	//Label shown when we run out of emoticons to show, or search yields no results
	let noEmoticonsLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.isHidden = true
		label.text = "Much Searching Done, Such Void to See 😞"
		label.textAlignment = .center
		label.font = UIFont(name: "AvenirNext-Bold", size: 15)
		label.textColor = .gray
		return label
	}()
	
	//MARK: - Override init
	override init(frame: CGRect) {
		super.init(frame: frame)
		addSubview(spinner)
		addSubview(noEmoticonsLabel)
		NSLayoutConstraint.activate([
			//Spinner
			spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
			spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
			//No Emoticons Label
			noEmoticonsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			noEmoticonsLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
