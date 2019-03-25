//
//  BluetoothPopUpView.swift
//  MyMobileED
//
//  Created by Admin on 1/20/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

class BluetoothPopUpView: PopUpView {
    
    var buttonDoneTapCallback: (() -> (Void))?
    
    class func viewHeight() -> CGFloat {
        return 170.0
    }
    
    override func height() -> CGFloat {
        return BluetoothPopUpView.viewHeight()
    }
    
    override func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "BluetoothPopUpView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    @IBAction func buttonDoneTapped(_ sender: Any) {
        if let validCallback = buttonDoneTapCallback {
            validCallback()
        }
    }
    
}
