//
//  ViewController.swift
//  Rippit
//
//  Created by Daniel Efrain Ocasio on 10/7/24.
//

import UIKit
import Combine
import Foundation

class HomeVC: UIViewController {
	
	//MARK: - Declarations
	
	let searchController = UISearchController(searchResultsController: nil)
	
	let fetchManager = EmoticonsFetchManager()
	
	private var cancellables = Set<AnyCancellable>()
	
	var popularEmoticons: [Emoticon] = [] //Storage container for popular emoticons data
	
	var newEmoticons: [Emoticon] = [] //Storage container for new emoticons data
	
	var onScreenEmoticons: [Emoticon] = [] //This is the array container for the data shown on screen
	
	var popularLoadedPage = 0 //Variable used to keep count of the current number of loaded popular Pages. initially zero
	
	var newLoadedPage = 0 //Variable used to keep count of the current number of loaded new Pages. initially zero
	
	var isFetching = false
	
	//Button for the Popular Tab
	lazy var popularButton: CategoryButton = {
		let button = CategoryButton()
		button.setTitle("Popular Emotes", for: .normal)
		button.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
		button.isSelected = true
		
		return button
	}()
	
	//Button for the Newly Created Tab
	lazy var newButton: CategoryButton = {
		let button = CategoryButton()
		button.setTitle("Newly Created", for: .normal)
		button.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
		button.isSelected = false
		
		return button
	}()

	
	//This is the collection view that holds all of the emotes
	lazy var emoticonCollection = EmoticonCollectionView()
	var emoticonCollectionTopConstraint: NSLayoutConstraint! //Reference to the collectionviews top constraint

	
	
	//MARK: - Life Cycle Methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupView()
		setupNavController()
		setupSearchController()
		setupCollectionView()
		fetchEmoticons(category: "popular")
		
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
		emoticonCollectionTopConstraint = emoticonCollection.topAnchor.constraint(equalTo: newButton.bottomAnchor, constant: 10)

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
			emoticonCollectionTopConstraint,
			emoticonCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
			emoticonCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
			emoticonCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}
	
	
	//MARK: - Action and Helper Methods
	
	//Action button for tapped category buttons
	@objc func categoryButtonTapped(_ sender: CategoryButton) {
		//Ensuring the tapped button was not already selected
		guard !sender.isSelected else {return}
		
		//Switch to identify the tapped button and take action from there
		switch sender {
		case popularButton:
			popularButton.isSelected = true
			newButton.isSelected = false
			//If statement that checks if the popularEmoticons Page data source already has data. If not, do a fetch before updating the screen, else just update the screen.
			if popularLoadedPage == 0 {
				isFetching = true
				fetchEmoticons(category: "popular")
			} else {
				onScreenEmoticons = popularEmoticons
				DispatchQueue.main.async {
					self.emoticonCollection.reloadData()
				}
			}
			
		case newButton:
			popularButton.isSelected = false
			newButton.isSelected = true
			//If statement that checks if the newEmoticons Page data source already has data. If not, do a fetch before updating the screen, else just update the screen.
			if newLoadedPage == 0 {
				onScreenEmoticons = newEmoticons
				DispatchQueue.main.async {
					self.emoticonCollection.reloadData()
				}
				isFetching = true
				fetchEmoticons(category: "new")
			} else {
				onScreenEmoticons = newEmoticons
				DispatchQueue.main.async {
					self.emoticonCollection.reloadData()
				}
			}
			
		default:
			break
		}
		
	}
	
	//Method handling the fetch of the Emoticons from the database
	func fetchEmoticons(category: String) {
		
		//Checking which category and page to to fetch for
		var pageToLoad: Int
		if category == "popular" {
			popularLoadedPage += 1
			pageToLoad = popularLoadedPage
		} else {
			newLoadedPage += 1
			pageToLoad = newLoadedPage
		}
		

		fetchManager.fetchEmoticons(category: category, pageToLoad: pageToLoad)
			.sink { completion in
				print("Emoticons fetch returned with status: \(completion)")
				self.isFetching = false
			} receiveValue: { [weak self] data in
				guard let self = self else {return}
				//Checking the category so we know which data source to update and show
				if category == "popular" {
					self.popularEmoticons.append(contentsOf: data) //Appending the results of the fetch to the storage array
					self.onScreenEmoticons = popularEmoticons
				} else {
					self.newEmoticons.append(contentsOf: data)
					self.onScreenEmoticons = newEmoticons
				}
					emoticonCollection.reloadData()
			}
			.store(in: &cancellables)
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
				.foregroundColor: DesignManager.shared.navyBlueText, 
				.font: customFont                      
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
		
		emoticonCollection.translatesAutoresizingMaskIntoConstraints = false
		emoticonCollection.dataSource = self
		emoticonCollection.delegate = self
		
		//Registering Cell
		emoticonCollection.register(EmoticonCell.self,
									forCellWithReuseIdentifier: "cell")
		//Registering FooterView
		emoticonCollection.register(LoadingFooterView.self,
									forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
									withReuseIdentifier: LoadingFooterView.identifier)
	}
	
	
	//Items in Section Method
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return onScreenEmoticons.count
	}
	
	
	//Cell for Item Method
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = emoticonCollection.dequeueReusableCell(withReuseIdentifier: "cell", 
														  for: indexPath) as! EmoticonCell
		//Assignment of the image to the cell
		let cellForImage = onScreenEmoticons[indexPath.item].image
		cell.EmoticonImage.image = cellForImage
		
		return cell
	}
	
	
	//Function that returns a Header/Footer view -  In this case we use it to return our custom footer
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		if kind == UICollectionView.elementKindSectionFooter {
			let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
																		 withReuseIdentifier: LoadingFooterView.identifier,
																		 for: indexPath) as! LoadingFooterView
			return footer
		}
		
		return UICollectionReusableView()
	}
	
	
}


