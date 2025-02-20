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
import CoreData
import UniformTypeIdentifiers

class MessagesViewController: MSMessagesAppViewController {
	
	//MARK: - Properties
	
	//Managers
	private let fetchManager = EmoticonsFetchManager()
	private var cancellables = Set<AnyCancellable>()
	private let context = DataStoreManager.shared.persistentContainer.viewContext
	
	//Emoticon Data Containers
	private var popularEmoticons: [Emoticon] = [] //Storage container for popular emoticons data
	private var newEmoticons: [Emoticon] = [] //Storage container for new emoticons data
	private var searchedEmoticons: [Emoticon] = [] //Storage container for searched emoticons data
	private var onScreenEmoticons: [EmoticonDisplayable] = [] //This is the array container for the data shown on screen
	private lazy var savedEmoticons: [FavoritedEmoticon] = [] //This is the array container for the data shown on screen
	
	//Pagination Tracking
	private var popularLoadedPage = 0 //Keep count of loaded popular Pages. initially zero
	private var newLoadedPage = 0 //Keep count of loaded new Pages. initially zero
	private var searchLoadedPage = 0  //Keep count of loaded search Pages. initially zero
	
	//Fetching State
	private var searchTerm = ""
	private var morePagesToLoad = false
	private var isFetching = false
	
	//CollectionView
	private lazy var emoticonCollection = EmoticonCollectionView()
	private var emoticonCollectionTopConstraint: NSLayoutConstraint! //Top Constraint Reference
	
	//UI Elements
	private lazy var popularButton: CategoryButton = createCategoryButton(title: "Popular", isSelected: false)
	private lazy var newButton: CategoryButton = createCategoryButton(title: "Newest", isSelected: false)
	private lazy var favoriteButton: CategoryButton = createCategoryButton(title: "Favorites", isSelected: true)
	private lazy var searchBar: UISearchBar = {
		let searchBar = UISearchBar()
		searchBar.delegate = self
		searchBar.placeholder = "Search"
		searchBar.translatesAutoresizingMaskIntoConstraints = false
		searchBar.overrideUserInterfaceStyle = .light
		searchBar.searchBarStyle = .minimal
		return searchBar
	}()
	
	//UI Factory Methods
	private func createCategoryButton(title: String, isSelected: Bool) -> CategoryButton {
		let button = CategoryButton()
		button.setTitle(title, for: .normal)
		button.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
		button.isSelected = isSelected
		return button
	}
	
	//Button Positioning
	enum ButtonPosition {
		case leading
		case center
		case trailing
	}
	
