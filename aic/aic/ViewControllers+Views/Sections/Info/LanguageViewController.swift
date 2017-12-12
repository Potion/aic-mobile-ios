//
//  LanguageSettingsViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 12/11/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

class LanguageViewController : UIViewController {
	let pageView: InfoSectionPageView = InfoSectionPageView(title: Common.Info.languageTitle, text: Common.Info.languageText)
	let englishButton: AICButton = AICButton(color: .aicInfoColor, isSmall: false)
	let spanishButton: AICButton = AICButton(color: .aicInfoColor, isSmall: false)
	let chineseButton: AICButton = AICButton(color: .aicInfoColor, isSmall: false)
	
	init() {
		super.init(nibName: nil, bundle: nil)
		
		self.navigationItem.title = "Language"
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = .white
		
		englishButton.setTitle("English", for: .normal)
		englishButton.addTarget(self, action: #selector(languageButtonPressed(button:)), for: .touchUpInside)
		
		spanishButton.setTitle("Español", for: .normal)
		spanishButton.addTarget(self, action: #selector(languageButtonPressed(button:)), for: .touchUpInside)
		
		chineseButton.setTitle("中文", for: .normal)
		chineseButton.addTarget(self, action: #selector(languageButtonPressed(button:)), for: .touchUpInside)
		
		// Add subviews
		self.view.addSubview(pageView)
		self.view.addSubview(englishButton)
		self.view.addSubview(spanishButton)
		self.view.addSubview(chineseButton)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// TODO: check current language and show current selection
		spanishButton.isHighlighted = true
		chineseButton.isHighlighted = true
	}
	
	override func updateViewConstraints() {
		pageView.autoPinEdge(.top, to: .top, of: self.view)
		pageView.autoPinEdge(.leading, to: .leading, of: self.view)
		pageView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		
		englishButton.autoPinEdge(.top, to: .bottom, of: pageView)
		englishButton.autoAlignAxis(.vertical, toSameAxisOf: self.view)
		
		spanishButton.autoPinEdge(.top, to: .bottom, of: englishButton, withOffset: 16)
		spanishButton.autoAlignAxis(.vertical, toSameAxisOf: self.view)
		
		chineseButton.autoPinEdge(.top, to: .bottom, of: spanishButton, withOffset: 16)
		chineseButton.autoAlignAxis(.vertical, toSameAxisOf: self.view)
		
		super.updateViewConstraints()
	}
	
	@objc func languageButtonPressed(button: UIButton) {
		englishButton.isHighlighted = button != englishButton
		spanishButton.isHighlighted = button != spanishButton
		chineseButton.isHighlighted = button != chineseButton
		
	}
}