//
//  FavoritesVC.swift
//  Rippit
//
//  Created by Daniel Efrain Ocasio on 10/22/24.
//

import Foundation
import UIKit
import CoreData

class FavoritesVC: UIViewController {
	//MARK: - Declarations
	
	lazy var savedEmoticons: [FavoritedEmoticon] = [] //These are the saved emoticons to be used on screen
	
	lazy var emoticonCollection = EmoticonCollectionView()
		
	private let noEmoticonsLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.isHidden = true
		label.text = "Much Emptiness 😢 Such Sad"
		label.textAlignment = .center
		label.font = UIFont(name: "AvenirNext-Bold", size: 17)
		label.textColor = .gray
		return label
	}()
	
	
	//MARK: - Override and Init
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		fetchSavedEmoticons()
		setupView()
		setupCollectionView()
		
	}
	
	
	//MARK: - Setup Methods
	
	//general setup of the view
	func setupView() {
		//Self
		self.view.backgroundColor = DesignManager.shared.lightBgColor
		self.title = "Saved Emoticons"
		//Emoticon Collection
		self.view.addSubview(emoticonCollection)
		//noEmoticonLabel
		view.addSubview(noEmoticonsLabel)
		
		NSLayoutConstraint.activate([
			//Emoticon Collection
			emoticonCollection.topAnchor.constraint(equalTo: view.topAnchor),
			emoticonCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
			emoticonCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
			emoticonCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			//noEmoticonLabel
			noEmoticonsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			noEmoticonsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
		])
	}
	
	//Method for fetching saved emoticons from coredata
	func fetchSavedEmoticons() {
		let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
		let fetchRequest: NSFetchRequest<FavoritedEmoticon> = FavoritedEmoticon.fetchRequest()
		
		do {
			let emoticons = try context.fetch(fetchRequest)
			savedEmoticons = emoticons
			emoticonCollection.reloadData()
			noEmoticonsLabel.isHidden = !savedEmoticons.isEmpty
		} catch {
			print("Failed to fetch emoticons: \(error)")
		}
	}
	
}



//MARK: - EXT: Collection View
extension FavoritesVC: UICollectionViewDelegate, UICollectionViewDataSource {
	
	//General setup of the Emoticon Collection View
	func setupCollectionView() {
		
		emoticonCollection.translatesAutoresizingMaskIntoConstraints = false
		emoticonCollection.dataSource = self
		emoticonCollection.delegate = self
		//Registering Cell
		emoticonCollection.register(EmoticonCell.self,
									forCellWithReuseIdentifier: "cell")
	}
	
	
	//Items in Section Method
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return savedEmoticons.count
	}
	
	
	//Cell for Item Method
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = emoticonCollection.dequeueReusableCell(withReuseIdentifier: "cell",
														  for: indexPath) as! EmoticonCell
		//Assignment of the image to the cell
		let imageForCell = savedEmoticons[indexPath.item].image
		cell.EmoticonImage.image = imageForCell
		
		return cell
	}
	
	//Did Select Item At function called when a cell is selected
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let selectedEmoticon = savedEmoticons[indexPath.item]
		
		// Safely unwrap the name and image
		if let name = selectedEmoticon.name, let image = selectedEmoticon.image {
			let emoticonVC = SelectedEmoticonVC(id: Int(selectedEmoticon.id), name: name, image: image)
			self.present(emoticonVC, animated: true)
			emoticonVC.didUpdateEmote = { [weak self] in
				guard let self = self else { return }
				self.fetchSavedEmoticons()
			}
		} else {
			// Handle the case where the image or name is nil
			print("Emoticon name or image is nil.")
		}
	}
	
	
}
