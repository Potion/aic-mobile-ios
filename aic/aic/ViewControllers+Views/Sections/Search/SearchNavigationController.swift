//
//  SearchNavigationController.swift
//  aic
//
//  Created by Filippo Vanucci on 12/7/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

class SearchNavigationController : CardNavigationController {
	let backButton: UIButton = UIButton()
	let searchBar: UISearchBar = UISearchBar()
	let searchButton: UIButton = UIButton()
	let dividerLine: UIView = UIView()
	let resultsVC: ResultsTableViewController = ResultsTableViewController()
    
    let slideAnimator: SearchSlideAnimator = SearchSlideAnimator()
	
	let searchResultsTopMargin: CGFloat = 80
	
	var searchBarLeadingConstraint: NSLayoutConstraint? = nil
	var searchBarActiveLeading: CGFloat = 2
	var searchBarInactiveLeading: CGFloat = 32
	
	init() {
        super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		SearchDataManager.sharedInstance.delegate = self
		
		backButton.isEnabled = false
		backButton.setImage(#imageLiteral(resourceName: "backButton"), for: .normal)
		backButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		backButton.addTarget(self, action: #selector(backButtonPressed(button:)), for: .touchUpInside)
		
		searchBar.barTintColor = .aicDarkGrayColor
		searchBar.tintColor = .white
		searchBar.showsBookmarkButton = false
		searchBar.showsCancelButton = false
		searchBar.searchBarStyle = .prominent
		searchBar.backgroundColor = .aicDarkGrayColor
		searchBar.isTranslucent = false
		searchBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
		searchBar.setImage(#imageLiteral(resourceName: "searchClear"), for: .clear, state: .normal)
		searchBar.placeholder = Common.Search.searchBarPlaceholder
		searchBar.keyboardAppearance = .dark
		searchBar.delegate = self
		
		let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
		searchTextField?.backgroundColor = .aicDarkGrayColor
		searchTextField?.textColor = .white
		searchTextField?.font = .aicSearchBarFont
		searchTextField?.leftViewMode = .never
		
		searchButton.setImage(#imageLiteral(resourceName: "iconSearch"), for: .normal)
		searchButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
		searchButton.addTarget(self, action: #selector(searchButtonPressed(button:)), for: .touchUpInside)
		
		dividerLine.backgroundColor = .white
		
		resultsVC.searchDelegate = self
		
		// TODO: figure out why I can set constraints on the tableVC, it messes up when navigating to the next page
		//self.rootVC.view.clipsToBounds = false
//        resultsVC.view.frame = CGRect(x: 0, y: searchResultsTopMargin, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - Common.Layout.cardFullscreenPositionY - searchResultsTopMargin - Common.Layout.tabBarHeight)
		
		// Add subviews
		self.view.addSubview(searchBar)
		self.view.addSubview(searchButton)
		self.view.addSubview(backButton)
		self.view.addSubview(dividerLine)
        
        // Add main VC as subview to rootVC
        resultsVC.willMove(toParentViewController: rootVC)
        rootVC.view.addSubview(resultsVC.view)
        resultsVC.didMove(toParentViewController: rootVC)
        
        createViewConstraints()
        
        // NavigationController Delegate
        self.delegate = self
	}
	
	func createViewConstraints() {
		searchBar.autoPinEdge(.top, to: .top, of: self.view, withOffset: 32)
		searchBarLeadingConstraint = searchBar.autoPinEdge(.leading, to: .leading, of: self.view, withOffset: 2)
		searchBar.autoPinEdge(.trailing, to: .leading, of: searchButton, withOffset: 12)
		searchBar.autoSetDimension(.height, toSize: 36)
		
		backButton.autoPinEdge(.trailing, to: .leading, of: searchBar, withOffset: 16)
		backButton.autoPinEdge(.bottom, to: .top, of: dividerLine, withOffset: 2)
		
		searchButton.autoPinEdge(.trailing, to: .trailing, of: self.view, withOffset: -6)
		searchButton.autoPinEdge(.bottom, to: .top, of: dividerLine, withOffset: 2)
		
		dividerLine.autoPinEdge(.top, to: .top, of: self.view, withOffset: 69)
		dividerLine.autoPinEdge(.leading, to: .leading, of: self.view, withOffset: 16)
		dividerLine.autoPinEdge(.trailing, to: .trailing, of: self.view, withOffset: -16)
		dividerLine.autoSetDimension(.height, toSize: 1)

		// TODO: figure out why I can set constraints on the tableVC, it messes up when navigating to the next page
        resultsVC.view.autoPinEdge(.top, to: .top, of: rootVC.view, withOffset: searchResultsTopMargin)
        resultsVC.view.autoPinEdge(.leading, to: .leading, of: rootVC.view)
        resultsVC.view.autoPinEdge(.trailing, to: .trailing, of: rootVC.view)
        resultsVC.view.autoPinEdge(.bottom, to: .bottom, of: rootVC.view, withOffset: -Common.Layout.tabBarHeight)
	}
	
	override func cardWillShowFullscreen() {
		if viewControllers.count < 2 {
			// show keyboard when the card shows
			DispatchQueue.main.async {
				let searchTextField = self.searchBar.value(forKey: "searchField") as? UITextField
				searchTextField?.becomeFirstResponder()
			}
		}
		
		resultsVC.view.setNeedsLayout()
		resultsVC.view.layoutIfNeeded()
	}
	
	override func cardDidShowFullscreen() {
		resultsVC.view.setNeedsLayout()
		resultsVC.view.layoutIfNeeded()
	}
	
	override func handlePanGesture(recognizer: UIPanGestureRecognizer) {
		// dismiss the keyboard when the user taps to close the card
		let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
		searchTextField?.resignFirstResponder()
		searchTextField?.layoutIfNeeded()
		
		super.handlePanGesture(recognizer: recognizer)
	}
	
	// Start New Search
	func loadSearch(searchText: String, showAutocomplete: Bool) {
		resultsVC.autocompleteStringItems.removeAll()
		resultsVC.artworkItems.removeAll()
		resultsVC.tourItems.removeAll()
		resultsVC.exhibitionItems.removeAll()
		if showAutocomplete == true {
			SearchDataManager.sharedInstance.loadAutocompleteStrings(searchText: searchText)
		}
		SearchDataManager.sharedInstance.loadArtworks(searchText: searchText)
		SearchDataManager.sharedInstance.loadTours(searchText: searchText)
		if resultsVC.filter == .empty {
			resultsVC.filter = .suggested
		}
		else {
			resultsVC.tableView.reloadData()
		}
	}
	
	// Search Button Pressed
	@objc func searchButtonPressed(button: UIButton) {
		if let searchText = searchBar.text {
			if searchText.isEmpty == false {
				// dismiss the keyboard when the user taps to close the card
				let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
				searchTextField?.resignFirstResponder()
				searchTextField?.layoutIfNeeded()
				
				loadSearch(searchText: searchText, showAutocomplete: false)
			}
		}
	}
	
	// Back Button Pressed
	@objc func backButtonPressed(button: UIButton) {
		hideBackButton()
		self.popViewController(animated: true)
		self.view.layoutIfNeeded()
		
		// TEMPORARY FIX!
		// TODO: figure out why I can set constraints on the tableVC, it messes up when navigating to the next page
//        resultsVC.view.frame = CGRect(x: 0, y: searchResultsTopMargin, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - Common.Layout.cardFullscreenPositionY - searchResultsTopMargin - Common.Layout.tabBarHeight)
	}
	
	func showBackButton() {
		let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
		searchTextField?.clearButtonMode = .never
		searchBar.isUserInteractionEnabled = false
		searchButton.isHidden = true
		backButton.isEnabled = true
		UIView.animate(withDuration: 0.3) {
			self.searchBarLeadingConstraint?.constant = self.searchBarInactiveLeading
			self.view.layoutIfNeeded()
		}
	}
	
	func hideBackButton() {
		let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
		searchTextField?.clearButtonMode = .always
		searchBar.isUserInteractionEnabled = true
		searchButton.isHidden = false
		backButton.isEnabled = false
		UIView.animate(withDuration: 0.3) {
			self.searchBarLeadingConstraint?.constant = self.searchBarActiveLeading
			self.view.layoutIfNeeded()
		}
	}
}

// MARK: UISearchBarDelegate
extension SearchNavigationController : UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchText.count > 0 {
			loadSearch(searchText: searchText, showAutocomplete: true)
		}
		else {
			resultsVC.filter = .empty
		}
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		if let searchText = searchBar.text {
			if searchText.isEmpty == false {
				// dismiss the keyboard when the user taps to close the card
				let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
				searchTextField?.resignFirstResponder()
				searchTextField?.layoutIfNeeded()
				
				loadSearch(searchText: searchText, showAutocomplete: false)
			}
		}
	}
}

// MARK: SearchDataManagerDelegate

extension SearchNavigationController : SearchDataManagerDelegate {
	func searchDataDidFinishLoading(autocompleteStrings: [String]) {
		resultsVC.autocompleteStringItems = autocompleteStrings
		resultsVC.tableView.reloadData()
		self.view.layoutIfNeeded()
	}
	
	func searchDataDidFinishLoading(artworks: [AICObjectModel]) {
		resultsVC.artworkItems = artworks
		resultsVC.tableView.reloadData()
		self.view.layoutIfNeeded()
	}
	
	func searchDataDidFinishLoading(tours: [AICTourModel]) {
		resultsVC.tourItems = tours
		resultsVC.tableView.reloadData()
		self.view.layoutIfNeeded()
	}
	
	func searchDataDidFinishLoading(exhibitions: [AICExhibitionModel]) {
		resultsVC.exhibitionItems = exhibitions
		resultsVC.tableView.reloadData()
		self.view.layoutIfNeeded()
	}
	
	func searchDataFailure(withMessage: String) {
		
	}
}

// MARK: ResultsTableViewControllerDelegate

extension SearchNavigationController : ResultsTableViewControllerDelegate {
	func resultsTableViewWillScroll() {
		// dismiss the keyboard when the user scrolls results
		let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
		searchTextField?.resignFirstResponder()
		searchTextField?.layoutIfNeeded()
	}
	
	func resultsTableDidSelect(searchText: String) {
		let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
		searchTextField?.text = searchText
		searchTextField?.resignFirstResponder()
		searchTextField?.layoutIfNeeded()
		
		loadSearch(searchText: searchText, showAutocomplete: false)
	}
	
	func resultsTableDidSelect(artwork: AICObjectModel) {
		let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
		searchTextField?.resignFirstResponder()
		searchTextField?.layoutIfNeeded()
		
		showBackButton()
		
		let artworkVC = ArtworkTableViewController(artwork: artwork)
		let contentVC = SearchContentViewController(tableVC: artworkVC)
		self.pushViewController(contentVC, animated: true)
	}
	
	func resultsTableDidSelect(tour: AICTourModel) {
		let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
		searchTextField?.resignFirstResponder()
		searchTextField?.layoutIfNeeded()
		
		showBackButton()
		
		let tourVC = TourTableViewController(tour: tour)
		let contentVC = SearchContentViewController(tableVC: tourVC)
		self.pushViewController(contentVC, animated: true)
	}
	
	func resultsTableDidSelect(exhibition: AICExhibitionModel) {
		
	}
	
	func resultsTableDidSelect(filter: Common.Search.Filter) {
		resultsVC.filter = filter
	}
}

// MARK: UINavigationControllerDelegate

extension SearchNavigationController : UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        slideAnimator.isAnimatingIn = (operation == .push)
        return slideAnimator
    }
}

