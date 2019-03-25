//
//  SignUpPEViewController.swift
//  MyMobileED_Fabric
//
//  Created by Manisha Reddy Narayan on 17/07/18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class SignUpPEViewController:BaseViewController,UITextFieldDelegate,TTTAttributedLabelDelegate{
    
    private let textFieldViewOffset: Int = 20
    var user: User?
    var profile: Profile?
    var router: AuthorizationPrivateRoutingProtocol?
    var userManager:SessionUserProtocol?
    var networkManager: AuthorizationNetworkProtocol?
    var validator: ValidatorProtocol?
    var authorizationModel: AuthorizationModel?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var confirmEmailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    @IBOutlet weak var passwordEyeButton: UIButton!
    @IBOutlet weak var confirmPasswordEyeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        addDoneButtonOnKeyboardToMobileTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupViews()
    }
    
    private func setupViews() {
        UIApplication.shared.statusBarStyle = .default
        scrollView.isScrollEnabled = true
        
        configure(textField: fullNameTextField)
        configure(textField: confirmEmailTextField)
        configure(textField: passwordTextField)
        configure(textField: confirmPasswordTextField)
    }
    
    private func configure(textField tField: UITextField) {
        tField.rightView = UIView.init(frame: CGRect(x: 0, y: 0, width: textFieldViewOffset, height: textFieldViewOffset))
        tField.leftView = UIView.init(frame: CGRect(x: 0, y: 0, width: textFieldViewOffset, height: textFieldViewOffset))
        tField.rightViewMode = .always
        tField.leftViewMode = .always
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        validateAndSignup(with: fullNameTextField.text, email: confirmEmailTextField.text, password: passwordTextField.text, authorizationModel: authorizationModel!)
    }
    
    @IBAction func supportButtonTapped(_ sender: Any) {
        let hostname = Hostname.defaultHostname()
        let supportUrl = URL.supportUrl(fromHostLink: hostname.fullHostDomainLink())
        if UIApplication.shared.canOpenURL(supportUrl) {
            UIApplication.shared.openURL(supportUrl)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        router?.popToRootViewController(withAnimation: true)
    }
    
    override func keyboardWillShow(_ notification: Notification) {
        var keyboardFrame: CGRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.scrollView.contentInset = contentInset
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = UIEdgeInsets.zero
    }
    
    private func addDoneButtonOnKeyboardToMobileTextField() {
        let doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        confirmPasswordTextField.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        confirmPasswordTextField.resignFirstResponder()
    }
    @IBAction func togglePassword(_ sender: Any) {
        togglePasswordVisibility(eyeButton: passwordEyeButton, textFeild: passwordTextField)
    }
    @IBAction func toggleConfirmPassword(_ sender: Any){
        togglePasswordVisibility(eyeButton: confirmPasswordEyeButton, textFeild: confirmPasswordTextField)
    }
    
    
    func togglePasswordVisibility(eyeButton:UIButton,textFeild:UITextField) {
        let buttonTitle = (eyeButton.currentImage?.isEqual(UIImage(named: "closedEye")))! ? UIImage(named:"openEye") : UIImage(named:"closedEye")
        eyeButton.setImage(buttonTitle, for: .normal)
        textFeild.isSecureTextEntry = !textFeild.isSecureTextEntry
        if let textRange = textFeild.textRange(from: textFeild.beginningOfDocument, to: textFeild.endOfDocument) {
            textFeild.replace(textRange, withText: textFeild.text!)
        }
    }
    
    private func validateAndSignup(with name: String?, email: String?, password: String?, authorizationModel: AuthorizationModel?) {
        
        if email == nil || (email?.count)! <= 0 {
            self.presentAlert(withMessage: "Email field can't be empty.")
            return
        }
        let validEmail = email
        
        if name == nil || (name?.count)! <= 0{
            self.presentAlert(withMessage: "Name field can't be empty.")
            return
        }
        let validName = name
        
        if password == nil || (password?.count)! <= 0{
            self.presentAlert(withMessage: "Password field can't be empty.")
            return
        }
        let validPassword = password
        
        if confirmPasswordTextField.text == nil || (confirmPasswordTextField.text?.count)! <= 0{
            self.presentAlert(withMessage: "Confirm password field can't be empty.")
            return
        }
        let validConfirmPassword = confirmPasswordTextField.text
        
        if validPassword != validConfirmPassword {
            self.presentAlert(withMessage: "Confirm password do not match with the password.")
            return
        }
        
        if !validator!.isValidEmail(validEmail!) {
            self.presentAlert(withMessage: "Please enter valid email.")
            return
        }
        
        if !(authorizationModel?.email?.localizedCaseInsensitiveContains(validEmail!))! {
            self.presentAlert(withMessage: "Confirm email does not match with the email you entered earlier.")
            return
        }
        
        signUp(with: validName!, email: validEmail!, password: validPassword!, authorizationModel: authorizationModel!)
    }
    
    private func signUp(with name: String, email: String, password: String, authorizationModel: AuthorizationModel){
        UserDefaults.standard.set(true, forKey: "IsSign")
        let sv = UIViewController.displaySpinner(onView: self.view)
        networkManager?.signUp(with: name, password: password, authorizationModel: authorizationModel,successBlock: { (response) -> (Void) in
            print(response)
            DispatchQueue.main.async {
                //TODO
                guard let requiredUserData = response.object as? SignInDataResult else { return }
                self.userManager?.saveUserInfo(requiredUserData.user)
                self.userManager?.saveProfile(requiredUserData.profile!)
                self.router?.showVerifyAccountViewController(fromViewController: self, forAuthorizationModel: self.authorizationModel!, withAnimation: true)
                UIViewController.removeSpinner(spinner: sv)
                
            }
        }, failureBlock: { (error) -> (Void) in
            let errorMessage = (error.json["form_errors"]["name"]).string
            let message = (errorMessage?.html2Attributed)?.string
            if error.code != 200 {
                self.presentAlert(withMessage: message!)
            } else {
                DispatchQueue.main.async { self.presentAlert(withMessage: error.message) }
            }
            UIViewController.removeSpinner(spinner: sv)
        })
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (confirmEmailTextField == textField) {
            fullNameTextField.becomeFirstResponder()
        } else if (fullNameTextField == textField) {
            passwordTextField.becomeFirstResponder()
        } else if (passwordTextField == textField) {
            confirmPasswordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    // MARK: - TTTAttributedLabelDelegate
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }
}

extension String {
    var html2Attributed: NSAttributedString? {
        do {
            guard let data = data(using: String.Encoding.utf8) else {
                return nil
            }
            return try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error: ", error)
            return nil
        }
    }
}



