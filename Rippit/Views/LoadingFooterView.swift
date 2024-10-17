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
	
	static let identifier = "LoadingFooterView"
	
	//This is the loading indicator shown when emoticons are being fetched
	let spinner: UIActivityIndicatorView = {
		let spinner = UIActivityIndicatorView(style: .large)
		spinner.color = DesignManager.shared.navyBlueText
		spinner.translatesAutoresizingMaskIntoConstraints = false
		spinner.startAnimating()
		return spinner
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		addSubview(spinner)
		NSLayoutConstraint.activate([
			spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
			spinner.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
