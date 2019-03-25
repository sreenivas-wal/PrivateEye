//
//  AlertsManager.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 9/26/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import InputMask

class AlertsManager: NSObject, AlertsManagerProtocol, MaskedTextFieldDelegateListener {

    private let phoneNumberInputMask = "([000]) [000]-[0000]"
    
    private var inputAction: UIAlertAction?
    private var inputTextField: UITextField?
    private var maskedDelegate: MaskedTextFieldDelegate!
    
    var validator: ValidatorProtocol?
    
    init(validator: ValidatorProtocol?) {
        super.init()
        
        self.validator = validator
    }
    
    // MARK: - AlertsManagerProtocol
    // MARK: Common
    
    func showAlert(forViewController viewController: UIViewController, withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction)
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func showErrorAlert(forViewController viewController: UIViewController, withMessage message: String) {
        showAlert(forViewController: viewController, withTitle: "Error", message: message)
    }
    
    func showAlertWithTextField(forViewController viewController: UIViewController,
                                with title: String,
                                message: String,
                                textFieldPlaceholder: String,
                                actionHandler: @escaping ((_ text: String) -> ())) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = textFieldPlaceholder
            textField.addTarget(self, action: #selector(self.textFieldValueChanged(_:)), for: .editingChanged)
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        let actionOK = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            guard let textField = alertController.textFields?.first else { return }
            
            actionHandler(textField.text ?? "")
        })
        alertController.addAction(actionOK)
        
        actionOK.isEnabled = false
        inputAction = actionOK
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: Doximity
    
    func showDoximityVerificationAlertController(forViewController viewController: UIViewController, withOkayCallback okayCallback: @escaping () -> (Void)) {
        let doximityAlert = UIAlertController(title: "Verify your doximity account",
                                              message: "Please complete the doximity verification process before linking your account to PrivateEye.",
                                              preferredStyle: .alert)
        doximityAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
            okayCallback()
        }))
        
        viewController.present(doximityAlert, animated: true, completion: nil)
    }
    
    func showUnVerifiedAlertController(forViewController viewController: UIViewController, withOkayCallback okayCallback: @escaping () -> (Void),withOpenCallback openCallback: @escaping () -> (Void)) {
        let unverifiedAlert = UIAlertController(title: "Verify to access all features",
                                              message: "To access all sharing features, please verify you are a clinician by linking your Doximity account or providing details through our verification page. You can find a link in your welcome email or verify now.",
                                              preferredStyle: .alert)
        unverifiedAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            okayCallback()
        }))
        unverifiedAlert.addAction(UIAlertAction(title: "Verify Now", style: .default, handler: { (action) in
            openCallback()
        }))
        
        viewController.present(unverifiedAlert, animated: true, completion: nil)
    }
    
    func showInReviewAlertController(forViewController viewController: UIViewController, withOkayCallback okayCallback: @escaping () -> (Void)) {
        let inReviewAlert = UIAlertController(title: "Your verification info is in review",message: "Thanks for submitting your verification info. One of our administrators will review your account and verify your credentials or contact you for further details. Once you are verified you’ll have access to all sharing features.",preferredStyle: .alert)
        inReviewAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
            okayCallback()
        }))
        viewController.present(inReviewAlert, animated: true, completion: nil)
    }
    func showUnSavedChangesAlertController(forViewController viewController: UIViewController, withYesCallback yesCallback: @escaping () -> (Void), withNoCallback noCallback: @escaping () -> (Void)) {
        let unsavedChangesAlert = UIAlertController(title: "Alert",
                                              message: "You have unsaved changes on the page. Are you sure you want to leave?",
                                              preferredStyle: .alert)
        unsavedChangesAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            yesCallback()
        }))
        unsavedChangesAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
           noCallback()
        }))
        
        viewController.present(unsavedChangesAlert, animated: true, completion: nil)
    }
    // MARK: Groups
    
    func showAddMembersAlertController(forViewController viewController: UIViewController,
                                       withUserSelectionCallback userSelectionCallback: @escaping () -> (Void),
                                       doximitySelectionCallback: @escaping () -> (Void),
                                       emailSelectionCallback: @escaping () -> (Void),
                                       textSelectionCallback: @escaping () -> (Void)) {
        let addMembersAlert = UIAlertController(title: nil, message: "Add group members from ...", preferredStyle: .actionSheet)
        addMembersAlert.addAction(UIAlertAction(title: "My Institution", style: .default, handler: { (action) in
            userSelectionCallback()
        }))
        addMembersAlert.addAction(UIAlertAction(title: "My Doximity Network", style: .default, handler: { (action) in
            doximitySelectionCallback()
        }))
        addMembersAlert.addAction(UIAlertAction(title: "Email", style: .default, handler: { (action) in
            emailSelectionCallback()
        }))
        addMembersAlert.addAction(UIAlertAction(title: "SMS", style: .default, handler: { (action) in
            textSelectionCallback()
        }))
        addMembersAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        viewController.present(addMembersAlert, animated: true, completion: nil)
    }
    
    func showSuccessMembersAddedAlertController(forViewController viewController: UIViewController, withSuccessHandler successHandler: @escaping (() -> ())) {
        let alertController = UIAlertController(title: "Group members added!", message: "Would you like to add more group members?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            successHandler()
        }))
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func showSuccessSharedContentAlertController(forViewController viewController: UIViewController) {
        let message = String(format: "Your content has been shared with the selected group.")
        showSuccessSharedAlertController(forViewController: viewController, withMessage: message)
    }
    
    // MARK: Sharing
    
    func showShareAlertController(forViewController viewController: UIViewController,
                                  withShareToUserCallback shareToUserCallback: @escaping () -> (Void),
                                  shareToDoximityCallback: @escaping () -> (Void),
                                  shareByEmailCallback: @escaping () -> (Void),
                                  shareByTextCallback: @escaping () -> (Void),
                                  shareToGroupCallback: @escaping () -> (Void)) {
        let shareMenuAlert = UIAlertController(title: nil, message: "Share to ...", preferredStyle: .actionSheet)
        shareMenuAlert.addAction(UIAlertAction(title: "User in My Institution", style: .default, handler: { (action) in
            shareToUserCallback()
        }))
        shareMenuAlert.addAction(UIAlertAction(title: "User in My Doximity Network", style: .default, handler: { (action) in
            shareToDoximityCallback()
        }))
        shareMenuAlert.addAction(UIAlertAction(title: "Email", style: .default, handler: { (action) in
            shareByEmailCallback()
        }))
        shareMenuAlert.addAction(UIAlertAction(title: "SMS", style: .default, handler: { (action) in
            shareByTextCallback()
        }))
        shareMenuAlert.addAction(UIAlertAction(title: "Group", style: .default, handler: { (action) in
            shareToGroupCallback()
        }))
        shareMenuAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        viewController.present(shareMenuAlert, animated: true, completion: nil)
    }

    func showSuccessSharedPhotoAlertController(forViewController viewController: UIViewController, isMultiple: Bool) {
        let message = String(format: "The user%@ will receive the shared image in their “Shared With Me” folder.", isMultiple ? "s" : "")
        showSuccessSharedAlertController(forViewController: viewController, withMessage: message)
    }
    
    func showSuccessSharedFolderAlertController(forViewController viewController: UIViewController, isMultiple: Bool) {
        showSuccessSharedPhotoAlertController(forViewController: viewController, isMultiple: isMultiple)
    }
    
    func showSuccessSharedByEmailAlertController(forViewController viewController: UIViewController, isMultiple: Bool) {
        let message = String(format: "The user%@ will receive an email with a link to access the shared content.", isMultiple ? "s" : "")
        showSuccessSharedAlertController(forViewController: viewController, withMessage: message)
    }
    
    func showSuccessSharedByTextAlertController(forViewController viewController: UIViewController, isMultiple: Bool) {
        let message = String(format: "The user%@ will receive a text message with a link to access the shared content.", isMultiple ? "s" : "")
        showSuccessSharedAlertController(forViewController: viewController, withMessage: message)
    }
    
    // MARK: Invites
    
    func showInviteAlertController(forViewController viewController: UIViewController,
                                   withMessage message: String,
                                   withDoximityInviteHandler doximityInviteHandler: @escaping (() -> (Void)),
                                   withEmailInviteHandler emailInviteHandler: @escaping (() -> (Void)),
                                   textInviteHandler: @escaping (() -> (Void))) {
        let inviteAlert = UIAlertController(title: message, message: nil, preferredStyle: .actionSheet)
        inviteAlert.addAction(UIAlertAction(title: "Invite via Doximity", style: .default, handler: { (action) in
            doximityInviteHandler()
        }))
        inviteAlert.addAction(UIAlertAction(title: "Email", style: .default, handler: { (action) in
            emailInviteHandler()
        }))
        inviteAlert.addAction(UIAlertAction(title: "Text", style: .default, handler: { (action) in
            textInviteHandler()
        }))
        inviteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        viewController.present(inviteAlert, animated: true, completion: nil)
    }
    
    func showInviteByEmailAlertController(forViewController viewController: UIViewController, textValue: String,
                                          withSuccessHandler successHandler: @escaping ((_ email: String) -> (Void))) {
        showAlertControllerWithEmailField(forViewController: viewController,
                                          withTitle: "Invite user by email:",
                                          message: nil,
                                          buttonTitle: "Send", textValue: textValue,
                                          withShareCallback: successHandler)
    }
    
    func showInviteByTextAlertController(forViewController viewController: UIViewController, textValue: String,
                                         withSuccessHandler successHandler: @escaping ((_ text: String) -> (Void))) {
        showAlertControllerWithMobileNumberField(forViewController: viewController,
                                                 withTitle: "Invite user by text:",
                                                 message: nil,
                                                 buttonTitle: "Send", textValue: textValue,
                                                 withShareCallback: successHandler)
    }
    
    func showSuccessInviteAlertController(forViewController viewController: UIViewController) {
        let successInviteAlert = UIAlertController(title: "Invitation Sent!",
                                                             message: "This user will receive an invitation to download and join the PrivateEyeHC app. Thanks!",
                                                             preferredStyle: .alert)
        successInviteAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        viewController.present(successInviteAlert, animated: true, completion: nil)
    }

    // MARK: - Photo

    func showConnectionAlertController(forViewController viewController: UIViewController,
                                       textValue: String,
                                       withHandler actionHandler: @escaping ((UIAlertAction) -> (Void))) {
        let alertController = UIAlertController(title: nil,
                                                message: textValue,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Please, try again later", style: .default, handler: actionHandler))

        viewController.present(alertController, animated: true, completion: nil)
    }
        
    // MARK: - Private
    
    @objc private func textFieldValueChanged(_ textField: UITextField) {
        inputAction?.isEnabled = (textField.text!.count > 0)
    }
    
    @objc private func textDidChanged(_ textField: UITextField) {
        setupInputActionEnableState(withTextField: textField)
    }
    
    private func setupInputActionEnableState(withTextField textField: UITextField) {
        let email = textField.text!
        inputAction?.isEnabled = validator!.isValidEmail(email)
    }

    private func showAlertControllerWithMobileNumberField(forViewController viewController: UIViewController,
                                                          withTitle title: String,
                                                          message: String?,
                                                          buttonTitle: String,
                                                          textValue: String,
                                                          withShareCallback shareCallback: @escaping ((_ text: String) -> (Void))) {
        maskedDelegate = MaskedTextFieldDelegate(format: phoneNumberInputMask)
        maskedDelegate.listener = self
        
        let shareByEmailAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        shareByEmailAlert.addTextField { (textField) in
            textField.placeholder = "Mobile number"
            textField.keyboardType = .numberPad
            textField.delegate = self.maskedDelegate

            self.inputTextField = textField
        }
        let shareAction = UIAlertAction(title: buttonTitle, style: .default, handler: { (action) in
            if let alertTextField = shareByEmailAlert.textFields?.first {
                shareCallback(alertTextField.text!)
            }
        })
        shareAction.isEnabled = false
        shareByEmailAlert.addAction(shareAction)
        shareByEmailAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        inputAction = shareAction
        maskedDelegate.put(text: textValue, into: inputTextField!)
        
        viewController.present(shareByEmailAlert, animated: true, completion: nil)
    }
    
    private func showAlertControllerWithEmailField(forViewController viewController: UIViewController,
                                                   withTitle title: String,
                                                   message: String?,
                                                   buttonTitle: String,
                                                   textValue: String,
                                                   withShareCallback shareCallback: @escaping ((_ text: String) -> (Void))) {
        let shareByEmailAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        shareByEmailAlert.addTextField { (textField) in
            textField.placeholder = "Email"
            textField.addTarget(self, action: #selector(self.textDidChanged(_:)), for: .editingChanged)
            textField.text = textValue
            
            self.inputTextField = textField
        }
        let shareAction = UIAlertAction(title: buttonTitle, style: .default, handler: { (action) in
            if let alertTextField = shareByEmailAlert.textFields?.first {
                shareCallback(alertTextField.text!)
            }
        })
        shareAction.isEnabled = false
        shareByEmailAlert.addAction(shareAction)
        shareByEmailAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        inputAction = shareAction
        setupInputActionEnableState(withTextField: self.inputTextField!)
        
        viewController.present(shareByEmailAlert, animated: true, completion: nil)
    }
    
    private func showSuccessSharedAlertController(forViewController viewController: UIViewController, withMessage message: String) {
        let successSharedAlert = UIAlertController(title: "Shared!",
                                                   message: message,
                                                   preferredStyle: .alert)
        successSharedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        viewController.present(successSharedAlert, animated: true, completion: nil)
    }
    
    // MARK: - MaskedTextFieldDelegateListener
    
    func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
        inputAction?.isEnabled = complete
    }
}