	//Category Options
	enum SelectedCategory: String {
		case favorite = "favorite"
		case popular = "popular"
		case new = "new"
	}
	
	
	//MARK: - Life Cycle Methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
		setupCollectionView()
	}
	
	
	//MARK: - Setup Methods
	
	//Setup of View
	func setupView() {
		savedEmoticons = fetchSavedEmoticons()
		//Self
		self.view.backgroundColor = DesignManager.shared.lightBgColor //BG Color
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)) //Dismiss keyboard on tap
		tapGesture.cancelsTouchesInView = false
		view.addGestureRecognizer(tapGesture)
		
		//Add & Configure Subviews
		view.addSubview(searchBar)
		view.addSubview(favoriteButton)
		view.addSubview(popularButton)
		view.addSubview(newButton)
		configureCategoryConstraints(favoriteButton, position: .leading)
		configureCategoryConstraints(popularButton, position: .center)
		configureCategoryConstraints(newButton, position: .trailing)
		
		NSLayoutConstraint.activate([
			//Search Bar
			searchBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.90),
			searchBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			searchBar.heightAnchor.constraint(equalToConstant: 40),
			searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
		])
	}
	
	//Method for configuring category button constraints
	func configureCategoryConstraints(_ button: CategoryButton, position: ButtonPosition) {
		
		switch position {
		case .leading:
			button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
		case .center:
			button.centerXAnchor.constraint(greaterThanOrEqualTo: view.centerXAnchor).isActive = true
		case .trailing:
			button.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10).isActive = true
		}
		
		NSLayoutConstraint.activate([
			button.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.30),
			button.heightAnchor.constraint(equalToConstant: 30),
			button.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 5),
		])
	}
	
	
	//MARK: - Action and Helper Methods
	
	//Action function for dismissing the keyboard
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
	
	//Action button for tapped category buttons
	@objc func categoryButtonTapped(_ sender: CategoryButton) {
		guard !sender.isSelected else {return}
		[popularButton, newButton, favoriteButton].forEach { $0.isSelected = ($0 == sender) }
		handleCategorySelection(for: sender)
	}
	
	//State Management and Fetch Managment
	private func handleCategorySelection(for button: UIButton) {
		let category: SelectedCategory
		let loadedPage: Int
		let dataSource: [EmoticonDisplayable]
		
		if button == popularButton {
			category = .popular
			loadedPage = popularLoadedPage
			dataSource = popularEmoticons
		} else if button == newButton {
			category = .new
			loadedPage = newLoadedPage
			dataSource = newEmoticons
		} else {
			dataSource = fetchSavedEmoticons()
			onScreenEmoticons = dataSource
			emoticonCollection.reloadData()
			return
		}
		
		DispatchQueue.main.async { [weak self] in
			guard let self = self else {return}
			onScreenEmoticons = dataSource
			emoticonCollection.reloadData()
			if loadedPage == 0 {
				morePagesToLoad = true
				isFetching = true
				fetchEmoticons(category: category.rawValue, searchTerm: nil)
			}
			
		}
	}
	
	//Fetch Saved Emoticons
	func fetchSavedEmoticons() -> [FavoritedEmoticon] {
		let fetchRequest: NSFetchRequest<FavoritedEmoticon> = FavoritedEmoticon.fetchRequest()
		var fetchSavedEmoticons: [FavoritedEmoticon] = []
		
		do {
			fetchSavedEmoticons = try context.fetch(fetchRequest)
		} catch {
			print("Failed to fetch emoticons: \(error)")
		}
		
		print("We fetched for saved emoticons and got are returning an array with \(fetchSavedEmoticons.count) emoticons")
		return fetchSavedEmoticons
	}
	
	//Method that makes the network call and passes the sink
	func fetchEmoticons(category: String, searchTerm: String?) {
		// Determine the page to load and update the page count
		let pageToLoad = incrementPage(for: category)
		
		print("Beginning fetch for category: \(category), page: \(pageToLoad)")
		
		fetchManager.fetchEmoticons(category: category, searchTerm: searchTerm, pageToLoad: pageToLoad)
			.sink { completion in
				print("Emoticons fetch for \(category), Page: \(pageToLoad) returned with status: \(completion)")
				self.isFetching = false
			} receiveValue: { [weak self] data in
				guard let self = self else { return }
				self.handleFetchedData(data, for: category)
			}
			.store(in: &cancellables)
	}
	
	// Increment page count the given category and return page count
	private func incrementPage (for category: String) -> Int {
		if category == "popular" {
			popularLoadedPage += 1
			return popularLoadedPage
		} else if category == "new" {
			newLoadedPage += 1
			return newLoadedPage
		} else {
			searchLoadedPage += 1
			return searchLoadedPage
		}
	}
	
	// Handle fetched data and update UI
	private func handleFetchedData(_ data: [Emoticon], for category: String) {
		morePagesToLoad = data.count > 33
		
		// Append fetched data to the respective storage array
		switch category {
		case "popular":
			popularEmoticons.append(contentsOf: data)
			if popularButton.isSelected {
				onScreenEmoticons = popularEmoticons
			}
		case "new":
			newEmoticons.append(contentsOf: data)
			if newButton.isSelected {
				onScreenEmoticons = newEmoticons
			}
		default:
			searchedEmoticons.append(contentsOf: data)
			onScreenEmoticons = searchedEmoticons
		}
		
		DispatchQueue.main.async {
			self.emoticonCollection.reloadData()
		}
	}
	
	
	
}


//MARK: - EXT: Search Bar

extension MessagesViewController: UISearchBarDelegate {
	
