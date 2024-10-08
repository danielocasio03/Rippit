//
//  ViewController.swift
//  Rippit
//
//  Created by Daniel Efrain Ocasio on 10/7/24.
//

import UIKit

class HomeVC: UIViewController {
	
	//MARK: - Declarations
	
	let searchController = UISearchController(searchResultsController: nil)
	
	//Button for the Popular Tab
	lazy var popularButton: CategoryButton = {
		let button = CategoryButton()
		button.setTitle("Popular Emotes", for: .normal)
		button.isSelected = true
		
		return button
	}()
	
	//Button for the Newly Created Tab
	lazy var newButton: CategoryButton = {
		let button = CategoryButton()
		button.setTitle("Newly Created", for: .normal)
		button.isSelected = false
		
		return button
	}()
	
	//This is the collection view that holds all of the emotes
	lazy var emoticonCollection = EmoticonCollectionView()
	
	
	//MARK: - Life Cycle Methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupView()
		setupNavController()
		setupSearchController()
		setupCollectionView()
	}
	
	
	//MARK: - Setup Methods
	
	//General setup of the view
	func setupView() {
		//Self
		self.view.backgroundColor = DesignManager.shared.lightBgColor
		//Popular Button
		self.view.addSubview(popularButton)
		//New Button
		self.view.addSubview(newButton)
		//Emoticon Collection
		self.view.addSubview(emoticonCollection)
		
		NSLayoutConstraint.activate([
			//Popular Button
			popularButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			popularButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -20),
			popularButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
			popularButton.heightAnchor.constraint(equalToConstant: 30),
			//New Buton
			newButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 20),
			newButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			newButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
			newButton.heightAnchor.constraint(equalToConstant: 30),
			//Emoticon Collection
			//fix
			emoticonCollection.topAnchor.constraint(equalTo: newButton.bottomAnchor, constant: 10),
			emoticonCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			emoticonCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			emoticonCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
		
	}
}



//MARK: - EXT: Search Controller & Navigation Controller
extension HomeVC: UISearchResultsUpdating {
	
	//Function for the general setup of the Nav Controller
	func setupNavController() {
		// Set the title for the nav bar
		self.title = "Rippit"
		
		// Customizing the nav Title
		if let customFont = UIFont(name: "AvenirNext-Bold", size: 24) {
			navigationController?.navigationBar.titleTextAttributes = [
				.foregroundColor: DesignManager.shared.navyBlueText, //Custom Color
				.font: customFont                      // Apply Custom Font
			]
		}
	}
	
	
	//Function for the general setup of the Search Controller
	func setupSearchController() {
		
		//Search Controller
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = true
		searchController.searchBar.placeholder = "Search for emoticons..."
		navigationItem.searchController = searchController
		definesPresentationContext = true
		
	}
	
	
	//Update Search Results method
	func updateSearchResults(for searchController: UISearchController) {
		print("search typed in")
	}
}


//MARK: - EXT: Collection View
extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource {
	
	//General setup of the Emoticon Collection View
	func setupCollectionView() {
		emoticonCollection.translatesAutoresizingMaskIntoConstraints = false // fix
		emoticonCollection.dataSource = self
		emoticonCollection.delegate = self
		emoticonCollection.register(EmoticonCell.self,
									forCellWithReuseIdentifier: "cell")
		
	}
	
	//Items in Section Method
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 40
	}
	
	//Cell for Item Method
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = emoticonCollection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
		
		return cell
	}
	
	
	
}
