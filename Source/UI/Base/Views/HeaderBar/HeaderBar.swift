//
//  HeaderBar.swift
//  MyMobileED
//
//  Created by Admin on 4/19/16.
//  Copyright © 2016 Company. All rights reserved.
//

import Foundation
import UIKit

@objc protocol HeaderBarDelegate: class {
    
    @objc optional func headerBar(_ header: HeaderBar, didTapLeftButton left: UIButton)
    @objc optional func headerBar(_ header: HeaderBar, didTapNearToLeft button: UIButton)
    @objc optional func headerBar(_ header: HeaderBar, didTapRightButton right: UIButton)
    @objc optional func headerBar(_ header: HeaderBar, didTapSecureButton secure: UIButton)
}

@IBDesignable class HeaderBar: UIView {
   
    var view: UIView!
    var delegate: HeaderBarDelegate?
    
    @IBOutlet fileprivate weak var topView: UIView?
    @IBOutlet fileprivate weak var leftButton: UIButton?
    @IBOutlet fileprivate weak var nearToLeftButton: UIButton?
    @IBOutlet fileprivate weak var rightButton: UIButton?
    @IBOutlet fileprivate weak var titleLabel: UILabel?
    @IBOutlet fileprivate weak var bottomView: UIView?
    @IBOutlet fileprivate weak var secureButton: UIButton?
    @IBOutlet fileprivate weak var leftLeadingConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        xibSetup()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]        
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "HeaderBar", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }

    @IBInspectable var textTitleLabel: String? {
        get {
            return titleLabel?.text
        }
        set {
            titleLabel?.text = newValue
        }
    }

    @IBInspectable var leadingTitleLabelConstraintConstant: CGFloat {
        get {
            return leftLeadingConstraint.constant
        }
        set {
            leftLeadingConstraint.constant = newValue
        }
    }
    
    @IBInspectable var leftButtonImage: UIImage? {
        get {
            return leftButton?.imageView?.image
        }
        set {
            leftButton?.setImage(newValue, for: UIControlState())
        }
    }
    
    @IBInspectable var leftButtonHide: Bool {
        get {
            return leftButton!.isHidden
        }
        set {
            leftButton?.isHidden = newValue
        }
    }
    
    @IBInspectable var nearToLeftButtonImage: UIImage? {
        get {
            return nearToLeftButton?.imageView?.image
        }
        set {
            nearToLeftButton?.setImage(newValue, for: UIControlState())
        }
    }
    
    @IBInspectable var nearToLeftButtonHide: Bool {
        get {
            return nearToLeftButton!.isHidden
        }
        set {
            nearToLeftButton?.isHidden = newValue
        }
    }
    
    @IBInspectable var rightButtonImage: UIImage? {
        get {
            return rightButton?.imageView?.image
        }
        set {
            rightButton?.setImage(newValue, for: UIControlState())
        }
    }
    
    var rightButtonImageEdgeInsets: UIEdgeInsets {
        get {
            return rightButton!.imageEdgeInsets
        }
        set {
            rightButton?.imageEdgeInsets = newValue
        }
    }
    
    @IBInspectable var rightButtonHide: Bool {
        get {
            return (rightButton?.isHidden)!
        }
        set {
            rightButton?.isHidden = newValue
        }
    }
    
    @IBInspectable var rightButtonEnable: Bool {
        get {
            return rightButton!.isEnabled
        }
        set {
            rightButton?.isEnabled = newValue
        }
    }

    @IBInspectable var rightButtonText: String {
        get {
            return rightButton!.titleLabel!.text!
        }
        set {
            rightButton?.setTitle(newValue, for: .normal)
        }
    }

    @IBInspectable var rightButtonTextColor: UIColor {
        get {
            return rightButton!.titleLabel!.textColor
        }
        set {
            rightButton?.setTitleColor(newValue, for: .normal)
        }
    }
    
    var rightButtonFont: UIFont? {
        get {
            return rightButton!.titleLabel?.font
        }
        set {
            rightButton?.titleLabel?.font = newValue
        }
    }
    
    @IBInspectable var secureButtonImage: UIImage? {
        get {
            return secureButton!.imageView?.image
        }
        set {
            secureButton?.setImage(newValue, for: .normal)
        }
    }
    
    @IBInspectable var secureButtonHide: Bool {
        get {
            return (secureButton?.isHidden)!
        }
        set {
            secureButton?.isHidden = newValue
        }
    }

    @IBInspectable var secureButtonUserInteractionEnabled: Bool {
        get {
            return secureButton!.isUserInteractionEnabled
        }
        set {
            secureButton?.isUserInteractionEnabled = newValue
        }
    }
    
    @IBInspectable var secureButtonText: String {
        get {
            return secureButton!.titleLabel!.text!
        }
        set {
            secureButton?.setTitle(newValue, for: .normal)
        }
    }

    var titleLabelFont: UIFont {
        get {
            return titleLabel!.font
        }
        set {
            titleLabel?.font = newValue
        }
    }
    
    @IBAction func leftButtonTapped(_ sender: UIButton) {
        delegate?.headerBar!(self, didTapLeftButton: sender)
    }
    
    @IBAction func rightButtonTapped(_ sender: UIButton) {
        delegate?.headerBar!(self, didTapRightButton: sender)
    }
    
    @IBAction func secureButtonTapped(_ sender: UIButton) {
        guard let _ = delegate?.headerBar?(self, didTapSecureButton: sender) else { return }
    }
    
    @IBAction func nearToLeftButtonTapped(_ sender: UIButton) {
        guard let _ = delegate?.headerBar?(self, didTapNearToLeft: sender) else { return }
    }
}
