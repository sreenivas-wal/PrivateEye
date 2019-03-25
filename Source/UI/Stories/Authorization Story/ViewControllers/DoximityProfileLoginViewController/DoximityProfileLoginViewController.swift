//
//  DoximityProfileLoginViewController.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 1/30/18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit

struct ProfileFreemiumViewModel {
    
    let email: String
    let hostname: Hostname
}

class DoximityProfileLoginViewController: DoximityViewController {

    var viewModel: ProfileFreemiumViewModel!
    
    @IBOutlet fileprivate weak var emailLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configure(with: self.viewModel)
    }
    
    // MARK: -
    // MARK: Actions
    @IBAction func cancelButtonTapped(_ sender: Any) {
        router?.popToRootViewController(withAnimation: true)
    }
    
    @IBAction func doximityButtonTapped(_ sender: Any) {
        self.startDoximityLogin()
    }
    
    @IBAction func supportButtonTapped(_ sender: Any) {
        
        guard let requiredDomainLink = self.viewModel.hostname.domainLink,
              let requiredProtocolName = self.viewModel.hostname.protocolName
        else { return }
        
        let hostLink = String(format: "%@://%@", requiredProtocolName, requiredDomainLink)
        let supportUrl = URL.supportUrl(fromHostLink: hostLink)

        if UIApplication.shared.canOpenURL(supportUrl) {
            UIApplication.shared.openURL(supportUrl)
        }
    }
    
    // MARK: -
    // MARK: Private
    fileprivate func configure(with viewModel: ProfileFreemiumViewModel) {
        
        self.emailLabel.text = viewModel.email
    }
}
