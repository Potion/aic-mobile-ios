/*
 Abstract:
 Main Section controller, contains MapView, UITabBar and Object View.
*/

import UIKit
import MapKit
import Localize_Swift

protocol SectionsViewControllerDelegate : class {
    func sectionsViewControllerDidFinishAnimatingIn()
}

class SectionsViewController : UIViewController {
    weak var delegate:SectionsViewControllerDelegate? = nil
    
    //let locationManager: CLLocationManager = CLLocationManager()
	
	// Object Audio Card
    //let objectVC: ObjectViewController = ObjectViewController();
    let audioPlayerVC: AudioPlayerNavigationController = AudioPlayerNavigationController()
	
	var contentCardVC: ContentCardNavigationController? = nil
	
	// Search Card
	let searchVC: SearchNavigationController = SearchNavigationController()
    
    // TabBar
    var sectionTabBarController: UITabBarController = UITabBarController()
    
    // Sections
    var sectionViewControllers: [SectionNavigationController] = []
    
    var currentViewController: SectionNavigationController
    var previousViewController: SectionNavigationController? = nil
	
	var homeVC: HomeNavigationController = HomeNavigationController(section: Common.Sections[.home]!)
    var audioGuideVC: AudioGuideNavigationController = AudioGuideNavigationController(section: Common.Sections[.audioGuide]!)
	var mapVC: MapNavigationController = MapNavigationController(section: Common.Sections[.map]!)
	var infoVC:InfoNavigationController = InfoNavigationController(section: Common.Sections[.info]!)
    
    // Messages
    fileprivate var requestedTour:AICTourModel? = nil
    fileprivate var leaveCurrentTourMessageView:UIView? = nil

