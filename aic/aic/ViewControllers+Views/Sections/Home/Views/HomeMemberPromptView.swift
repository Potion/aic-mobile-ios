//
//  HomeMemberCardView.swift
//  aic
//
//  Created by Filippo Vanucci on 11/21/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import PureLayout

protocol HomeMemberPromptViewDelegate : class {
	func memberPromptDidSelectAccessMemberCard()
}

class HomeMemberPromptView: BaseView {
	let promptTextView: UITextView = UITextView()
	let accessMemberCardTextView: LinkedTextView = LinkedTextView()
	
	let topMargin: CGFloat = 32.0
	let accessMemberCardTopMargin: CGFloat = 18.0
	let bottomMargin: CGFloat = 32.0
	
	weak var delegate: HomeMemberPromptViewDelegate? = nil
	
	init() {
		super.init(frame:CGRect.zero)
		
		backgroundColor = .aicHomeMemberPromptBackgroundColor
		
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 6
		let promptTextAttrString = NSMutableAttributedString(string: "The Museum is a dynamic place. Let’s Explore!\nIf you’re a member, sign-in for enhanced access.")
		promptTextAttrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, promptTextAttrString.length))
		
		promptTextView.setDefaultsForAICAttributedTextView()
		promptTextView.attributedText = promptTextAttrString
		promptTextView.font = .aicTextFont
		promptTextView.textColor = .aicDarkGrayColor
		promptTextView.textAlignment = .center
		
		// TODO: make link to open your member card
		let accessMemberCardAttrText = NSMutableAttributedString(string: "Access your member card.")
		let accessMemberCardURL = URL(string: String("artic://membercard"))!
		accessMemberCardAttrText.addAttributes([NSAttributedStringKey.link : accessMemberCardURL], range: NSMakeRange(0, accessMemberCardAttrText.string.count))
		
		accessMemberCardTextView.setDefaultsForAICAttributedTextView()
		accessMemberCardTextView.attributedText = accessMemberCardAttrText
		accessMemberCardTextView.textColor = .aicHomeMemberPromptLinkColor
		accessMemberCardTextView.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue : UIColor.aicHomeMemberPromptLinkColor]
		accessMemberCardTextView.textAlignment = NSTextAlignment.center
		accessMemberCardTextView.font = .aicTextFont
		accessMemberCardTextView.delegate = self
		
		self.addSubview(promptTextView)
		self.addSubview(accessMemberCardTextView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func updateConstraints() {
		if didSetupConstraints == false {
			promptTextView.autoPinEdge(.top, to: .top, of: self, withOffset: topMargin)
			promptTextView.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16.0)
			promptTextView.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16.0)
			
			accessMemberCardTextView.autoPinEdge(.top, to: .bottom, of: promptTextView, withOffset: accessMemberCardTopMargin)
			accessMemberCardTextView.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16.0)
			accessMemberCardTextView.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16.0)
			
			self.autoPinEdge(.bottom, to: .bottom, of: accessMemberCardTextView, withOffset: bottomMargin)
			
			didSetupConstraints = true
		}
		
		super.updateConstraints()
	}
}

extension HomeMemberPromptView : UITextViewDelegate {
	func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		// MARK: Link to open Member Card
		if textView == accessMemberCardTextView {
			self.delegate?.memberPromptDidSelectAccessMemberCard()
			return false
		}
		return false
	}
}
