//
//  SetPasswordViewController.swift
//  MyMobileED_Fabric
//
//  Created by Manisha Reddy Narayan on 26/07/18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit

class SetPasswordViewController: UIViewController {
    var router: AuthorizationPrivateRoutingProtocol?

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func supportButtonTapped(_ sender: Any) {
        let hostname = Hostname.defaultHostname()
        let supportUrl = URL.supportUrl(fromHostLink: hostname.fullHostDomainLink())
        
        if UIApplication.shared.canOpenURL(supportUrl) {
            UIApplication.shared.openURL(supportUrl)
        }
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        router?.showPhotosViewController(fromViewController: self, withAnimation: true)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        router?.popToRootViewController(withAnimation: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
