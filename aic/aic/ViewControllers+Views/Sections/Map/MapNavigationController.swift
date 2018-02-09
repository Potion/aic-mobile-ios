//
//  MapNavigationController.swift
//  aic
//
//  Created by Filippo Vanucci on 1/25/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit
import CoreLocation
import Localize_Swift

protocol MapNavigationControllerDelegate : class {
	func playArtwork(artwork: AICObjectModel)
}

class MapNavigationController : SectionNavigationController {
	let mapVC: MapViewController = MapViewController()
	
	let tourStopsVC: TourStopsNavigationController = TourStopsNavigationController()
	
	let locationManager: CLLocationManager = CLLocationManager()
	fileprivate var enableLocationMessageView: MessageViewController? = nil
	
	weak var sectionDelegate: MapNavigationControllerDelegate? = nil
	
	override init(section: AICSectionModel) {
		super.init(section: section)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Setup delegates
		mapVC.delegate = self
		tourStopsVC.cardDelegate = self
		locationManager.delegate = self.mapVC
		
		// Add root viewcontroller
		self.pushViewController(mapVC, animated: false)
		
		// Add Tour Stops Card
		tourStopsVC.willMove(toParentViewController: self)
		self.view.addSubview(tourStopsVC.view)
		tourStopsVC.didMove(toParentViewController: self)
		
		// Initial map state
//		self.mapVC.showAllInformation()
		
		// Location
		startLocationManager()
		
		self.view.setNeedsLayout()
		self.view.layoutIfNeeded()
		self.view.layoutSubviews()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		mapVC.setViewableArea(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - Common.Layout.tabBarHeight))
		
		self.view.setNeedsLayout()
		self.view.layoutIfNeeded()
		self.view.layoutSubviews()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.view.setNeedsLayout()
		self.view.layoutIfNeeded()
		self.view.layoutSubviews()
	}
	
	// MARK: Location Manager
	fileprivate func startLocationManager() {
		//See if we need to prompt first
		let defaults = UserDefaults.standard
		let showEnableLocationMessageValue = defaults.bool(forKey: Common.UserDefaults.showEnableLocationUserDefaultsKey)
		
		// If we do show it
        if showEnableLocationMessageValue {
			showEnableLocationMessage()
        } else {  // Otherwise try to start the location manager
            // Init location manager
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
	}
	
	fileprivate func showEnableLocationMessage() {
        enableLocationMessageView = MessageViewController(message: Common.Messages.enableLocation)
		enableLocationMessageView!.delegate = self
        
        // Modal presentation style
        enableLocationMessageView!.definesPresentationContext = true
        enableLocationMessageView!.providesPresentationContextTransitionStyle = true
        enableLocationMessageView!.modalPresentationStyle = .overFullScreen
        enableLocationMessageView!.modalTransitionStyle = .crossDissolve
        
		self.present(enableLocationMessageView!, animated: true, completion: nil)
	}
	
	fileprivate func hideEnableLocationMessage() {
		if let messageView = enableLocationMessageView {
			// Update user defaults
			let defaults = UserDefaults.standard
			defaults.set(false, forKey: Common.UserDefaults.showEnableLocationUserDefaultsKey)
			defaults.synchronize()
			
			messageView.dismiss(animated: true, completion: nil)
			enableLocationMessageView = nil
		}
	}
	
	// MARK: Show
	
	func showTour(tour: AICTourModel, language: Common.Language, stopIndex: Int?) {
		if sectionNavigationBar.currentState != .hidden {
			sectionNavigationBar.hide()
		}
		
		mapVC.showTour(forTour: tour)
		tourStopsVC.setTourContent(tour: tour, language: language)
		tourStopsVC.setCurrentStop(stopIndex: stopIndex)
		tourStopsVC.showMinimized()
		
		self.view.setNeedsLayout()
		self.view.layoutIfNeeded()
		self.view.layoutSubviews()
	}
}

// MARK: Message Delegate Methods
extension MapNavigationController : MessageViewControllerDelegate {
	func messageViewActionSelected(messageVC: MessageViewController) {
		if messageVC == enableLocationMessageView {
			hideEnableLocationMessage()
			startLocationManager()
		}
	}
	
	func messageViewCancelSelected(messageVC: MessageViewController) {
		if messageVC == enableLocationMessageView {
			hideEnableLocationMessage()
		}
	}
}

// MARK: Map Delegate Methods
extension MapNavigationController : MapViewControllerDelegate {
	func mapWasPressed() {
		sectionNavigationBar.hide()
	}
	
	func mapDidPressArtworkPlayButton(artwork: AICObjectModel) {
		self.sectionDelegate?.playArtwork(artwork: artwork)
	}
	
	func mapDidSelectTourStop(artwork: AICObjectModel) {
		//showTourStop(forStopObjectModel: stopObject)
	}
}

extension MapNavigationController : CardNavigationControllerDelegate {
	// update the view area of the map as the card slides
	func cardDidUpdatePosition(cardVC: CardNavigationController, position: CGPoint) {
		self.mapVC.setViewableArea(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: position.y)))
	}
	
	func cardDidHide(cardVC: CardNavigationController) {
		if cardVC == tourStopsVC {
			mapVC.showAllInformation()
		}
	}
}



