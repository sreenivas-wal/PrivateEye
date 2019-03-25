//
//  PurchaseCaseView.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 8/22/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class PurchaseCaseView: PopUpView, TTTAttributedLabelDelegate {

    private let casePurchaseURL = "www.mymobilehc.com/case"
    
    var okayButtonTapCallback: (() -> Void)?
    var openURLTapCallback: ((_ url: URL) -> Void)?
    
    @IBOutlet weak var textLabel: TTTAttributedLabel!
    
    class func viewHeight() -> CGFloat {
        return 230.0
    }
    
    override func height() -> CGFloat {
        return PurchaseCaseView.viewHeight()
    }
    
    override func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "PurchaseCaseView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureLink()
    }
    
    // MARK: - Actions
    
    @IBAction func okayButtonTapped(_ sender: Any) {
        if let validCallback = okayButtonTapCallback {
            validCallback()
        }
    }
    
    // MARK: - Private
    
    private func configureLink() {
        let str = NSString(string: textLabel.text as! String)
        
        let clickableRange = str.range(of: casePurchaseURL)
        let linkAttributes = [
            NSForegroundColorAttributeName : BaseColors.lightBlue.color(),
            NSUnderlineStyleAttributeName: NSNumber(value: true)
        ] as [String : Any]
        
        textLabel.linkAttributes = linkAttributes
        textLabel.activeLinkAttributes = linkAttributes
        textLabel.addLink(to: URL(string: "https://www.mymobilehc.com/case"), with: clickableRange)
    }
    
    // MARK: - TTTAttributedLabelDelegate
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        if let validOpenUrlCallback = openURLTapCallback {
            validOpenUrlCallback(url)
        }
    }
}
