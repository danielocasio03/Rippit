//
//  EmoticonsCollectionView.swift
//  Rippit
//
//  Created by Daniel Efrain Ocasio on 10/7/24.
//

import Foundation
import UIKit

class EmoticonCollectionView: UICollectionView {
	
	
	//MARK: - Init
	override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
		super.init(frame: .zero, collectionViewLayout: EmoticonCollectionView.collectionLayoutSetup())
		
		backgroundColor = DesignManager.shared.lightBgColor
		
	}
	
	
	
	
	//MARK: - Setup methods

	//Layout Setup
	static func collectionLayoutSetup() -> UICollectionViewLayout {
		
		//Item
		let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(0.33), heightDimension: .fractionalHeight(1)))
		item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6)
		
		//Group
		let group = NSCollectionLayoutGroup.horizontal(
			layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.18)),
			subitems: [item]
		)
		
		//Sections
		let section = NSCollectionLayoutSection(group: group)
		
		return UICollectionViewCompositionalLayout(section: section)
		
	}
	
	
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