//MARK: - EXT: ScrollViewDelegate
extension HomeVC: UIScrollViewDelegate {
	
	//Called when the scrollview is scrolled (Collectionview in this case)
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let yOffset = scrollView.contentOffset.y
		
		// Total space that can be collapsed (buttons height, navbar/search bar height)
		let maxMovement = popularButton.frame.height + (navigationController?.navigationBar.frame.height ?? 0)
		
		// Move collection view, fade and translate buttons, fade search bar
		let isScrollingDown = yOffset > 0
		let movement = min(yOffset, maxMovement)
		
		//The Constraint constant for the collectionview
		let newConstant: CGFloat = isScrollingDown ? -movement : 10
		emoticonCollectionTopConstraint.constant = newConstant
		
		//Calculate the subview Alpha's and apply them to give a fade in/out animation
		let buttonAlpha = isScrollingDown ? max(0, 1 - (yOffset / (maxMovement * 0.08))) : 1
		let searchBarAlpha = isScrollingDown ? max(0, 1 - (yOffset / (maxMovement * 0.30))) : 1
		popularButton.alpha = buttonAlpha
		newButton.alpha = buttonAlpha
		popularButton.transform = isScrollingDown ? CGAffineTransform(translationX: 0, y: -yOffset / 2) : .identity
		newButton.transform = isScrollingDown ? CGAffineTransform(translationX: 0, y: -yOffset / 2) : .identity
		navigationItem.searchController?.searchBar.alpha = searchBarAlpha
		
		
		// Infinite Scroll Logic - calculates where the user is on the collectionview and when nearing the bottom, calls the method for fetching more emoticons
		let contentHeight = scrollView.contentSize.height
		let scrollViewHeight = scrollView.frame.size.height
		let threshold = contentHeight - scrollViewHeight - 700
		if scrollView.contentOffset.y > threshold && scrollView.isDragging && !isFetching {
			isFetching = true
			//Checking which page we are currently on so we know which to fetch for
			if popularButton.isSelected {
				fetchEmoticons(category: "popular")
			} else {
				fetchEmoticons(category: "new")
			}
			
		}
		
	}
	
}