    //fileprivate var enableLocationMessageView:UIView? = nil
    fileprivate var headphonesMessageView: MessageViewController? = nil
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		currentViewController = homeVC
        super.init(nibName: nil, bundle: nil)
    }
	
	required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
    
    override func viewDidLoad() {
        // Set the view controllers for the tab bar
        sectionViewControllers = [
			homeVC,
            audioGuideVC,
            mapVC,
            infoVC
        ]
        
        // Setup and add the tabbar
		sectionTabBarController.view.frame = UIScreen.main.bounds
		sectionTabBarController.tabBar.tintColor = .aicHomeColor
        sectionTabBarController.tabBar.backgroundColor = .aicTabbarColor
        sectionTabBarController.tabBar.barStyle = UIBarStyle.black
		sectionTabBarController.viewControllers = sectionViewControllers
		
        // Setup and add contentView
        //mapVC.view.alpha = 0.0
        
        // Add Views
		sectionTabBarController.willMove(toParentViewController: self)
        view.addSubview(sectionTabBarController.view)
		sectionTabBarController.didMove(toParentViewController: self)
		
//        objectVC.willMove(toParentViewController: sectionTabBarController)
//        sectionTabBarController.view.insertSubview(objectVC.view, belowSubview: sectionTabBarController.tabBar)
//        objectVC.didMove(toParentViewController: sectionTabBarController)
        audioPlayerVC.willMove(toParentViewController: sectionTabBarController)
        sectionTabBarController.view.insertSubview(audioPlayerVC.view, belowSubview: sectionTabBarController.tabBar)
        audioPlayerVC.didMove(toParentViewController: sectionTabBarController)
		
		searchVC.willMove(toParentViewController: self.sectionTabBarController)
		sectionTabBarController.view.insertSubview(searchVC.view, belowSubview: audioPlayerVC.view)
		searchVC.didMove(toParentViewController: self.sectionTabBarController)
		
		// Set delegates
		homeVC.sectionDelegate = self
		mapVC.sectionDelegate = self
		audioGuideVC.sectionDelegate = self
        sectionTabBarController.delegate = self
		searchVC.cardDelegate = self
		searchVC.sectionsVC = self
        audioPlayerVC.cardDelegate = self
		
		// Search Buttons
		for sectionVC in sectionViewControllers {
			sectionVC.sectionNavigationBar.searchButton.addTarget(self, action: #selector(searchButtonPressed(button:)), for: .touchUpInside)
		}
		
		// Language
		NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage), name: NSNotification.Name( LCLLanguageChangeNotification), object: nil)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		updateLanguage()
	}
    
    func setSelectedSection(sectionVC: SectionNavigationController) {
        // If tours tab was pressed when on a tour
        /*if sectionVC == currentViewController && sectionVC == toursVC {
            if toursVC.currentTour != nil {
                showLeaveTourMessage()
                return
            }
        }*/
        
        previousViewController = currentViewController
        currentViewController = sectionVC
        
        // Update colors for this VC
		sectionTabBarController.tabBar.tintColor = sectionVC.color
		audioPlayerVC.setProgressBarColor(color: sectionVC.color)
		
		// Card operations
		if currentViewController != previousViewController {
			if searchVC.currentState == .fullscreen {
				searchVC.hide()
			}
			if let contentCardVC = self.contentCardVC {
				contentCardVC.hide()
			}
		}
        
        // Set the map mode
//        switch sectionVC {
//        //case nearbyVC:
//            //locationManager.delegate = mapVC
//            //mapVC.showAllInformation()
//
//        /*case toursVC:
//            // If we were previously showing a tour,
//            // show it on the map again
//            if let currentTour = toursVC.currentTour {
//                mapVC.showTour(forTour: currentTour, andRestoreState: true)
//                locationManager.delegate = mapVC
//            } else {
//                disableMap(locationManagerDelegate:toursVC)
//            }
//          */
//        default:
//            disableMap(locationManagerDelegate: nil)
//        }
		
        sectionVC.view.setNeedsUpdateConstraints()
    }
    
    /*fileprivate func removeCurrentTour() {
        disableMap(locationManagerDelegate: toursVC)
        toursVC.removeCurrentTour()
        toursVC.reset()
    }*/
    
    func disableMap(locationManagerDelegate:CLLocationManagerDelegate?) {
        //locationManager.delegate = locationManagerDelegate
        //mapVC.showDisabled()
    }
    
	// MARK: Intro animation
	// TODO: remove function but keep deep link to related tour
    func animateInInitialView() {
		sectionTabBarController.view.alpha = 0.0
        homeVC.view.alpha = 0.0
        
        UIView.animate(withDuration: 0.5, delay: 1.0, options: UIViewAnimationOptions.curveEaseOut,
                                   animations:  {
									self.sectionTabBarController.view.alpha = 1.0
                                    self.homeVC.view.alpha = 1.0
            }, completion: { (value:Bool) in
                self.delegate?.sectionsViewControllerDidFinishAnimatingIn()
        })
        Common.DeepLinks.loadedEnoughToLink = true
        (UIApplication.shared.delegate as? AppDelegate)?.triggerDeepLinkIfPresent()
    }
	
	// MARK: Show On Map
    
	func showTourOnMap(tour: AICTourModel, language: Common.Language, stopIndex: Int?) {
        /*if toursVC.currentTour != nil {
            self.requestedTour = tour
            showLeaveTourMessage()
            return
        }*/
		
		if currentViewController != mapVC {
			setSelectedSection(sectionVC: mapVC)
		}
		mapVC.showTour(tour: tour, language: language, stopIndex: stopIndex)
		sectionTabBarController.selectedIndex = 2
		
        // If this is coming from an object view,
        //show the mini player to reveal tour below
//        if objectVC.mode != .hidden {
//            objectVC.showMiniPlayer()
//        }
		
        // Log Analytics
//        AICAnalytics.sendTourStartedFromLinkEvent(forTour: tour)
    }
	
	func showOnMap(artwork: AICSearchedArtworkModel) {
		if currentViewController != mapVC {
			setSelectedSection(sectionVC: mapVC)
		}
		mapVC.showArtwork(artwork: artwork)
		sectionTabBarController.selectedIndex = 2
	}
    
    // MARK: Play Audio
	
	func playObject(object:AICObjectModel, audioGuideID: Int?) {
//        self.objectVC.setContent(forObjectModel: object, audioGuideID: audioGuideID)
//        self.objectVC.showFullscreen()
		
		setSearchButtonEnabled(false)
		
        audioPlayerVC.playArtwork(artwork: object, forAudioGuideID: audioGuideID)
        audioPlayerVC.showFullscreen()
        showHeadphonesMessage()
        
        updateTabBarHeightWithMiniPlayer()
    }
    
    func playAudioGuideObject(object:AICObjectModel, audioGuideID: Int) {
        playObject(object: object, audioGuideID: audioGuideID)
        
        // Log analytics
        AICAnalytics.sendAudioGuideDidShowObjectEvent(forObject: object)
    }
    
    func playMapObject(forObjectModel object:AICObjectModel) {
//        if currentViewController == toursVC {
//            guard let currentTour = toursVC.currentTour else {
//                print("Could not display object because it isn't on currently displayed tour.")
//                return
//            }
//
//            guard let tourStopIndex = currentTour.getIndex(forStopObject: object) else {
//                print("Could not get index for tour object.")
//                return
//            }
//
//            showTourStop(forTourModel: currentTour, atStopIndex: tourStopIndex)
//        } else {
            playObject(object: object, audioGuideID: nil)
//        }
		
        // Log analytics
        AICAnalytics.sendMapDidShowObjectEvent(forObject: object)
    }
    
    fileprivate func playTourOverview(forTourModel tour:AICTourModel) {
//        self.objectVC.setContent(forTourOverviewModel: tour.overview)
//        self.objectVC.showMiniPlayer()
        self.showHeadphonesMessage()
        
        updateTabBarHeightWithMiniPlayer()
        
        // Log analytics
        AICAnalytics.sendTourDidShowOverviewEvent(forTour: tour)
    }
    
    fileprivate func playTourStop(forTourModel tour:AICTourModel, atStopIndex stopIndex:Int) {
//        self.objectVC.setContent(forTour: tour, atStopIndex: stopIndex)
//        self.objectVC.showMiniPlayer()
        self.showHeadphonesMessage()
        
        updateTabBarHeightWithMiniPlayer()
        
        // Log analytics
        AICAnalytics.sendTourDidShowObjectEvent(forObject: tour.stops[stopIndex].object)
    }
    
    // Update bottom margin for tab bar + audio player in case any views need to adjust
    private func updateTabBarHeightWithMiniPlayer() {
//        if Common.Layout.tabBarHeight == Common.Layout.tabBarHeightWithMiniAudioPlayerHeight {
//            Common.Layout.miniAudioPlayerHeight = objectVC.getMiniPlayerHeight()
//        }
    }
	
	// Show/Hide Search Buttons
	
	private func setSearchButtonEnabled(_ enabled: Bool) {
		for sectionVC in sectionViewControllers {
			sectionVC.sectionNavigationBar.searchButton.isEnabled = enabled
			sectionVC.sectionNavigationBar.searchButton.isHidden = !enabled
		}
	}
	
    // MARK: Messages
    
    fileprivate func showLeaveTourMessage() {
		let leaveCurrentTourMessageView = UIView()
//        leaveCurrentTourMessageView.delegate = self
		
        view.addSubview(leaveCurrentTourMessageView)
//        self.leaveCurrentTourMessageView = leaveCurrentTourMessageView
    }
    
    fileprivate func hideLeaveTourMessage() {
        if let leaveCurrentTourMessageView = leaveCurrentTourMessageView {
            leaveCurrentTourMessageView.removeFromSuperview()
//            self.leaveCurrentTourMessageView = nil
        }
    }
    
    fileprivate func showHeadphonesMessage() {
        let defaults = UserDefaults.standard
        let showHeadphonesMessage = defaults.bool(forKey: Common.UserDefaults.showHeadphonesUserDefaultsKey)
        
        if showHeadphonesMessage {
            headphonesMessageView = MessageViewController(message: Common.Messages.useHeadphones)
            headphonesMessageView!.delegate = self
			
            // Modal presentation style
            headphonesMessageView!.definesPresentationContext = true
            headphonesMessageView!.providesPresentationContextTransitionStyle = true
            headphonesMessageView!.modalPresentationStyle = .overFullScreen
            headphonesMessageView!.modalTransitionStyle = .crossDissolve
            
            self.present(headphonesMessageView!, animated: true, completion: nil)
        }
    }
    
    fileprivate func hideHeadphonesMessage() {
        if let messageView = headphonesMessageView {
            // Update user defaults
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: Common.UserDefaults.showHeadphonesUserDefaultsKey)
            defaults.synchronize()
            
            messageView.dismiss(animated: true, completion: nil)
            headphonesMessageView = nil
        }
    }
	
	@objc func searchButtonPressed(button: UIButton) {
		setSearchButtonEnabled(false)
		searchVC.showFullscreen()
	}
	
	// MARK: Language
	@objc func updateLanguage() {
		sectionTabBarController.tabBar.items![0].title = "Home".localized(using: "TabMenu")
		sectionTabBarController.tabBar.items![1].title = "Audio".localized(using: "TabMenu")
		sectionTabBarController.tabBar.items![2].title = "Map".localized(using: "TabMenu")
		sectionTabBarController.tabBar.items![3].title = "Info".localized(using: "TabMenu")
	}
}

