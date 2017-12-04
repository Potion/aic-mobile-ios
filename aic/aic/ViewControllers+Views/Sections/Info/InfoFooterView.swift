//
//  InfoFooterView.swift
//  aic
//
//  Created by Filippo Vanucci on 11/21/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import PureLayout

class InfoFooterView: BaseView {
	let bloombergCreditsImageView = UIImageView()
	let potionCreditsTextView = LinkedTextView()
	
	let bloomberCreditsTopMargin: CGFloat = 72
	let potionCreditsTopMargin: CGFloat = 48
	let bottomMargin: CGFloat = 48
	
	init() {
		super.init(frame:CGRect.zero)
		
		backgroundColor = .aicInfoColor
		
		bloombergCreditsImageView.image = #imageLiteral(resourceName: "bloombergLogo")
		
		let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?
		let version = nsObject as! String

		let versionPlusPotionLink = "Version \(version) \(Common.Info.creditsPotion)"
		let potionCreditsAttrString = NSMutableAttributedString(string: versionPlusPotionLink)
		let potionUrl = URL(string: Common.Info.potionURL)!
		potionCreditsAttrString.addAttributes([NSAttributedStringKey.link : potionUrl], range: NSMakeRange(0, potionCreditsAttrString.string.count))
		
		potionCreditsTextView.attributedText = potionCreditsAttrString
		potionCreditsTextView.font = .aicPotionCreditsFont
		potionCreditsTextView.setDefaultsForAICAttributedTextView()
		potionCreditsTextView.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue : UIColor.white]
		potionCreditsTextView.delegate = self

		addSubview(bloombergCreditsImageView)
		addSubview(potionCreditsTextView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func updateConstraints() {
		if didSetupConstraints == false {
			bloombergCreditsImageView.autoPinEdge(.top, to: .top, of: self, withOffset: bloomberCreditsTopMargin)
			bloombergCreditsImageView.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16)
			
			potionCreditsTextView.autoPinEdge(.top, to: .bottom, of: bloombergCreditsImageView, withOffset: potionCreditsTopMargin)
			potionCreditsTextView.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16)
			potionCreditsTextView.autoPinEdge(.trailing, to: .trailing, of: self)
			
			self.autoSetDimension(.height, toSize: 250) //autoPinEdge(.bottom, to: .bottom, of: potionCreditsTextView, withOffset: bottomMargin)
			
			didSetupConstraints = true
		}
		
		super.updateConstraints()
	}
}

// Observe links for passing analytics
extension InfoFooterView  : UITextViewDelegate {
	func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
		// Log Analytics
		
		return true
	}
}