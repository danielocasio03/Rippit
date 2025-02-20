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
		let context = DataStoreManager.shared.persistentContainer.viewContext
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
		//Assignment of the sticker to the cell
		let emoticonForCell = savedEmoticons[indexPath.item]
		cell.emoticonStickerView.sticker = emoticonForCell.sticker
		
		//Animating if this is an animated emoticon
		if emoticonForCell.isAnimated {
			cell.emoticonStickerView.startAnimating()
		}
		
		//Method in charge of adding in the functionality of tapped stickers 
		cell.emoticonStickerView.onTap = { [weak self] in
			guard let self = self else {return}
			let name = emoticonForCell.name
			
			// Safely unwrap the name and sticker
			if let sticker = emoticonForCell.sticker {
				let emoticonVC = SelectedEmoticonVC(id: Int(emoticonForCell.id), name: name, sticker: sticker, isAnimated: emoticonForCell.isAnimated) // Create Selected Emoticon VC
				self.present(emoticonVC, animated: true) // Present
				//Defining Method in charge of updating view if user unsaves an emoticon
				emoticonVC.didUpdateEmote = { [weak self] in
					guard let self = self else { return }
					self.fetchSavedEmoticons()
				}
			} else {
				print("Emoticon name or sticker is nil.") // Handle the case where the sticker or name is nil
			}
		}
		
		return cell
	}
	
}