// MARK: SectionTabBarController Delegate Methods
extension SectionsViewController : UITabBarControllerDelegate {
	func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
		if let sectionVC = viewController as? SectionNavigationController {
			setSelectedSection(sectionVC: sectionVC)
		}
	}
}

// MARK: Home Delegate

extension SectionsViewController : HomeNavigationControllerDelegate {
	func showMemberCard() {
		setSelectedSection(sectionVC: infoVC)
		infoVC.shouldShowMemberCard = true
		sectionTabBarController.selectedIndex = 3
	}
	
	func showTourCard(tour: AICTourModel) {
		let tourTableVC = TourTableViewController(tour: tour)
		tourTableVC.tourTableDelegate = self
		showContentCard(ContentCardNavigationController(tableVC: tourTableVC))
	}
	
	func showExhibitionCard(exhibition: AICExhibitionModel) {
		let exhibitionTableVC = ExhibitionTableViewController(exhibition: exhibition)
		showContentCard(ContentCardNavigationController(tableVC: exhibitionTableVC))
	}
	
	func showEventCard(event: AICEventModel) {
		let eventTableVC = EventTableViewController(event: event)
		showContentCard(ContentCardNavigationController(tableVC: eventTableVC))
	}
	
	func showContentCard(_ contentCardVC: ContentCardNavigationController) {
		if let cardVC = self.contentCardVC {
			cardVC.view.removeFromSuperview()
		}
		self.contentCardVC = contentCardVC
		contentCardVC.cardDelegate = self
		
		setSearchButtonEnabled(false)
		
		contentCardVC.willMove(toParentViewController: sectionTabBarController)
		sectionTabBarController.view.insertSubview(contentCardVC.view, aboveSubview: searchVC.view)
		contentCardVC.didMove(toParentViewController: sectionTabBarController)
		
		contentCardVC.showFullscreen()
	}
}

