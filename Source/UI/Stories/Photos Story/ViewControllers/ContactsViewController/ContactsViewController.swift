//
//  ContactsViewController.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 11/14/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

enum ContactsDisplayingInfo: Int {
    case emails = 0
    case phones
}

class ContactsViewController: MultipleSelectionViewController, UITextFieldDelegate, MultipleSelectionContactsDataSourceDelegate, ContactListTableViewCellDelegate {
    
    private let maxPhoneNumberLength = 10

    var router: PhotosRouterProtocol?
    var contactsService: ContactsServiceProtocol?
    var displayingInfo: ContactsDisplayingInfo = .emails
    var selectionHandler: ((_ textValues: [String]) -> (Void))?

    private var dataSource: MultipleSelectionContactsDataSourceProtocol!
    private var selectedContacts: [Contact] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.isStatusBarHidden = false
        
        dataSource?.searchContacts(withKeywords: "")
        reloadView(animated: false)
    }

    // MARK: - Actions
    
    @IBAction func searchTextFieldEditingChanged(_ sender: Any) {
        guard let keywords = searchTextField.text else { return }
        
        dataSource?.searchContacts(withKeywords: keywords.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    // MARK: Overriden
    
    override func selectedCount() -> Int {
        return dataSource.fetchSelectedContacts().count
    }
    
    override func configureDataSource() {
        let dataSource = MultipleSelectionContactsDataSource(contactsService: contactsService,
                                                             tableView: listContactsTableView,
                                                             displayingInfo: displayingInfo,
                                                             delegate: self)
        self.dataSource = dataSource
    }

    override func unsecureConnection() {
        super.unsecureConnection()

        showUnsecureConnectionView(withConnectionState: .unsecureConnection, completionBlock: { [unowned self] in
            self.router?.showBluetoothViewController(fromViewController: self, withAnimation: true)
        })
    }

    // MARK: - Private

    private func searchContacts() {
        guard let keywords = searchTextField.text else { return }
        
        dataSource?.searchContacts(withKeywords: keywords.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    private func isClearedPhoneNumber( _ phoneText: inout String) -> Bool {
        phoneText = phoneText.removedFormatString()
        
        if phoneText.hasPrefix("+") {
            if phoneText.hasPrefix("+1") {
                phoneText = phoneText.replacingOccurrences(of: "+1", with: "")
            }
            else {
                return false
            }
        }
        
        let usaNumbersPrefix = "1"
        
        if (phoneText.hasPrefix(usaNumbersPrefix)) && (phoneText.count == self.maxPhoneNumberLength + usaNumbersPrefix.count) {
            phoneText.remove(at: phoneText.startIndex)
        }
        
        return true
    }

    // MARK: - MultipleSelectionContactsDataSourceDelegate
    
    func multipleSelectionContactsDataSource(_ sender: MultipleSelectionContactsDataSourceProtocol, isEmptyContactsList isEmpty: Bool) {
        noResultView.isHidden = !isEmpty
    }
    
    func multipleSelectionContactsDataSource(_ sender: MultipleSelectionContactsDataSourceProtocol, didSelectContact contact: Contact, atIndex index: Int) {
        switch displayingInfo {
        case .emails:
            break
        case .phones:
            var phoneText = contact.phones.last!

            if !isClearedPhoneNumber(&phoneText) {
                self.presentAlert(withMessage: "Currently service is available for US mobile numbers only (xxx) xxx-xxxx")
                return
            }

            if phoneText.count != self.maxPhoneNumberLength {
                self.presentAlert(withMessage: "Currently service is available for US mobile numbers only (xxx) xxx-xxxx")
                return
            }
            break
        }
        
        dataSource.setupContactSelection(contact, atIndex: index)
        reloadView(animated: true)
    }

    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.fetchSelectedContacts().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactListTableViewCell") as! ContactListTableViewCell
        let viewModel = dataSource.selectedContactViewModels(at: indexPath.row)
        cell.configure(withContactViewModel: viewModel)
        cell.delegate = self
        
        return cell
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    // MARK: - ContactListTableViewCellDelegate
    
    func contactListTableViewCellDidTapDelete(_ sender: ContactListTableViewCell) {
        guard let indexPath = selectedContactsTableView.indexPath(for: sender) else { return }
        let contact = dataSource.selectedContact(at: indexPath.row)
        dataSource.removeSelectedContact(contact, atIndex: indexPath.row)
        dataSource.reloadContacts()
        reloadView(animated: false)
    }
    
    // MARK: - HeaderBarDelegate
    
    func headerBar(_ header: HeaderBar, didTapLeftButton left: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func headerBar(_ header: HeaderBar, didTapRightButton right: UIButton) {
        navigationController?.popViewController(animated: true)
        
        var contactValues: [String] = []
        
        switch displayingInfo {
        case .emails:
            contactValues = dataSource.fetchSelectedContacts().map({ (contact) -> String in
                return contact.emails.last!
            })
            break
        case .phones:
            contactValues = dataSource.fetchSelectedContacts().map({ (contact) -> String in
                var phoneText = contact.phones.last!
                _ = isClearedPhoneNumber(&phoneText)

                return phoneText
            })
            break
        }
        
        selectionHandler?(contactValues)
    }
}
