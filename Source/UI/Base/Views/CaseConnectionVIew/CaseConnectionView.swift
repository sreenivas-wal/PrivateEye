//
//  CaseConnectionView.swift
//  MyMobileED
//
//  Created by Admin on 2/3/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

enum ConnectionViewState {
    case noCaseConnection
    case unsecureConnection
}

class CaseConnectionView: PopUpView {
    
    var cancelButtonTapCallback: (() -> (Void))?
    var connectButtonTapCallback: (() -> (Void))?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    class func noConnectionHeight() -> CGFloat {
        return 175.0
    }
    
    class func unsecureConnectionHeight() -> CGFloat {
        return 195.0
    }
    
    func setupConnectionViewState(state: ConnectionViewState) {
        switch state {
        case .noCaseConnection:
            setupNoConnectedState()
            break
        case .unsecureConnection:
            setupUnsecureConnectionState()
            break
        }
    }
    
    private func setupNoConnectedState() {
        titleLabel.text = "WARNING"
        descriptionLabel.text = "Your case is not connected to the device"
    }
    
    private func setupUnsecureConnectionState() {
        titleLabel.text = "UNSECURE CONNECTION"
        descriptionLabel.text = "Phone detected out of case, please return phone to case"
    }
    
    override func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CaseConnectionView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    @IBAction func buttonCancelTapped(_ sender: Any) {
        if let validCancelCallback = cancelButtonTapCallback {
            validCancelCallback()
        }
    }
    
    @IBAction func buttonConnectTapped(_ sender: Any) {
        if let validConnectCallback = connectButtonTapCallback {
            validConnectCallback()
        }
    }
}
