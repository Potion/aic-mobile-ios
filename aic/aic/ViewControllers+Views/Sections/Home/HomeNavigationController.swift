//
//  HomeSectionNavigationController.swift
//  aic
//
//  Created by Filippo Vanucci on 11/8/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

class HomeNavigationController : SectionNavigationController {
	let homeVC: HomeViewController
	
	override init(section: AICSectionModel) {
		homeVC = HomeViewController(section: section)
		
		super.init(section: section)
		
		self.delegate = self
		
		homeVC.delegate = self
		
		self.pushViewController(homeVC, animated: false)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
}

extension HomeNavigationController : UINavigationControllerDelegate {
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		
	}
	
	func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
		// set SectionNavigationBar as scrollDelegateon homeVC only after it appears for the first time
		if viewController == homeVC && homeVC.delegate == nil {
			homeVC.scrollDelegate = sectionNavigationBar
		}
	}
}

extension HomeNavigationController : HomeViewControllerDelegate {
	func showSeeAllTours() {
		self.sectionNavigationBar.collapse()
		self.sectionNavigationBar.titleLabel.text = "Tours"
		self.sectionNavigationBar.setBackButtonHidden(false)
		
		let seeAllVC = SeeAllViewController()
		seeAllVC.contentItems = AppDataManager.sharedInstance.app.tours
		self.pushViewController(seeAllVC, animated: true)
	}
	
	func showSeeAllExhibitions() {
//		self.sectionNavigationBar.collapse()
//		self.sectionNavigationBar.titleLabel.text = "On View"
	}
	
	func showSeeAllEvents() {
//		self.sectionNavigationBar.collapse()
//		self.sectionNavigationBar.titleLabel.text = "Events"
	}
}
