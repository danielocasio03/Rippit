//
//  MessagesViewController.swift
//  Rippit iMessage
//
//  Created by Daniel Efrain Ocasio on 11/19/24.
//

import UIKit
import Combine
import Foundation
import Messages

class MessagesViewController: MSMessagesAppViewController {
    
	//MARK: - Declarations
	
	let fetchManager = EmoticonsFetchManager()
	
	//This is the collection view that holds all of the emotes
	lazy var emoticonCollection = EmoticonCollectionView()
	var emoticonCollectionTopConstraint: NSLayoutConstraint! //Reference to the collectionviews top constraint
	
	let searchController = UISearchController(searchResultsController: nil)
	
	private var cancellables = Set<AnyCancellable>()
	
	var popularEmoticons: [Emoticon] = [] //Storage container for popular emoticons data
	var newEmoticons: [Emoticon] = [] //Storage container for new emoticons data
	var searchedEmoticons: [Emoticon] = [] //Storage container for searched emoticons data
	var onScreenEmoticons: [Emoticon] = [] //This is the array container for the data shown on screen
	
	var popularLoadedPage = 0 //Variable used to keep count of the current number of loaded popular Pages. initially zero
	var newLoadedPage = 0 //Variable used to keep count of the current number of loaded new Pages. initially zero
	var searchLoadedPage = 0  //Variable used to keep count of the current number of loaded search Pages. initially zero
	var searchTerm = ""
	
	var isFetching = false
	var morePagesToLoad = true
	
	
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
	
	//Button that goes in the nav bar and links to the favorites page
	lazy var favoriteButton: UIBarButtonItem = {
		let button = FavoriteButton(frame: .zero, color: .clear)
		button.addTarget(self, action: #selector(favoritesTapped), for: .touchUpInside)
		let configuration = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
		button.setImage(UIImage(systemName: "heart.fill", withConfiguration: configuration), for: .normal)
		let barButton = UIBarButtonItem(customView: button)
		return barButton
	}()
	
	
	
	//MARK: - Life Cycle Methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupView()
		setupNavController()
		setupSearchController()
		setupCollectionView()
		fetchEmoticons(category: "popular", searchTerm: nil)
		
		
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
		morePagesToLoad = true
		//Switch to identify the tapped button and take action from there
		switch sender {
		case popularButton:
			popularButton.isSelected = true
			newButton.isSelected = false
			//If statement that checks if the popularEmoticons Page data source already has data. If not, do a fetch before updating the screen, else just update the screen.
			if popularLoadedPage == 0 {
				isFetching = true
				fetchEmoticons(category: "popular", searchTerm: nil)
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
				fetchEmoticons(category: "new", searchTerm: nil)
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
	
	//Action Button for when the favorites button is tapped
	@objc func favoritesTapped() {
		print("Button tapped")
		let favoritesVC = FavoritesVC()
		self.navigationController?.pushViewController(favoritesVC, animated: true)
		
	}
	
	//Method handling the fetch of the Emoticons from the database
	func fetchEmoticons(category: String, searchTerm: String?) {
		
		//Checking which category and page to to fetch for
		var pageToLoad: Int
		if category == "popular" {
			popularLoadedPage += 1
			pageToLoad = popularLoadedPage
		} else if category == "new" {
			newLoadedPage += 1
			pageToLoad = newLoadedPage
		} else {
			searchLoadedPage += 1
			pageToLoad = searchLoadedPage
		}
		
		print("Beginning fetch for category: \(category), page: \(pageToLoad)")
		
		fetchManager.fetchEmoticons(category: category, searchTerm: searchTerm, pageToLoad: pageToLoad)
			.sink { completion in
				print("Emoticons fetch for \(category), Page: \(pageToLoad) returned with status: \(completion)")
				self.isFetching = false
			} receiveValue: { [weak self] data in
				guard let self = self else {return}
				morePagesToLoad = !data.isEmpty
				// Append fetched data to the respective storage array
				if category == "popular" {
					self.popularEmoticons.append(contentsOf: data)
				} else if category == "new" {
					self.newEmoticons.append(contentsOf: data)
				} else {
					self.searchedEmoticons.append(contentsOf: data)
				}
				
				// Only update onScreenEmoticons if the respective category button is selected
				if category == "popular", self.popularButton.isSelected {
					self.onScreenEmoticons = self.popularEmoticons
				} else if category == "new", self.newButton.isSelected {
					self.onScreenEmoticons = self.newEmoticons
				} else {
					self.onScreenEmoticons = self.searchedEmoticons
				}
				
				// Reload collection view to update UI
				self.emoticonCollection.reloadData()
			}
			.store(in: &cancellables)
	}
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dismisses the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }

}


//MARK: - EXT: Collection View
extension MessagesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	
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
		//Assignment of the sticker to the cell
		let emoticonForCell = onScreenEmoticons[indexPath.item]
		cell.emoticonStickerView.sticker = emoticonForCell.sticker
		cell.emoticonStickerView.sizeToFit()
		//Starting animation of emoticon if it is animated
		if emoticonForCell.isAnimated {
			cell.emoticonStickerView.startAnimating()
		}
		
		//Method in charge of adding in the functionality of tapped stickers
		cell.emoticonStickerView.onTap = { [weak self] in
			guard let self = self else {return}
			// Safely unwrap the sticker
			if let sticker = emoticonForCell.sticker {
				let emoticonVC = SelectedEmoticonVC(id: Int(emoticonForCell.id), name: emoticonForCell.name, sticker: sticker, isAnimated: emoticonForCell.isAnimated) // Create Selected Emoticon VC
				self.present(emoticonVC, animated: true) // Present
			} else {
				// Handle the case where the sticker or name is nil
				print("Emoticon sticker is nil.")
			}
		}
		
		return cell
	}
	
	
	//Function that returns a Header/Footer view -  In this case we use it to return our custom footer
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		if kind == UICollectionView.elementKindSectionFooter {
			let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
																		 withReuseIdentifier: LoadingFooterView.identifier,
																		 for: indexPath) as! LoadingFooterView
			footer.spinner.isHidden = !morePagesToLoad
			footer.noEmoticonsLabel.isHidden = morePagesToLoad
			
