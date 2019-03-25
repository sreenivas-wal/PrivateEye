//
//  ProfileLoginViewController.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 1/30/18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit

struct ProfileEnterpriseViewModel {
    
    let email: String
    let hostname: Hostname
}

class ProfileLoginViewController: BaseViewController, UITextFieldDelegate {
    
    fileprivate let textFieldViewOffset: Int = 20
    
    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    @IBOutlet fileprivate weak var emailLabel: UILabel!
    @IBOutlet fileprivate weak var hostnameLabel: UILabel!
    @IBOutlet fileprivate weak var passwordTextField: UITextField!
    
    var router: AuthorizationPrivateRoutingProtocol?
    var networkManager: AuthorizationNetworkProtocol?
    var userManager: SessionUserProtocol?

    var viewModel: ProfileEnterpriseViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configure(textField: passwordTextField)
        self.configure(with: self.viewModel)
    }
    
    // MARK: -
    // MARK: Private
    
    fileprivate func configure(textField tField: UITextField) {
        tField.rightView = UIView.init(frame: CGRect(x: 0, y: 0, width: textFieldViewOffset, height: textFieldViewOffset))
        tField.leftView = UIView.init(frame: CGRect(x: 0, y: 0, width: textFieldViewOffset, height: textFieldViewOffset))
        tField.rightViewMode = .always
        tField.leftViewMode = .always
    }
    
    fileprivate func proceedLocalAuthentification() {
        
        let authentificationHelper = AuthentificationHelper()
        authentificationHelper.proceedLocalAuthentification(
            withSuccessHandler: {
                guard let touchIDInfo = self.userManager?.touchIDInfo() else { return }
                
                self.signIn(with: touchIDInfo.email,
                        password: touchIDInfo.password)

            },
               failureHandler: { (error) in
                
                   let alert = UIAlertController.authentificationErrorAlertController()
                   self.present(alert, animated: true, completion: nil)

               })
    }
    
    fileprivate func login(withPassword password: String?) {
        
        guard let validPassword = password else {
            self.presentAlert(withMessage: "Password field can't be empty")
            return
        }

        if validPassword.count < 1 {
            self.presentAlert(withMessage: "Password field can't be empty")
            return
        }
        
        if Validator().isValidEmail(self.viewModel.email) == false { return }
        
        self.signIn(with: self.viewModel.email, password: validPassword)
    }
    
    fileprivate func signIn(with email: String, password: String) {
        
        self.userManager?.updateHostDomain(withHostname: self.viewModel.hostname)

        self.view.isUserInteractionEnabled = false

        networkManager?.signIn(with: email,
                           password: password,
                       successBlock: { (response) -> (Void) in

                           DispatchQueue.main.async {
                                
                               self.view.isUserInteractionEnabled = true
                                
                               guard let requiredUserData = response.object as? SignInDataResult else { return }
                            
                               if let requireDoximityID = requiredUserData.user.doximityID,
                                   requireDoximityID.isEmpty == false {

                                   self.userManager?.saveUserInfo(requiredUserData.user)
                                   self.userManager?.saveTouchIDInfo(for: email, password: password)
                                
                                   if let requiredUserProfile = requiredUserData.profile {
                                       self.userManager?.saveProfile(requiredUserProfile)
                                   }
                                
                                   self.router?.showPhotosViewController(fromViewController: self, withAnimation: true)
                               }
                               else {
                                
                                   let linkViewModel = LinkDoximityControllerViewModel(user: requiredUserData.user,
                                                                                    profile: requiredUserData.profile,
                                                                                   password: password,
                                                                                      email: email)
                                
                                   self.router?.showLinkDoximityViewController(with: linkViewModel,
                                                                 fromViewController: self,
                                                                      withAnimation: true)
                               }
                           }
                       },
                       failureBlock: { (error) -> (Void) in
            
                           DispatchQueue.main.async {
                            
                               self.view.isUserInteractionEnabled = true
                               self.presentAlert(withMessage: "Wrong password.")
                           }
                       })
    }
    
    fileprivate func configure(with viewModel: ProfileEnterpriseViewModel) {
        
        self.emailLabel.text = viewModel.email
        self.hostnameLabel.text = viewModel.hostname.title
    }
    
    override func keyboardWillShow(_ notification: Notification) {
        var userInfo = (notification as NSNotification).userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.scrollView.contentInset = contentInset
        self.scrollView.isScrollEnabled = true
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        self.scrollView.contentInset = UIEdgeInsets.zero
        self.scrollView.isScrollEnabled = false
    }
    
    // MARK: - Actions
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        self.login(withPassword: passwordTextField.text)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.router?.popToRootViewController(withAnimation: true)
    }
    
    @IBAction func forgotPasswordButtonTapped(_ sender: Any) {
        self.router?.showRecoverPasswordViewController(fromViewController: self, withAimation: true)
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
    
    @IBAction func touchIDLoginButtonTapped(_ sender: Any) {
        view.endEditing(true)
        self.proceedLocalAuthentification()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}
