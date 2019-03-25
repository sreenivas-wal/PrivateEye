//
//  MobileVerificationViewController.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 1/31/18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit

class MobileVerificationViewController: BaseViewController, UITextFieldDelegate {

    private let validationCodeLenght: Int = 6
    private let profileNotFoundCode: Int = 404
    private let animationDuration: Double = 0.3
    private let defaultViewHeight: CGFloat = 265.0
    private let viewWithValidationHeight: CGFloat = 312.0
    private let validationViewHeight: CGFloat = 47.0
    weak var router: AuthorizationPrivateRoutingProtocol?
    var networkManager: AuthorizationNetworkProtocol?
    var authorizationModel: AuthorizationModel!
    var mobileNumbers:[String]? = []
    @IBOutlet var codeTextFieldsCollection: [UITextField]!
    @IBOutlet weak var alertViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var validationViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultViewState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        codeTextFieldsCollection.first?.becomeFirstResponder()
    }
    
    // MARK: - Private
    
    private func setupValidation() {
        alertViewHeightConstraint.constant = viewWithValidationHeight
        validationViewHeightConstraint.constant = validationViewHeight
    }
    
    private func setupDefaultViewState() {
        alertViewHeightConstraint.constant = defaultViewHeight
        validationViewHeightConstraint.constant = 0
    }
    
    private func verificationCode() -> String {
        var code = ""
        codeTextFieldsCollection.forEach { (textField) in
            guard let text = textField.text else { return }
            code.append(text)
        }
        return code
    }

    override func keyboardWillShow(_ notification: Notification) {
        var keyboardFrame: CGRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.view.frame.origin.y = -(keyboardFrame.height / 2)
            self.view.setNeedsLayout()
        })
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.view.frame.origin.y = 0
            self.view.setNeedsLayout()
        })
    }
    
    private func nextTextField(fromCurrentTextField textField: UITextField) {
        guard let index = codeTextFieldsCollection.index(of: textField) else { return }
        
        if index == codeTextFieldsCollection.count - 1 {
            codeTextFieldsCollection.last?.resignFirstResponder()
        } else {
            for indexOrTextField in index...codeTextFieldsCollection.count - 2 {
                let nextTextField = codeTextFieldsCollection[indexOrTextField + 1]
                
                if nextTextField.text!.count == 0 {
                    nextTextField.becomeFirstResponder()
                    return
                }
            }

        }
    }
    
    private func previousTextField(fromCurrentTextField textField: UITextField) {
        guard let index = codeTextFieldsCollection.index(of: textField) else { return }
        
        if index == 0 {
            codeTextFieldsCollection.first?.resignFirstResponder()
        } else {
            codeTextFieldsCollection[index - 1].becomeFirstResponder()
        }
    }
    
    private func showViewWithoutValidation() {
        view.setNeedsLayout()
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.setupDefaultViewState()
            self.view.layoutIfNeeded()
        })
    }
    
    private func showValidationView() {
        view.setNeedsLayout()
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.setupValidation()
            self.view.layoutIfNeeded()
        })
    }

    // MARK: - Actions
    
    @IBAction func resendButtonTapped(_ sender: Any) {
        guard let phoneNumber = authorizationModel.mobileNumber else { return }
        networkManager?.requestAuthorization(withPhoneNumber: phoneNumber, successBlock: { [unowned self] (response) -> (Void) in
            self.authorizationModel.verificationToken = response.object as? String
        }, failureBlock: { (response) -> (Void) in
            DispatchQueue.main.async { self.presentAlert(withMessage: response.message)}
        })
    }
    
    @IBAction func verifyButtonTapped(_ sender: Any) {
        showViewWithoutValidation()

        let code = verificationCode()

        if code.count != validationCodeLenght {
            showValidationView()
            return
        }

        networkManager?.verifyMobileNumber(with: authorizationModel, code: code, successBlock: { (response) -> (Void) in
            UserDefaults().set(code, forKey: "code")

            guard let requiredAccount = response.object as? UserProfileRecognizer else { return }
            DispatchQueue.main.async {
                
                let defaults = UserDefaults.standard
                defaults.set( self.authorizationModel.email, forKey: "email")
                defaults.set(self.authorizationModel.mobileNumber, forKey: "mobileNumber")
                defaults.set(self.authorizationModel.verificationToken, forKey: "verificationToken")
                defaults.set(code, forKey: "code")
                defaults.synchronize()
                
                switch requiredAccount.accountType {
                case .newUser:
                    print("Verify Number - New User")
                    self.dismiss(animated: true, completion: nil)
                    
                    self.router?.showSignUpPEViewController(fromViewController: self, forAuthorizationModel: self.authorizationModel!, withAnimation: true)                    
                case .profileNotFoundforEmail:
                    print("Verify Number - profileNotFound")
                    self.router?.showProfileNotFoundAlertController(fromViewController: self, forEmail: true, forEmailWithPhone: false, withAnimation: true)
                case .profileNotFoundforNumber:
                    self.router?.showProfileNotFoundAlertController(fromViewController: self, forEmail: false, forEmailWithPhone: false, withAnimation: true)

                case .enterpriseProfile:
                    print("Verify Number - enterpriseProfile")
                    self.dismiss(animated: true, completion: nil)
                    let allHostnames = requiredAccount.hostnames
                    
                    guard let requiredAnyHostname = allHostnames.first,
                          let requiredEmail = self.authorizationModel.email
                    else { return }
                    
                    let enterpriseViewModel = ProfileEnterpriseViewModel(email: requiredEmail,
                                                                      hostname: requiredAnyHostname)
                    
                    self.router?.showProfileLoginViewController(with: enterpriseViewModel,
                                                  fromViewController: self,
                                                       withAnimation: true)
                    
                case .freemiumProfile:
                    print("Verify Number - freemiumProfile")
                    let allHostnames = requiredAccount.phoneHostNames + requiredAccount.emailHostNames
                    
                    guard let requiredAnyHostname = allHostnames.first,
                          let requiredEmail = self.authorizationModel.email
                    else { return }
                    
                    let freemiumViewModel = ProfileFreemiumViewModel(email: requiredEmail, hostname: requiredAnyHostname)
                    self.router?.showDoximityProfileLoginViewController(with: freemiumViewModel, fromViewController: self, withAnimation: true)
                case .profileNotFoundforEmailAndNumber:
                    self.router?.showProfileNotFoundAlertController(fromViewController: self, forEmail: false, forEmailWithPhone: true, withAnimation: true)
                }
            }
        }, failureBlock: { (error) -> (Void) in
             DispatchQueue.main.async { self.showValidationView() }
        })
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - UITextFieldDelegate

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldString = textField.text!

        if string.count == 0 {
            textField.text = ""
            
            if textFieldString.count == 0 {
                previousTextField(fromCurrentTextField: textField)
            }
            
            return true
        }
        if textFieldString.count + string.count == 1 {
            textField.text = textFieldString + string
            nextTextField(fromCurrentTextField: textField)
        }
        return false
        
    }
}
