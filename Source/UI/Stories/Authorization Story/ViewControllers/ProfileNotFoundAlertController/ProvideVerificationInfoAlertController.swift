//
//  ProvideVerificationInfoAlertController.swift
//  MyMobileED_Fabric
//
//  Created by Manisha Reddy Narayan on 24/08/18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit
protocol ProvideVerificationInfoDelegate: class {

    func provideVerificationInfoAlertController(_ sender: ProvideVerificationInfoAlertController)

}


class ProvideVerificationInfoAlertController: UIViewController {
    
    var delegate:ProvideVerificationInfoDelegate?
    @IBAction func backButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func continueButtonClicked(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.provideVerificationInfoAlertController(self)
        }
    }
}
