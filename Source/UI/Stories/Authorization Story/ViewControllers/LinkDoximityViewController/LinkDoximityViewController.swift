//
//  LinkDoximityViewController.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 1/30/18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit

struct LinkDoximityControllerViewModel {
    
    var user: User?
    var profile: Profile?
    var password: String
    var email: String
}

class LinkDoximityViewController: DoximityViewController {
    
    var viewModel: LinkDoximityControllerViewModel!
    
    @IBAction func skipButtonTapped(_ sender: Any) {
        
        guard let requiredUser = self.viewModel.user else { return }
        
        self.userManager.saveUserInfo(requiredUser)
        self.userManager.saveTouchIDInfo(for: self.viewModel.email, password: self.viewModel.password)

        if let requiredUserProfile = self.viewModel.profile {
            self.userManager.saveProfile(requiredUserProfile)
        }
        
        router?.showPhotosViewController(fromViewController: self, withAnimation: true)
    }
    
    @IBAction func doximityButtonTapped(_ sender: Any) {
        self.startDoximityLogin()
    }
}
