//
//  NoResultView.swift
//  MyMobileED
//
//  Created by Admin on 2/9/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

@IBDesignable class NoResultView: UIView {
    
    @IBOutlet weak var noResultImageView: UIImageView!
    @IBOutlet var view: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBInspectable var descriptionText: String? {
        get {
            return descriptionLabel.text
        }
        set {
            descriptionLabel.text = newValue
        }
    }
    
    @IBInspectable var image: UIImage? {
        get {
            return noResultImageView.image
        }
        set {
            noResultImageView.image = newValue
        }
    }
    
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
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "NoResultView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
}