// MARK: AudioGuide delegate
extension SectionsViewController : AudioGuideNavigationControllerDelegate {
    func audioGuideDidSelectObject(object: AICObjectModel, audioGuideID: Int) {
        playAudioGuideObject(object: object, audioGuideID: audioGuideID)
    }
}

// NewsTours Delegate methods
extension SectionsViewController : NewsToursSectionViewControllerDelegate {
    func newsToursSectionViewController(_ controller: NewsToursSectionViewController, didCloseReveal reveal: NewsToursRevealView) {
        //mapVC.showDisabled()
    }
}

// Tours Delegate Methods
extension SectionsViewController : ToursSectionViewControllerDelegate {
    func toursSectionDidShowTour(tour: AICTourModel) {
        //locationManager.delegate = mapVC
        //mapVC.showTour(forTour: tour)
        
        // Log Analytics
        AICAnalytics.sendTourDidStartEvent(forTour: tour)
    }
    
    func toursSectionDidFocusOnTourOverview(tour: AICTourModel) {
        //mapVC.showTourOverview(forTourModel: tour)
    }
    
    func toursSectionDidFocusOnTourStop(tour: AICTourModel, stopIndex: Int) {
        //mapVC.highlightTourStop(forTour: tour, atStopIndex: stopIndex)
    }
    
