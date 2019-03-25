//
//  ChangePasswordViewController.swift
//  MyMobileED
//
//  Created by Admin on 2/3/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

class ChangePasswordViewController: BaseViewController, UITextFieldDelegate {
    private let TextFieldViewOffset: Int = 20
    
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var reenterNewPasswordTextField: UITextField!
    
    var router: PhotosRouterProtocol?
    var networkManager: AuthorizationNetworkProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad() 
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupViews()
    }
    
    func setupViews() {
        configure(textField: newPasswordTextField)
        configure(textField: reenterNewPasswordTextField)
    }
    
    func configure(textField tField: UITextField) {
        tField.rightView = UIView.init(frame: CGRect(x: 0, y: 0, width: TextFieldViewOffset, height: TextFieldViewOffset))
        tField.leftView = UIView.init(frame: CGRect(x: 0, y: 0, width: TextFieldViewOffset, height: TextFieldViewOffset))
        tField.rightViewMode = .always
        tField.leftViewMode = .always
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.statusBarStyle = .default
    }

    @IBAction func buttonCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonChangePasswordTapped(_ sender: Any) {
        if newPasswordTextField.text!.count < 1 || reenterNewPasswordTextField.text!.count < 1 {
            self.presentAlert(withMessage: "Please fill all the fields.")
            return
        }
        
        if newPasswordTextField.text != reenterNewPasswordTextField.text {
            self.presentAlert(withMessage: "The password fields do not match")
            return
        }
        
        self.newPasswordTextField.isUserInteractionEnabled = false
        self.reenterNewPasswordTextField.isUserInteractionEnabled = false
        self.changePasswordButton.isUserInteractionEnabled = false
        self.networkManager?.changePassword(newPasswordTextField.text!, successBlock: { (response) -> (Void) in
            print("Response = \(response)")
            DispatchQueue.main.async {
                self.changePasswordButton.setTitle("PASSWORD UPDATED!", for: .normal)
                self.changePasswordButton.backgroundColor = BaseColors.lightGreenColor.color()
            }
        }, failureBlock: { (error) -> (Void) in
            self.presentAlert(withMessage: error.message)
            self.newPasswordTextField.isUserInteractionEnabled = true
            self.reenterNewPasswordTextField.isUserInteractionEnabled = true
            self.changePasswordButton.isUserInteractionEnabled = true
            print("Error = \(error.message)")
        })
    }

    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if (newPasswordTextField == textField) {
            reenterNewPasswordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
}
