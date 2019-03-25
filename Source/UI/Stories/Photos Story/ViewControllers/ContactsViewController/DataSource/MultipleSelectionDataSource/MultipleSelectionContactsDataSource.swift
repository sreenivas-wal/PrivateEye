//
//  ContactsDataSource.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 11/14/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

protocol MultipleSelectionContactsDataSourceDelegate: class {
    func multipleSelectionContactsDataSource(_ sender: MultipleSelectionContactsDataSourceProtocol, isEmptyContactsList isEmpty: Bool)
    func multipleSelectionContactsDataSource(_ sender: MultipleSelectionContactsDataSourceProtocol, didSelectContact contact: Contact, atIndex index: Int)
}

class MultipleSelectionContactsDataSource: NSObject, MultipleSelectionContactsDataSourceProtocol, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: MultipleSelectionContactsDataSourceDelegate?
    
    var contactsService: ContactsServiceProtocol?
    var tableView: UITableView?
    var displayingInfo: ContactsDisplayingInfo = .emails
    
    var contacts: [Contact] = [Contact]()
    var selectedContacts: [Contact] = [Contact]()
    var contactsViewModels: [ContactViewModel] = [ContactViewModel]()
    
    var keywords: String = ""
    
    init(contactsService: ContactsServiceProtocol?, tableView: UITableView, displayingInfo: ContactsDisplayingInfo, delegate: MultipleSelectionContactsDataSourceDelegate) {
        super.init()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.contactsService = contactsService
        self.tableView = tableView
        self.displayingInfo = displayingInfo
        self.delegate = delegate
    }
    
    // MARK: - ContactsDataSourceProtocol
    
    func searchContacts(withKeywords keywords: String) {
        self.keywords = keywords
        
        contactsService?.retrieveContacts({ (isSuccess, contacts) in
            if isSuccess {
                guard let contacts = contacts else { return }
            
                self.setupContacts(from: contacts, withKeywords: keywords)
                
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                }
            }
        })
    }

    func reloadContacts() {
        searchContacts(withKeywords: keywords)
    }
    
    func setupContactSelection(_ contact: Contact, atIndex index: Int) {
        let isSelected = contactsViewModels[index].isSelected
        
        if isSelected {
            removeSelectedContact(contact, atIndex: index)
        } else {
            selectedContacts.append(contact)
        }
        
        contactsViewModels[index].isSelected = !isSelected
        tableView?.reloadData()
    }
    
    func selectedContact(at index: Int) -> Contact {
        return selectedContacts[index]
    }
    
    func selectedContactViewModels(at index: Int) -> ContactViewModel {
        let contact = selectedContacts[index]
        
        return convertToViewModels([contact]).last!
    }
    
    func removeSelectedContact(_ contact: Contact, atIndex index: Int) {
        guard let selectedContactIndex = selectedContacts.index(of: contact) else { return }
        selectedContacts.remove(at: selectedContactIndex)
        
        tableView?.reloadData()
    }
    
    func fetchSelectedContacts() -> [Contact] {
        return selectedContacts
    }

    // MARK: - Private
    
    private func setupContacts(from fetchedContacts: [Contact], withKeywords keywords: String) {
        var contacts = [Contact]()

        for contact in fetchedContacts {
            switch displayingInfo {
            case .emails:
                guard contact.emails.count > 0 else { continue }
                
                contact.emails.forEach({ (email) in
                    let newContact = Contact()
                    newContact.identifier = String(format: "%@%@", contact.identifier!, email)
                    newContact.familyName = contact.familyName
                    newContact.givenName = contact.givenName
                    newContact.emails = [email]
                    
                    contacts.append(newContact)
                })
                
                break
            case .phones:
                guard contact.phones.count > 0 else { continue }
                
                contact.phones.forEach({ (phone) in
                    let newContact = Contact()
                    newContact.identifier = String(format: "%@%@", contact.identifier!, phone)
                    newContact.familyName = contact.familyName
                    newContact.givenName = contact.givenName
                    newContact.phones = [phone]
                    
                    contacts.append(newContact)
                })
                
                break
            }
        }

        let filteredContacts = filterContacts(contacts, withKeywords: keywords)
        
        let sortedContacts = filteredContacts.sorted { (contact1, contact2) -> Bool in
            let name1 = contact1.givenName! + " " + contact1.familyName!
            let name2 = contact2.givenName! + " " + contact2.familyName!
            
            let trimmedName1 = name1.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedName2 = name2.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedName1.isEmpty {
                return false
            } else if trimmedName2.isEmpty {
                return true
            } else {
                return trimmedName1.localizedCaseInsensitiveCompare(trimmedName2) == .orderedAscending
            }
        }
        
        self.contacts = sortedContacts
        self.contactsViewModels = convertToViewModels(sortedContacts)
        
        let isEmpty = (sortedContacts.count == 0)
        delegate?.multipleSelectionContactsDataSource(self, isEmptyContactsList: isEmpty)
    }
    
    private func filterContacts(_ contacts: [Contact], withKeywords keywords: String) -> [Contact] {
        let filteredContacts = contacts.filter( { (_ contact: Contact) -> Bool in
            let lowercasedKeywords = keywords.lowercased()
            let contactName = (contact.givenName! + " " + contact.familyName!).trimmingCharacters(in: CharacterSet.whitespaces)
            
            var isMatched = contact.familyName!.lowercased().starts(with: lowercasedKeywords) ||
                contact.givenName!.lowercased().starts(with: lowercasedKeywords) ||
                contactName.lowercased().starts(with: lowercasedKeywords)
            
            if let email = contact.emails.last {
                isMatched = isMatched || email.lowercased().starts(with: lowercasedKeywords)
            }
            
            if let phone = contact.phones.last {
                isMatched = isMatched || phone.lowercased().starts(with: lowercasedKeywords)
            }
            
            return isMatched
        })
        
        return filteredContacts
    }
    
    private func convertToViewModels(_ contacts: [Contact]) -> [ContactViewModel] {
        var viewModels = [ContactViewModel]()
        
        contacts.forEach { (contact) in
            let isSelected = self.selectedContacts.contains(where: { (selectedContact) -> Bool in
                return selectedContact.identifier == contact.identifier
            })
            let contactName = (contact.givenName! + " " + contact.familyName!).trimmingCharacters(in: CharacterSet.whitespaces)
            var displayingInfo: String?
            
            switch self.displayingInfo {
            case .emails:
                displayingInfo = contact.emails.last
                break
            case .phones:
                displayingInfo = contact.phones.last
                break
            }
            
            let viewModel = ContactViewModel(contactName: contactName, displayingInfo: displayingInfo, canSelect: true, isSelected: isSelected)
            viewModels.append(viewModel)
        }
        
        return viewModels
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell") as! ContactTableViewCell
        cell.configure(withContactViewModel: contactsViewModels[indexPath.row])

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsViewModels.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let contact = contacts[indexPath.row]
        delegate?.multipleSelectionContactsDataSource(self, didSelectContact: contact, atIndex: indexPath.row)
    }
    
}
