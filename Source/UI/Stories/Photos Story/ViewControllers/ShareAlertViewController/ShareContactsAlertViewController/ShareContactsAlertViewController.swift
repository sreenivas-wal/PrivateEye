//
//  ShareAlertViewController.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 12/19/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import InputMask
import NSStringMask

struct ShareContactsAlertViewControllerViewModel {
    
    let actionTitle: String
    var userDisplayingInformationViewModel: UserDisplayingInformationViewModel
    var displayingInfo: ContactsDisplayingInfo
}

class ShareContactsAlertViewController: ShareAlertViewController, MaskedTextFieldDelegateListener, ShareAlertTableViewCellDelegate {

    private let phoneNumberInputMask = "([000]) [000]-[0000]"
    private let phoneNumberMask = "\\((\\d{3})\\) (\\d{3})-(\\d{4})"

    var validator: ValidatorProtocol?
    var contactsService: ContactsServiceProtocol?
    
    var viewModel: ShareContactsAlertViewControllerViewModel!
    var sharingHandler: ((_ textValues: [String], _ viewController: UIViewController) -> (Void))?
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    private var contactValues: [String] = [String]()
    private var maskedDelegate: MaskedTextFieldDelegate?
    
    // MARK: - Overriden
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shareButton.setTitle(self.viewModel.actionTitle, for: .normal)
    }
    
    override func configureViewLayout() {
        
        let descriptionLabelHeight = self.descriptionLabel.frame.height
        let viewHeight = view.frame.height - keyboardFrame.height
        let alertViewHeight = minHeight() + CGFloat(contactValues.count) * tableViewRowHeight + descriptionLabelHeight

        let isOverAlertViewHeight = (alertViewHeight + alertViewOffset > viewHeight)
        alertViewHeightConstraint.constant = isOverAlertViewHeight ? viewHeight - alertViewOffset : alertViewHeight
        tableView.isScrollEnabled = isOverAlertViewHeight
    }
    
    override func reloadView() {
        super.reloadView()
        
        shareButton.isEnabled = (contactValues.count > 0)
    }
    
    override func minHeight() -> CGFloat {
        
        return 230.0
    }
    
    override func configureViewForDisplayingInfo() {
        super.configureViewForDisplayingInfo()
        
        addButton.isEnabled = false
        
        switch self.viewModel.displayingInfo {
        case .emails:
            configureViewForEmailsDisplayingState()
            break
        case .phones:
            configureViewForPhonesDisplayingState()
            break
        }
    }
    
    // MARK: UITableViewDelegate
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShareAlertTableViewCell", for: indexPath) as! ShareAlertTableViewCell
        cell.delegate = self
        let contact = contactValues[indexPath.row]
        
        switch  self.viewModel.displayingInfo {
        case .emails:
            cell.configure(withTitle: contact)
            break
        case .phones:
            cell.configure(withTitle: formattedContactValue(contact.removedFormatString()))
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactValues.count
    }
    
    // MARK: - Private
    
    private func configureViewForEmailsDisplayingState() {
        textField.placeholder = "Email"
        textField.addTarget(self, action: #selector(self.textDidChanged(_:)), for: .editingChanged)
    }
    
    private func configureViewForPhonesDisplayingState() {
        maskedDelegate = MaskedTextFieldDelegate(format: phoneNumberInputMask)
        maskedDelegate?.listener = self
        
        textField.placeholder = "Mobile number"
        textField.keyboardType = .numberPad
        textField.delegate = self.maskedDelegate
    }
    
    private func clearInputData() {
        textField.text = ""
        addButton.isEnabled = false
    }
    
    @objc private func textDidChanged(_ textField: UITextField) {
        let email = textField.text!
        addButton.isEnabled = validator!.isValidEmail(email)
    }
    
    private func showAccessDeniedAlertController() {
        let alertController = UIAlertController(title: "\"PrivateEyeHC\" Would Like to Access Your Contacts", message: "For easy importing of numbers and emails from your contact list.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) in
            let settingsURL = URL(string: UIApplicationOpenSettingsURLString)!
            
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.openURL(settingsURL)
            }
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func formattedContactValue(_ contact: String) -> String {
        let formattedValue = NSStringMask.maskString(contact, withPattern: phoneNumberMask)
        
        return formattedValue ?? contact
    }
    
    // MARK: - Actions
    
    @IBAction func selectFromPhonebookButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        contactsService?.requestAccessToContacts({ [unowned self] (isSuccess) in
            if isSuccess {
                DispatchQueue.main.async {
                    self.router?.showContactsViewController(fromViewController: self,
                                                            withAnimation: true,
                                                            forDisplayingInfo: self.viewModel.displayingInfo,
                                                            selectionHandler: { (textValues) -> (Void) in
                                                                self.contactValues.append(contentsOf: textValues)
                                                            })
                }
            } else {
                self.showAccessDeniedAlertController()
            }
        })
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        let newContactValue = textField.text!
        contactValues.append(newContactValue)
        
        reloadView()
        clearInputData()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        sharingHandler?(contactValues, self)
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    // MARK: - ShareAlertTableViewCellDelegate
    
    func shareAlertTableViewCellDidTapDeleteButton(_ cell: ShareAlertTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        contactValues.remove(at: indexPath.row)
        
        reloadView()
    }
    
    // MARK: - MaskedTextFieldDelegateListener
    
    func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
        addButton.isEnabled = complete
    }
}
