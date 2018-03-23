//
//  EventContentCell.swift
//  aic
//
//  Created by Filippo Vanucci on 1/25/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Atributika

class EventContentCell : UITableViewCell {
	static let reuseIdentifier = "eventContentCell"
	
	@IBOutlet var eventImageView: AICImageView!
	@IBOutlet weak var buyTicketsButton: AICButton!
	@IBOutlet weak var descriptionTextView: UITextView!
	@IBOutlet weak var transparentOverlayView: UIView!
	@IBOutlet var monthDayLabel: UILabel!
	@IBOutlet var hoursMinutesLabel: UILabel!
	@IBOutlet weak var locationAndDateLabel: UILabel!
	
	@IBOutlet weak var descriptionToImageVerticalSpacing: NSLayoutConstraint!
	let descriptionVerticalSpacingMin: CGFloat = 32
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		selectionStyle = UITableViewCellSelectionStyle.none
		
		self.backgroundColor = .aicDarkGrayColor
		
		eventImageView.contentMode = .scaleAspectFill
		eventImageView.clipsToBounds = true
		transparentOverlayView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
		buyTicketsButton.setIconImage(image: #imageLiteral(resourceName: "buttonTicketIcon"))
		descriptionTextView.setDefaultsForAICAttributedTextView()
		descriptionTextView.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.white, NSAttributedStringKey.underlineStyle.rawValue : NSUnderlineStyle.styleSingle.rawValue]
		locationAndDateLabel.numberOfLines = 2
	}
	
	var eventModel: AICEventModel? = nil {
		didSet {
			guard let eventModel = self.eventModel else {
				return
			}
			
			eventImageView.kf.setImage(with: eventModel.imageUrl, placeholder: nil, options: nil, progressBlock: nil) { (image, error, cache, url) in
				if image != nil {
					self.eventImageView.image = AppDataManager.sharedInstance.getCroppedImageForEvent(image: image!, viewSize: self.eventImageView.frame.size)
				}
			}
			
			let monthDayString = Common.Info.monthDayString(date: eventModel.startDate)
			let hoursMinutesString = Common.Info.hoursMinutesString(date: eventModel.startDate)
			var locationAndDateString = monthDayString
			locationAndDateString += ", "
			locationAndDateString += hoursMinutesString
			locationAndDateString += "\n"
			locationAndDateString += eventModel.locationText
			
			monthDayLabel.text = monthDayString
			hoursMinutesLabel.text = hoursMinutesString
			descriptionTextView.textColor = .white
			locationAndDateLabel.attributedText = getAttributedStringWithLineHeight(text: locationAndDateString, font: .aicCardDateLocationFont, lineHeight: 22)
			
			let emStyle = Style("em").font(.aicCardTextItalicFont)
			let iStyle = Style("i").font(.aicCardTextItalicFont)
			let strongStyle = Style("strong").font(.aicCardTextBoldFont)
			let bStyle = Style("b").font(.aicCardTextBoldFont)
			let allStyle = Style.font(.aicCardTextFont).baselineOffset(22.0 - Float(UIFont.aicTitleFont.pointSize))
			
			let eventDescription = eventModel.longDescription
				.replacingOccurrences(of: "</p>", with: "</p>\n")
				.replacingOccurrences(of: "<li>", with: "<li>\t•\t")
			
			let descriptionAttributedString = eventDescription
				.style(tags: emStyle, iStyle, strongStyle, bStyle)
				.styleAll(allStyle)
				.attributedString
			
			descriptionTextView.attributedText = descriptionAttributedString
			descriptionTextView.textColor = .white
			
			
			if eventModel.eventUrl == nil {
				buyTicketsButton.isEnabled = false
				buyTicketsButton.isHidden = true
				descriptionToImageVerticalSpacing.constant = descriptionVerticalSpacingMin
			}
			else {
				buyTicketsButton.setTitle(eventModel.buttonText, for: .normal)
			}
			
			self.setNeedsLayout()
			self.layoutIfNeeded()
		}
	}
}
