//
//  ContactsDataSourceProtocol.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 11/14/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

protocol MultipleSelectionContactsDataSourceProtocol: class {
    func searchContacts(withKeywords keywords: String)
    func reloadContacts()
    
    func setupContactSelection(_ contact: Contact, atIndex index: Int)
    func selectedContact(at index: Int) -> Contact
    func selectedContactViewModels(at index: Int) -> ContactViewModel
    func removeSelectedContact(_ contact: Contact, atIndex index: Int)
    
    func fetchSelectedContacts() -> [Contact]
}
