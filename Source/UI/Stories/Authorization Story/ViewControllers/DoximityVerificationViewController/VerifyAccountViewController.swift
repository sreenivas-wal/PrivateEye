//
//  DoximityVerificationViewController.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 1/30/18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit

class VerifyAccountViewController: DoximityViewController {
   
    // MARK: - Actions

    override func viewDidLoad() {
       
    }
    
    @IBAction func continueAsUnverifiedUserTapped(_ sender: Any) {
        router?.showPhotosViewController(fromViewController: self, withAnimation: true)
    }
    
    @IBAction func doximityButtonTapped(_ sender: Any) {
        startDoximityLogin()
    }
    
    @IBAction func verifyWithPETapped(_ sender: Any) {
        router?.showVerificationInfoAlertViewController(fromViewController: self, withDelegate: self, withAnimation: true)
    }
    
}

class PEVerifVC: DoximityViewController {
    override func viewDidLoad() {
        provideVerificationForm()
    }
}
