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
		
		self.clipsToBounds = false
		backgroundColor = DesignManager.shared.lightBgColor
		
	}
	
	
	
	
	//MARK: - Setup methods

	//Layout Setup
	static func collectionLayoutSetup() -> UICollectionViewLayout {
		
		//Item
		let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(0.33333),
			heightDimension: .fractionalHeight(1))
		)
		item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
		
		//Group
		let group = NSCollectionLayoutGroup.horizontal(
			layoutSize: NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1),
				heightDimension: .fractionalHeight(0.18)
			),
			subitems: [item]
		)
		
		//Sections
		let section = NSCollectionLayoutSection(group: group)
		
		// Footer setup
		let footerSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .absolute(100)
		)
		
		//Defining a Footer for the custom collectionview layout
		let footer = NSCollectionLayoutBoundarySupplementaryItem(
			layoutSize: footerSize,
			elementKind: UICollectionView.elementKindSectionFooter,
			alignment: .bottom
		)
		
		// Add footer to the section
		section.boundarySupplementaryItems = [footer]
		
		return UICollectionViewCompositionalLayout(section: section)
		
	}
	
	
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