	// Search/Return Tapped - Fetches based off user search term
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		//Reset Search State
		searchedEmoticons = []
		searchLoadedPage = 0
		
		//Safely unwrapping search query
		if let safeSearch = searchBar.text?.replacingOccurrences(of: " ", with: "") {
			searchTerm = safeSearch // Storing search term for use in other methods
			morePagesToLoad = true
			isFetching = true
			view.endEditing(true)
			onScreenEmoticons = searchedEmoticons
			[popularButton, newButton, favoriteButton].forEach { $0.isSelected = false } //Setting Category buttons to not selected
			fetchEmoticons(category: "search", searchTerm: searchTerm) //Fetch
		} else {
			let alert = UIAlertController(title: "Search Failed", message: "Please enter a valid search term", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			present(alert, animated: true, completion: nil)
		}
	}
	
}

//MARK: - EXT: Collection View

extension MessagesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	
	//Collection View Setup
	private func setupCollectionView() {
		onScreenEmoticons = savedEmoticons
		self.view.addSubview(emoticonCollection)
		emoticonCollection.translatesAutoresizingMaskIntoConstraints = false
		emoticonCollection.dataSource = self
		emoticonCollection.delegate = self
		emoticonCollectionTopConstraint = emoticonCollection.topAnchor.constraint(equalTo: newButton.bottomAnchor, constant: 10)
		
		//Register Cell
		emoticonCollection.register(EmoticonCell.self,
									forCellWithReuseIdentifier: "cell")
		//Register FooterView
		emoticonCollection.register(LoadingFooterView.self,
									forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
									withReuseIdentifier: LoadingFooterView.identifier)
		NSLayoutConstraint.activate([
			emoticonCollectionTopConstraint,
			emoticonCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
			emoticonCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
			emoticonCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}
	
	//MARK: - Helper Methods
	
	//Checks if emoticon with given ID is saved
	func isEmoticonSaved(emoticonID: Int32) -> Bool {
		return savedEmoticons.contains { $0.id == emoticonID }
	}
	
	//Configure cell; takes in emoticon that conforms to EmoticonDisplayable
	private func configureCell(_ cell: EmoticonCell, with emoticon: EmoticonDisplayable) {
		
		//Check if emoticon is saved
		let isSaved = isEmoticonSaved(emoticonID: emoticon.id)
		cell.favoriteButton.isSelected = isSaved
		
		//Assigning emoticon sticker to cell stickerview
		cell.emoticonStickerView.sticker = emoticon.sticker
		if emoticon.isAnimated {
			cell.emoticonStickerView.startAnimating()
		}
		
		//Add action for sticker tapped
		cell.emoticonStickerView.onTap = { [weak self] in
			guard let self = self else { return }
			stickerTapped(sticker: emoticon.sticker!, isAnimated: emoticon.isAnimated)
		}
		
		//Add action for when favorite (heart button) is tapped
		cell.onFavoriteTap = { [weak self] in
			guard let self = self else {return}
			updateSaveStatus(cell, with: emoticon, isSaved: isEmoticonSaved(emoticonID: emoticon.id)) //calls save method
		}
	}
	
	//Update user saved data when changes are made to emoticon. (Removes/Saves Emoticons to context)
	func updateSaveStatus(_ cell: EmoticonCell, with emoticon: EmoticonDisplayable, isSaved: Bool) {
		// 1. Check if Emoticon is already saved, if so delete it from save, if not save it
		if isSaved {
			// 2. Already exists; Delete from context
			if let existingFavorite = savedEmoticons.first(where: {$0.id == emoticon.id}) {
				context.delete(existingFavorite)}
			print("ALREADY SAVED, DELETING FROM SAVED...")
		} else {
			print("NOT YET SAVED, SAVING TO CONTEXT...")
			// 2. Does not exist; create new object for it in context
			let newFavorite = FavoritedEmoticon(context: context)
			newFavorite.id = emoticon.id
			newFavorite.name = emoticon.name
			newFavorite.isAnimated = emoticon.isAnimated
			
			// Safely unwrap the sticker and its imageFileURL
			if let sticker = emoticon.sticker {
				do {
					// Convert the sticker's image URL to Data
					let imageData = try Data(contentsOf: sticker.imageFileURL)
					newFavorite.imageData = imageData // Store the binary data in context
				} catch {
					print("Failed to load image data for saving: \(error)")
				}
			} else {
				print("Sticker or imageFileURL is nil, cannot save.")
			}
		}
		// 3. Save context & update class savedEmoticons array
		do {
			try context.save()
			// 4. Refreshing savedEmoticons, and calling the method to refresh screen with new changes
			savedEmoticons = fetchSavedEmoticons()
			if let selectedButton = [favoriteButton, newButton, popularButton].first(where: { $0.isSelected }) {
				handleCategorySelection(for: selectedButton)
			} else {
				onScreenEmoticons = searchedEmoticons
				emoticonCollection.reloadData()
			}
		} catch {
			print("Failed to save context: \(error)")
		}
	}
	
	// Resize an image while preserving its aspect ratio.
	private func resizeImage(_ image: UIImage, maxDimension: CGFloat = 408) -> UIImage? {
		let widthScale = maxDimension / image.size.width
		let heightScale = maxDimension / image.size.height
		let scaleFactor = min(widthScale, heightScale, 1.0)
		
		let newSize = CGSize(width: image.size.width * scaleFactor,
							 height: image.size.height * scaleFactor)
		
		UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
		image.draw(in: CGRect(origin: .zero, size: newSize))
		let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return scaledImage
	}
	
	// Create a scaled sticker from an existing sticker.
	private func createScaledSticker(from sticker: MSSticker, maxDimension: CGFloat = 408) -> MSSticker? {
		guard let image = UIImage(contentsOfFile: sticker.imageFileURL.path), // Load original image from sticker's URL
			  let scaledImage = resizeImage(image, maxDimension: maxDimension),
			  let imageData = scaledImage.pngData() else {
			print("Failed to create scaled image.")
			return nil
		}
		
		// Write scaled image to temporary file.
		let tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
		let tempFileURL = tempDir.appendingPathComponent("scaledSticker.png")
		do {
			try imageData.write(to: tempFileURL)
			// Create and return new MSSticker using the scaled image file
			let newSticker = try MSSticker(contentsOfFileURL: tempFileURL,
										   localizedDescription: sticker.localizedDescription)
			return newSticker
		} catch {
			print("Error creating scaled sticker: \(error)")
			return nil
		}
	}
	
	//Send tapped sticker
	private func stickerTapped(sticker: MSSticker, isAnimated: Bool) {
		switch isAnimated {
		case false:
			// Create scaled up sticker
			if let scaledSticker = createScaledSticker(from: sticker) {
				self.activeConversation?.send(scaledSticker)
			} else {
				self.activeConversation?.send(sticker)
			}
		case true:
			self.activeConversation?.send(sticker)
		}
		self.requestPresentationStyle(.compact)
	}

		
	//MARK: - CollectionView Delegate Methods
	
	//Items in Section
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		print("returning an array with \(onScreenEmoticons.count) items for section")
			return onScreenEmoticons.count
	}
	
	//Cell for Item
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = emoticonCollection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! EmoticonCell
		configureCell(cell, with: onScreenEmoticons[indexPath.item])
		
		return cell
		
	}
	
	
	//Returns Header/Footer view - In this case we use it to return our custom footer
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		if kind == UICollectionView.elementKindSectionFooter {
			let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
																		 withReuseIdentifier: LoadingFooterView.identifier,
																		 for: indexPath) as! LoadingFooterView
			
			//Conditional block for when and what the footer should show
			if favoriteButton.isSelected == true {
				footer.noEmoticonsLabel.isHidden = !onScreenEmoticons.isEmpty
				footer.spinner.isHidden = true
				footer.noEmoticonsLabel.text = "No Emoticons Saved 😢 Such Sad"
			} else {
				footer.noEmoticonsLabel.text = "Much Searching Done, Such Void to See 😞"
				footer.spinner.isHidden = !morePagesToLoad
				footer.noEmoticonsLabel.isHidden = morePagesToLoad
			}
			
			return footer
		}
		return UICollectionReusableView()
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

