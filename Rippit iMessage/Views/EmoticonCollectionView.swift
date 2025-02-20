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
	
	//MARK: - Setup Methods

	//Layout Setup
	static func collectionLayoutSetup() -> UICollectionViewLayout {
		// Fixed size for each item
		let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(0.25),
			heightDimension: .absolute(100)
		))
		item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
		
		// Group with a fixed size to match item dimensions
		let group = NSCollectionLayoutGroup.horizontal(
			layoutSize: NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1), // Group spans the full width
				heightDimension: .absolute(108) // Height matches the item + insets
			),
			subitems: [item]
		)
		
		// Section
		let section = NSCollectionLayoutSection(group: group)
		
		// Footer
		let footerSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .absolute(100)
		)
		let footer = NSCollectionLayoutBoundarySupplementaryItem(
			layoutSize: footerSize,
			elementKind: UICollectionView.elementKindSectionFooter,
			alignment: .bottom
		)
		// Add Footer
		section.boundarySupplementaryItems = [footer]
		
		return UICollectionViewCompositionalLayout(section: section)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
