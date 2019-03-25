//
//  UIAlertController+Biometrics.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 8/31/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

extension UIAlertController {

    class func authentificationErrorAlertController() -> UIAlertController {
        let alert = UIAlertController(title: "You haven't set up Touch ID sign in on this device.",
                                      message: "Go to the settings on your device and add a least one fingerprint, then sign in to the PrivateEyeHC app and turn on fingerprint sign in from \"Setting > TouchID\"",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "ОК", style: .cancel, handler: nil))
        
        return alert
    }
    
    class func signUpToDoximityAlertController(withLoginHandler loginHandler: @escaping (() -> ())) -> UIAlertController {
        let alert = UIAlertController(title: "Link to Doximity", message: "You must sign up or login to your Doximity account to use this feature.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Log in to share", style: .default, handler: { (action) in
            loginHandler()
        }))
        alert.addAction(UIAlertAction(title: "Sign Up", style: .default, handler: { (action) in
            let url = URL.signUpDoximityUrl()
            
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        return alert
    }
    
}
