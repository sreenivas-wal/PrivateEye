//
//  ReceoverPasswordViewController.swift
//  MyMobileED
//
//  Created by Admin on 1/27/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

class RecoverPasswordViewController: BaseViewController {

    private let testEmail = "jacob.embree+test02@stlouisintegration.com"
    private let TextFieldViewOffset: Int = 20
    
    var networkManager: AuthorizationNetworkProtocol?
    var router: AuthorizationRouterProtocol?
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var recoverButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure(textField: emailTextField)
    }
    
    @IBAction func buttonProceedTapped(_ sender: UIButton) {
        let email = emailTextField.text
        
        if email!.count < 1 {
            self.presentAlert(withMessage: "Email can't be empty")
            return
        }
        
        recoverButton.isEnabled = false
        emailTextField.isEnabled = false
        
        networkManager?.resetPassword(with: email!, successBlock: { (response) -> (Void) in
            print("Response = \(response)")
            self.changeButtonState()
        }, failureBlock: { (error) -> (Void) in
            self.recoverButton.isEnabled = true
            self.emailTextField.isEnabled = true
            self.presentAlert(withMessage: "Wrong email.")
            print("Error = \(error)")
        })
    }

    @IBAction func buttonCloseTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func changeButtonState() {
        self.recoverButton.setTitle("RECOVERY EMAIL SENT!", for: .normal)
        self.recoverButton.backgroundColor = BaseColors.lightGreenColor.color()
    }
    
    private func configure(textField tField: UITextField) {
        tField.rightView = UIView.init(frame: CGRect(x: 0, y: 0, width: TextFieldViewOffset, height: TextFieldViewOffset))
        tField.leftView = UIView.init(frame: CGRect(x: 0, y: 0, width: TextFieldViewOffset, height: TextFieldViewOffset))
        tField.rightViewMode = .always
        tField.leftViewMode = .always
    }

    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
}
