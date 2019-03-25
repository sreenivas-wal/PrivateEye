//
//  LogInViewController.swift
//  MyMobileED
//
//  Created by Admin on 1/16/17.
//
//

import UIKit
import TTTAttributedLabel
import InputMask

class LogInViewController: BaseViewController, UITextFieldDelegate, TTTAttributedLabelDelegate {
    
    private let textFieldViewOffset: Int = 20
    private let maxPhoneNumberLength = 10
    private let prefixUSACode = "+1"
    private let phoneNumberInputMask = "([000]) [000]-[0000]"
    
    private let termsOfUseText: String = "Terms of Use"
    private let termsOfUseURL: String = "http://mymobileerhealthcare.stlouisintegration.com/terms"
    
    weak var router: AuthorizationPrivateRoutingProtocol?
    var networkManager: AuthorizationNetworkProtocol?
    var validator: ValidatorProtocol?
    let authorizationModel = AuthorizationModel()

    
    @IBOutlet weak var fieldsView: UIView!
    @IBOutlet weak var termsLabel: TTTAttributedLabel!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loginButton: UIButton!
    private var maskedDelegate: MaskedTextFieldDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTermsLabel()
        setupMaskedDelegate()
        addDoneButtonOnKeyboardToMobileTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loginButtonInteraction(isInteractable: true)
        setupViews()
    }
    
    // MARK: Actions

    @IBAction func buttonLogInTapped(_ sender: Any) {
        loginButtonInteraction(isInteractable: false)
        login(with: emailTextField.text, mobileNumber: mobileNumberTextField.text)
    }
    

    // MARK: - Private
    
    private func setupViews() {
        UIApplication.shared.statusBarStyle = .default
        scrollView.isScrollEnabled = false
        
        configure(textField: mobileNumberTextField)
        configure(textField: emailTextField)
    }
    
    private func configure(textField tField: UITextField) {
        tField.rightView = UIView.init(frame: CGRect(x: 0, y: 0, width: textFieldViewOffset, height: textFieldViewOffset))
        tField.leftView = UIView.init(frame: CGRect(x: 0, y: 0, width: textFieldViewOffset, height: textFieldViewOffset))
        tField.rightViewMode = .always
        tField.leftViewMode = .always
    }

    private func setupMaskedDelegate() {
        maskedDelegate = MaskedTextFieldDelegate(format: phoneNumberInputMask)
        mobileNumberTextField.delegate = self.maskedDelegate
    }
    
    private func login(with email: String?, mobileNumber: String?) {
        guard let validEmail = email else {
            self.presentAlert(withMessage: "Email field can't be empty.")
            loginButtonInteraction(isInteractable: true)
            return
        }
        
        guard let validMobileNumber = mobileNumber?.removedFormatString() else {
            self.presentAlert(withMessage: "Mobile number field can't be empty.")
            loginButtonInteraction(isInteractable: true)
            return
        }

        if validMobileNumber.count != self.maxPhoneNumberLength {
            self.presentAlert(withMessage: "Invalid phone number. Please enter a 10 digit US number (xxx) xxx-xxxx.")
            loginButtonInteraction(isInteractable: true)
            return
        }
        
        if !validator!.isValidEmail(validEmail) {
            self.presentAlert(withMessage: "Please enter valid email.")
            loginButtonInteraction(isInteractable: true)
            return
        }
        
        let phoneNumber = String(format: "%@%@", prefixUSACode, validMobileNumber)
        mobileNumberVerification(with: phoneNumber, email: validEmail, validPhoneNumber: validMobileNumber)
        
    }
    
    func mobileNumberVerification(with phoneNumber: String, email: String, validPhoneNumber: String){
        let defaults = UserDefaults.standard
        let storedPhoneNumber = defaults.string(forKey: "mobileNumber")
        let verifToken = defaults.string(forKey: "verificationToken")
        let code = defaults.string(forKey: "code")
        
        if storedPhoneNumber != nil && storedPhoneNumber == validPhoneNumber && verifToken != nil && code != nil {
            let authorizationModel = AuthorizationModel()
            authorizationModel.email = email
            authorizationModel.mobileNumber = validPhoneNumber
            authorizationModel.verificationToken = verifToken
            
            networkManager?.verifyMobileNumber(with: authorizationModel, code: code!, successBlock: { (response) -> (Void) in

                guard let requiredAccount = response.object as? UserProfileRecognizer else { return }
                DispatchQueue.main.async {
                    
                    switch requiredAccount.accountType {
                    case .newUser:
                        print("Verify Number - New User")
                            self.router?.showSignUpPEViewController(fromViewController: self, forAuthorizationModel: authorizationModel, withAnimation: true)
                        
                    case .profileNotFoundforEmail:
                        print("Verify Number - profileNotFound")
                        self.router?.showProfileNotFoundAlertController(fromViewController: self, forEmail: true, forEmailWithPhone: false, withAnimation: true)
                        self.loginButtonInteraction(isInteractable: true)
                    case .profileNotFoundforNumber:
                        self.router?.showProfileNotFoundAlertController(fromViewController: self, forEmail: false, forEmailWithPhone: false, withAnimation: true)
                        self.loginButtonInteraction(isInteractable: true)

                    case .enterpriseProfile:
                        print("Verify Number - enterpriseProfile")
                        let allHostnames = requiredAccount.hostnames
                        guard let requiredAnyHostname = allHostnames.first,
                            let requiredEmail = authorizationModel.email
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
                            let requiredEmail = authorizationModel.email
                            else { return }
                        
                        let freemiumViewModel = ProfileFreemiumViewModel(email: requiredEmail, hostname: requiredAnyHostname)
                        self.router?.showDoximityProfileLoginViewController(with: freemiumViewModel, fromViewController: self, withAnimation: true)
                    
                    case .profileNotFoundforEmailAndNumber:
                        self.router?.showProfileNotFoundAlertController(fromViewController: self, forEmail: false, forEmailWithPhone: true, withAnimation: true)
                        self.loginButtonInteraction(isInteractable: true)
                    }
                }
            }, failureBlock: { (error) -> (Void) in
                DispatchQueue.main.async {
                    self.requestForAuthorization(phoneNumber: phoneNumber, validEmail: email, validMobileNumber: validPhoneNumber)
                }
            })
        } else {
            requestForAuthorization(phoneNumber: phoneNumber, validEmail: email, validMobileNumber: validPhoneNumber)
        }
    }
    
    
    func requestForAuthorization(phoneNumber:String,validEmail:String,validMobileNumber:String) {

        networkManager?.requestAuthorization(withPhoneNumber: phoneNumber, successBlock: { (response) -> (Void) in
            self.authorizationModel.email = validEmail
            self.authorizationModel.mobileNumber = validMobileNumber
            self.authorizationModel.verificationToken = response.object as? String
            
            DispatchQueue.main.async {
                self.loginButtonInteraction(isInteractable: true)
                self.router?.showMobileVerificationViewController(fromViewController: self, forAuthorizationModel: self.authorizationModel, withAnimation: true)
            }
        }, failureBlock: { (response) -> (Void) in
            self.loginButtonInteraction(isInteractable: true)
            if response.code == 406 {
            DispatchQueue.main.async { self.presentAlert(withMessage: (response.json.array![0]).string!) }
            } else {
                DispatchQueue.main.async { self.presentAlert(withMessage: response.message) }
            }
        })
    }
    
    private func configureTermsLabel() {
        let str = NSString(string: termsLabel.text as! String)
        let clickableRange = str.range(of: termsOfUseText)
        let linkAttributes = [
            NSForegroundColorAttributeName : BaseColors.lightBlue.color(),
            NSUnderlineStyleAttributeName: NSNumber(value: false),
            ] as [String : Any]
        
        termsLabel.linkAttributes = linkAttributes
        termsLabel.activeLinkAttributes = linkAttributes
        termsLabel.addLink(to: URL(string: termsOfUseURL), with: clickableRange)
    }

    override func keyboardWillShow(_ notification: Notification) {
        var userInfo = (notification as NSNotification).userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.scrollView.contentInset = contentInset
        scrollView.isScrollEnabled = true
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.isScrollEnabled = false
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
        
        mobileNumberTextField.inputAccessoryView = doneToolbar
    }
    
    func loginButtonInteraction(isInteractable:Bool) {
        loginButton.isUserInteractionEnabled = isInteractable

    }
    
    func doneButtonAction() {
        mobileNumberTextField.resignFirstResponder()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (emailTextField == textField) {
            mobileNumberTextField.becomeFirstResponder()
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
