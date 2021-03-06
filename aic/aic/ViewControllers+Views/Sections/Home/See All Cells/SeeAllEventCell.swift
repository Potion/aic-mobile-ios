//
//  SeeAllEventCell.swift
//  aic
//
//  Created by Filippo Vanucci on 12/12/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

/// SeeAllEventCell
///
/// UICollectionViewCell for list of all Events
class SeeAllEventCell : UICollectionViewCell {
	static let reuseIdentifier = "seeAllEventCell"
	
	@IBOutlet var eventImageView: AICImageView!
	@IBOutlet var eventTitleLabel: UILabel!
	@IBOutlet var dividerLine: UIView!
	@IBOutlet var shortDescriptionTextView: UITextView!
	@IBOutlet var monthDayLabel: UILabel!
	@IBOutlet var hoursMinutesLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		eventImageView.contentMode = .scaleAspectFill
		eventImageView.clipsToBounds = true
		monthDayLabel.font = .aicSeeAllInfoFont
		monthDayLabel.textColor = .aicMediumGrayColor
		hoursMinutesLabel.font = .aicSeeAllInfoFont
		hoursMinutesLabel.textColor = .aicMediumGrayColor
		eventTitleLabel.font = .aicSeeAllTitleFont
		eventTitleLabel.textColor = .aicDarkGrayColor
		eventTitleLabel.numberOfLines = 2
		eventTitleLabel.lineBreakMode = .byTruncatingTail
		dividerLine.backgroundColor = .aicDividerLineColor
		shortDescriptionTextView.font = .aicTextFont
		shortDescriptionTextView.textColor = .aicDarkGrayColor
		shortDescriptionTextView.textContainerInset.left = -4
		shortDescriptionTextView.textContainer.lineBreakMode = .byTruncatingTail
	}
	
	var eventModel: AICEventModel? = nil {
		didSet {
			guard let eventModel = self.eventModel else {
				return
			}
			
			// set up UI
			eventImageView.kf.setImage(with: eventModel.imageUrl, placeholder: nil, options: nil, progressBlock: nil) { (image, error, cache, url) in
				if image != nil {
					self.eventImageView.image = AppDataManager.sharedInstance.getCroppedImageForEvent(image: image!, viewSize: self.eventImageView.frame.size)
				}
			}
			eventTitleLabel.text = eventModel.title
			shortDescriptionTextView.text = eventModel.shortDescription
			monthDayLabel.text = Common.Info.monthDayString(date: eventModel.startDate)
			hoursMinutesLabel.text = Common.Info.hoursMinutesString(date: eventModel.startDate)
			
			// Accessibility
			self.isAccessibilityElement = true
			self.accessibilityLabel = "Event"
			var accessValue = eventTitleLabel.text!
			accessValue += ", "
			accessValue += monthDayLabel.text!
			accessValue += ", "
			accessValue += hoursMinutesLabel.text!
			accessValue += ", "
			accessValue += shortDescriptionTextView.text!
			self.accessibilityValue = accessValue
			self.accessibilityTraits = UIAccessibilityTraitButton
		}
	}
}
