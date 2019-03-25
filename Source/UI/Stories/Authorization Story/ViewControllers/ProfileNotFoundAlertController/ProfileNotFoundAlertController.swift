//
//  ProfileNotFoundAlertController.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 1/31/18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit

class ProfileNotFoundAlertController: UIViewController {

    var router: AuthorizationPrivateRoutingProtocol?
    
    @IBOutlet weak var alertHeadingLabel: UILabel!
    @IBOutlet weak var alertMessageLabel: UILabel!
    var forEmail:Bool?
    var forEmailWithNumber:Bool?
    override func viewDidLoad() {
        super.viewDidLoad()
        if !forEmail! && !forEmailWithNumber! {
            alertHeadingLabel.text = "Profile Not Found for Entered Number"
            alertMessageLabel.text = "Though we recognize your email, we could not find a profile for the entered mobile number. Please check your number and try again. If you believe a mistake has been made please contact support."
        } else if forEmailWithNumber! {
            alertHeadingLabel.text = "Profile Not Found"
            alertMessageLabel.text = "We have recognised your phone number and email but are associated/linked to two different accounts. Please check your email, phone number and try again, or contact Support by tapping below."
        }
    }
    
    @IBAction func suportButtonTapped(_ sender: Any) {
        let hostname = Hostname.defaultHostname()
        let supportUrl = URL.supportUrl(fromHostLink: hostname.fullHostDomainLink())
        
        if UIApplication.shared.canOpenURL(supportUrl) {
            UIApplication.shared.openURL(supportUrl)
        }
    }
    
    @IBAction func okayButtonTapped(_ sender: Any) {
        router?.dismissToLoginViewController(withAnimation: true)
    }
}
