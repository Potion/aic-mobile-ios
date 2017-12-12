//
//  SearchResultsTableViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 12/8/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

protocol ResultsTableViewControllerDelegate : class {
	func resultsTableViewWillScroll()
}

class ResultsTableViewController : UITableViewController {
	let promotedSearchStringItems: [String] = ["Essentials Tour", "Impressionism", "American Gothic"]
	var autocompleteStringItems: [String] = []
	var artworkItems: [AICObjectModel] = []
	var tourItems: [AICTourModel] = []
	var exhibitionItems: [AICExhibitionModel] = []
	
	var filter: Common.Search.Filter = .empty {
		didSet {
			self.tableView.reloadData()
		}
	}
	
	let contentTitleHeight: CGFloat = 65
	let resultsSectionTitleHeight: CGFloat = 50
	
	weak var scrollDelegate: ResultsTableViewControllerDelegate? = nil
	
	init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = .aicDarkGrayColor
		
		self.tableView.separatorStyle = .none
//		self.tableView.rowHeight = UITableViewAutomaticDimension // Necessary for AutoLayout of cells
//		self.tableView.estimatedRowHeight = 30
		self.tableView.alwaysBounceVertical = false
		//self.tableView.bounces = false
		self.tableView.register(UINib(nibName: "SuggestedSearchCell", bundle: Bundle.main), forCellReuseIdentifier: SuggestedSearchCell.reuseIdentifier)
		self.tableView.register(UINib(nibName: "ContentButtonCell", bundle: Bundle.main), forCellReuseIdentifier: ContentButtonCell.reuseIdentifier)
		self.tableView.register(UINib(nibName: "MapItemsCollectionContainerCell", bundle: Bundle.main), forCellReuseIdentifier: MapItemsCollectionContainerCell.reuseIdentifier)
	}
}

// MARK: Scroll events
extension ResultsTableViewController {
	override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		self.scrollDelegate?.resultsTableViewWillScroll()
	}
}

// MARK: Data Source
extension ResultsTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		if filter == .empty {
			return 2
		}
		else if filter == .suggested {
			return 5
		}
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if filter == .empty {
			if section == 0 {
				return promotedSearchStringItems.count
			}
			else if section == 1 {
				return 1
			}
		}
		else if filter == .suggested {
			if section == 0 {
				return min(autocompleteStringItems.count, 3)
			}
			else if section == 1 {
				return min(artworkItems.count, 3)
			}
			else if section == 2 {
				return min(tourItems.count, 3)
			}
			else if section == 3 {
				return min(exhibitionItems.count, 3)
			}
			else if section == 4 {
				return 1
			}
		}
		return 0
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if filter == .empty {
			if indexPath.section == 0 {
				let cell = tableView.dequeueReusableCell(withIdentifier: SuggestedSearchCell.reuseIdentifier, for: indexPath) as! SuggestedSearchCell
				cell.suggestedSearchLabel.text = promotedSearchStringItems[indexPath.row]
				return cell
			}
			else if indexPath.section == 1 {
				let cell = tableView.dequeueReusableCell(withIdentifier: MapItemsCollectionContainerCell.reuseIdentifier, for: indexPath) as! MapItemsCollectionContainerCell
				cell.innerCollectionView.reloadData()
				return cell
			}
		}
		else if filter == .suggested {
			if indexPath.section == 0 {
				let cell = tableView.dequeueReusableCell(withIdentifier: SuggestedSearchCell.reuseIdentifier, for: indexPath) as! SuggestedSearchCell
				cell.suggestedSearchLabel.text = autocompleteStringItems[indexPath.row]
				return cell
			}
			else if indexPath.section == 1 {
				// artwork cell
				let cell = tableView.dequeueReusableCell(withIdentifier: ContentButtonCell.reuseIdentifier, for: indexPath) as! ContentButtonCell
				let artwork = artworkItems[indexPath.row]
				cell.setContent(imageUrl: artwork.thumbnailUrl, title: artwork.title, subtitle: "Gallery Name")
				return cell
			}
			else if indexPath.section == 2 {
				// tour cell
				let cell = tableView.dequeueReusableCell(withIdentifier: ContentButtonCell.reuseIdentifier, for: indexPath) as! ContentButtonCell
				let tour = tourItems[indexPath.row]
				cell.setContent(imageUrl: tour.imageUrl, title: tour.title, subtitle: "Gallery Name")
				return cell
			}
			else if indexPath.section == 3 {
				// exhibition cell
				let cell = tableView.dequeueReusableCell(withIdentifier: ContentButtonCell.reuseIdentifier, for: indexPath) as! ContentButtonCell
				return cell
			}
			else if indexPath.section == 4 {
				let cell = tableView.dequeueReusableCell(withIdentifier: MapItemsCollectionContainerCell.reuseIdentifier, for: indexPath) as! MapItemsCollectionContainerCell
				cell.innerCollectionView.reloadData()
				return cell
			}
		}
		return UITableViewCell()
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if filter == .empty {
			if section <= 1 {
				let titles = ["Search Content", "On the Map"]
				let titleView = ResultsSectionTitleView(title: titles[section])
				return titleView
			}
		}
		if filter == .suggested {
			if section > 0 && section <= 3 {
				let titles = ["Artworks", "Tours", "Exhibitions"]
				let titleString = titles[section-1]
				let titleView = ContentTitleView(title: titleString)
				titleView.setDarkStyle(true)
				return titleView
			}
			else if section == 4 {
				let titleView = ResultsSectionTitleView(title: "On the Map")
				return titleView
			}
		}
		return nil
	}
}

// MARK: Layout
extension ResultsTableViewController {
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if filter == .suggested {
			if section > 0 && section <= 3 {
				return contentTitleHeight
			}
			else if section == 4 {
				return resultsSectionTitleHeight
			}
			return 0
		}
		return resultsSectionTitleHeight
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if filter == .empty {
			if indexPath.section == 0 {
				return SuggestedSearchCell.cellHeight
			}
			else if indexPath.section == 1 {
				return MapItemsCollectionContainerCell.cellHeight
			}
		}
		else if filter == .suggested {
			if indexPath.section == 0 {
				return SuggestedSearchCell.cellHeight
			}
			else if indexPath.section == 1 {
				return ContentButtonCell.cellHeight
			}
			else if indexPath.section == 2 {
				return ContentButtonCell.cellHeight
			}
			else if indexPath.section == 3 {
				return ContentButtonCell.cellHeight
			}
			else if indexPath.section == 4 {
				return MapItemsCollectionContainerCell.cellHeight
			}
		}
		return ContentButtonCell.cellHeight
	}
}