			return footer
		}
		return UICollectionReusableView()
	}
	
}


//MARK: - EXT: Search Controller & Navigation Controller
extension MessagesViewController: UISearchBarDelegate {
	
	//Function for the setup of the Nav Controller
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
		navigationItem.rightBarButtonItem = favoriteButton
		navigationController?.navigationBar.overrideUserInterfaceStyle = .light
	}
	
	//Function for the setup of the Search Controller
	func setupSearchController() {
		//Search Controller
		searchController.searchBar.delegate = self
		definesPresentationContext = true
		searchController.obscuresBackgroundDuringPresentation = true
		searchController.searchBar.placeholder = "Search for emoticons..."
		navigationItem.searchController = searchController
	}
	
	// Called when return key is tapped, fetching for the typed emoticon
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		morePagesToLoad = true
		popularButton.isSelected = false
		newButton.isSelected = false
		searchedEmoticons = []
		searchLoadedPage = 0
		if let safeSearch = searchBar.text {
			searchTerm = safeSearch.replacingOccurrences(of: " ", with: "")
		} else {
			let alert = UIAlertController(title: "Search Failed", message: "Please enter a valid search term", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			present(alert, animated: true, completion: nil)
		}
		
		searchController.isActive = false
		
		print(searchTerm)
		fetchEmoticons(category: "search", searchTerm: searchTerm)
	}
	
}


//MARK: - EXT: ScrollViewDelegate
extension MessagesViewController: UIScrollViewDelegate {
	
	//Called when the scrollview is scrolled (Collectionview in this case)
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let yOffset = scrollView.contentOffset.y
		
		// Total space that can be collapsed (buttons height, navbar/search bar height)
		let maxMovement = popularButton.frame.height + (navigationController?.navigationBar.frame.height ?? 0)
		
		// Move collection view, fade and translate buttons
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
		if scrollView.contentOffset.y > threshold && scrollView.isDragging && !isFetching && morePagesToLoad {
			isFetching = true
			//Checking which page we are currently on so we know which to fetch for
			if popularButton.isSelected {
				fetchEmoticons(category: "popular", searchTerm: nil)
			} else if newButton.isSelected {
				fetchEmoticons(category: "new", searchTerm: nil)
			} else {
				fetchEmoticons(category: "search", searchTerm: searchTerm)
			}
			
			
		}
		
	}
	
}
