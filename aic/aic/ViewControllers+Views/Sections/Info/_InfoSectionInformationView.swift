/*
 Abstract:
 Museum location, tickets, etc
 */

import UIKit

class InfoSectionInformationView: BaseView {
    let contentMargins = UIEdgeInsetsMake(25, 25, 25, 25)
    
    let sectionMarginTop = 25
    let sectionContentMarginTop = 15
    
    let contentView = UIView()
    
    let infoView = UIView()
    let infoContentViewHolder = UIView()
    let infoContentView = UIView()
    let infoCreditsView = UIView()
    
    let titleLabel = UILabel()
    let museumHoursTextView = UITextView()
    let locationLabel = UILabel()
    let locationTextView = LinkedTextView()
    let getTicketsTextView = LinkedTextView()
    
    let bloombergCreditsImageView = UIImageView()
    let potionCreditsTextView = LinkedTextView()
    
    init() {
        super.init(frame:CGRect.zero)
        
        infoContentViewHolder.backgroundColor = .white
        
        titleLabel.text = AppDataManager.sharedInstance.app.museumInfo.title
        titleLabel.textColor = .black
        titleLabel.font = .aicTitleFont
		
		museumHoursTextView.frame = UIScreen.main.bounds.insetBy(dx: contentMargins.left + contentMargins.right, dy: 0)
		museumHoursTextView.text = AppDataManager.sharedInstance.app.museumInfo.museumHours
		museumHoursTextView.textColor = .black
		museumHoursTextView.font = .aicTextFont
		museumHoursTextView.setDefaultsForAICAttributedTextView()
		
        locationLabel.text = "Location"
        locationLabel.textColor = .black
        locationLabel.font = .aicTitleFont
        
        locationTextView.text = Common.Info.museumInformationAddress + "\n\n" + Common.Info.museumInformationPhoneNumber
        locationTextView.font = .aicTextFont
        locationTextView.dataDetectorTypes = [.address, .phoneNumber]
        locationTextView.setDefaultsForAICAttributedTextView()
        
        let ticketsAttrString = NSMutableAttributedString(string: Common.Info.museumInformationGetTicketsTitle)
        let ticketsURL = URL(string: Common.Info.museumInformationGetTicketsURL)!
        ticketsAttrString.addAttributes([NSAttributedStringKey.link : ticketsURL.absoluteString], range: NSMakeRange(0, ticketsAttrString.string.count))
		
        getTicketsTextView.attributedText = ticketsAttrString
        getTicketsTextView.font = .aicTitleFont
        getTicketsTextView.setDefaultsForAICAttributedTextView()
        getTicketsTextView.delegate = self
        
        bloombergCreditsImageView.image = #imageLiteral(resourceName: "bloombergLogo")
        
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?
        let version = nsObject as! String
        
        let versionPlusPotionLink = "Version \(version) \(Common.Info.creditsPotion)"
        let potionCreditsAttrString = NSMutableAttributedString(string: versionPlusPotionLink)
        let potionUrl = URL(string: Common.Info.potionURL)!
        potionCreditsAttrString.addAttributes([NSAttributedStringKey.link : potionUrl], range: NSMakeRange(0, potionCreditsAttrString.string.count))
        
        
        potionCreditsTextView.attributedText = potionCreditsAttrString
        potionCreditsTextView.font = .aicTextFont
        potionCreditsTextView.setDefaultsForAICAttributedTextView()
        potionCreditsTextView.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue : UIColor.white]
		potionCreditsTextView.delegate = self
        
        // Add Subviews
        infoContentView.addSubview(titleLabel)
        infoContentView.addSubview(museumHoursTextView)
        infoContentView.addSubview(locationLabel)
        infoContentView.addSubview(locationTextView)
        infoContentView.addSubview(getTicketsTextView)
        
        infoCreditsView.addSubview(bloombergCreditsImageView)
        infoCreditsView.addSubview(potionCreditsTextView)
        
        infoContentViewHolder.addSubview(infoContentView)
        
        infoView.addSubview(infoContentViewHolder)
        infoView.addSubview(infoCreditsView)
        
        addSubview(infoView)
        addSubview(contentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
			
			infoView.snp.makeConstraints({ (make) -> Void in
                make.edges.equalTo(infoView.superview!).priority(Common.Layout.Priority.required.rawValue)
            })
            
            infoContentViewHolder.snp.makeConstraints({ (make) -> Void in
                make.top.left.right.equalTo(infoContentViewHolder.superview!).priority(Common.Layout.Priority.high.rawValue)
            })
            
            infoContentView.snp.makeConstraints({ (make) -> Void in
                make.top.equalTo(infoContentView.superview!).inset(contentMargins)
                make.left.right.bottom.equalTo(infoContentView.superview!).inset(contentMargins).priority(Common.Layout.Priority.high.rawValue)
            })
            
            titleLabel.snp.makeConstraints({ (make) -> Void in
                make.top.left.right.equalTo(titleLabel.superview!)
            })
			
			let museumHoursSize = museumHoursTextView.sizeThatFits(CGSize(width: museumHoursTextView.frame.width, height: CGFloat.greatestFiniteMagnitude))
			museumHoursTextView.snp.makeConstraints({ (make) -> Void in
                make.top.equalTo(titleLabel.snp.bottom).offset(sectionContentMarginTop)
				make.left.equalTo(museumHoursTextView.superview!)
				make.width.equalTo(museumHoursTextView.frame.width)
				make.height.equalTo(museumHoursSize.height)
            })
            
            locationLabel.snp.makeConstraints({ (make) -> Void in
                make.top.equalTo(museumHoursTextView.snp.bottom).offset(sectionMarginTop)
                make.left.right.equalTo(locationLabel.superview!)
            })
            
            locationTextView.snp.makeConstraints({ (make) -> Void in
                make.top.equalTo(locationLabel.snp.bottom).offset(sectionContentMarginTop)
                make.left.right.equalTo(locationTextView.superview!)
            })
            
            getTicketsTextView.snp.makeConstraints({ (make) -> Void in
                make.top.equalTo(locationTextView.snp.bottom).offset(sectionMarginTop)
                make.right.left.equalTo(getTicketsTextView.superview!)
                make.bottom.equalTo(getTicketsTextView.superview!).inset(contentMargins.bottom)
            })
            
            infoCreditsView.snp.makeConstraints({ (make) -> Void in
                make.top.equalTo(infoContentViewHolder.snp.bottom).offset(sectionContentMarginTop)
                make.left.right.equalTo(infoCreditsView.superview!).inset(contentMargins)
                make.bottom.equalTo(infoCreditsView.superview!)
            })
            
            bloombergCreditsImageView.snp.makeConstraints({ (make) -> Void in
                make.top.equalTo(bloombergCreditsImageView.superview!)
                make.left.equalTo(bloombergCreditsImageView.superview!)
                make.size.equalTo(bloombergCreditsImageView.image!.size)
            })
            
            potionCreditsTextView.snp.makeConstraints({ (make) -> Void in
                make.top.equalTo(bloombergCreditsImageView.snp.bottom).offset(sectionMarginTop)
                make.left.right.equalTo(potionCreditsTextView.superview!)
                make.bottom.equalTo(bloombergCreditsImageView.superview!).inset(contentMargins)
            })
            
            didSetupConstraints = true
        }
        
        super.updateConstraints()
        
    }
    
}

// Observe links for passing analytics
extension InfoSectionInformationView  : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        // Log Analytics
        AICAnalytics.infoGetTicketsPressedEvent()
        
        return true
    }
}