    func toursSectionDidSelectTourOverview(tour:AICTourModel) {
        playTourOverview(forTourModel: tour)
    }
    
    func toursSectionDidSelectTourStop(tour: AICTourModel, stopIndex:Int) {
        playTourStop(forTourModel: tour, atStopIndex:stopIndex)
    }
    
    func toursSectionDidLeaveTour(tour: AICTourModel) {
        // Log analytics
        AICAnalytics.sendTourDidLeaveEvent(forTour: tour)
    }
}

// MARK: Map Delegate Methods
extension SectionsViewController : MapNavigationControllerDelegate {
	func playArtwork(artwork: AICObjectModel) {
		playMapObject(forObjectModel: artwork)
	}
}

// MARK: Message Delegate Methods
extension SectionsViewController : MessageViewControllerDelegate {
    func messageViewActionSelected(messageVC: MessageViewController) {
        if messageVC.view == leaveCurrentTourMessageView {
            hideLeaveTourMessage()
            
            if let requestedTour = self.requestedTour {
                self.requestedTour = nil
//                toursVC.removeCurrentTour()
                //startTour(tour: requestedTour)
            } else {
//                removeCurrentTour()
            }
        }
            
        /*else if messageView == enableLocationMessageView {
            hideEnableLocationMessage()
            //startLocationManager()
        }*/
        
        else if messageVC == headphonesMessageView {
            hideHeadphonesMessage()
        }
        
        else {
            print("Unhandled message view action")
        }
    }
    
    func messageViewCancelSelected(messageVC: MessageViewController) {
        if messageVC.view == leaveCurrentTourMessageView {
            hideLeaveTourMessage()
            requestedTour = nil
        }
        
        /*else if messageView == enableLocationMessageView {
            hideEnableLocationMessage()
        }*/
    }
}

// MARK: Card Delegate
extension SectionsViewController : CardNavigationControllerDelegate {
    // When the Audio Player goes fullscreen hide the TabBar
    func cardDidUpdatePosition(cardVC: CardNavigationController, position: CGPoint) {
        if cardVC == audioPlayerVC {
            let screenHeight = UIScreen.main.bounds.height
            
            var percentageY: CGFloat = position.y / (screenHeight - self.sectionTabBarController.tabBar.frame.height - Common.Layout.miniAudioPlayerHeight)
            percentageY = clamp(val: percentageY, minVal: 0.0, maxVal: 1.0)
            
            // Set the sectionVC tab bar to hide as we show audioPlayerVC
            self.sectionTabBarController.tabBar.frame.origin.y = screenHeight - (sectionTabBarController.tabBar.bounds.height * percentageY)
        }
    }
	
	func cardDidShowMiniplayer(cardVC: CardNavigationController) {
		if cardVC == audioPlayerVC {
			setSearchButtonEnabled(true)
		}
	}
    
	func cardDidHide(cardVC: CardNavigationController) {
		setSearchButtonEnabled(true)
		if cardVC.isKind(of: ContentCardNavigationController.self) {
			cardVC.view.removeFromSuperview()
		}
	}
}

// MARK: TourTableViewControllerDelegate
extension SectionsViewController : TourTableViewControllerDelegate {
	// Pressed "Start Tour" or tour stop in content card
	func tourStartSelected(tour: AICTourModel, language: Common.Language, stopIndex: Int?) {
		if searchVC.currentState == .fullscreen {
			searchVC.hide()
		}
		showTourOnMap(tour: tour, language: language, stopIndex: stopIndex)
	}
}

// MARK: ArtworkTableViewControllerDelegate
extension SectionsViewController : ArtworkTableViewControllerDelegate {
	// Pressed "Start Tour" or tour stop in content card
	func artworkPlayAudioSelected(artwork: AICObjectModel) {
		if searchVC.currentState == .fullscreen {
			searchVC.hide()
		}
		playArtwork(artwork: artwork)
	}
	
	func artworkShowOnMapSelected(artwork: AICSearchedArtworkModel) {
		// TODO: temporarily disabling this
//		if searchVC.currentState == .fullscreen {
//			searchVC.hide()
//		}
//		showOnMap(artwork: artwork)
	}
}

