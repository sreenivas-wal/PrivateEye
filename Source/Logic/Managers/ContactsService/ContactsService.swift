//
//  ContactsService.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 11/14/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import Contacts

class ContactsService: NSObject, ContactsServiceProtocol {

    private var contactStore = CNContactStore()
    
    // MARK: - ContactsServiceProtocol
    
    func requestAccessToContacts(_ completion: @escaping (_ success: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        switch authorizationStatus {
        case .authorized:
            completion(true)
            break
        case .denied, .notDetermined:
            contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (accessGranted, error) -> Void in
                completion(accessGranted)
            })
            break
        case .restricted:
            completion(false)
            break
        }
    }
    
    func retrieveContacts(_ completion: (_ success: Bool, _ contacts: [Contact]?) -> Void) {
        var contacts = [Contact]()
        do {
            let contactsFetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor,
                                                                           CNContactFamilyNameKey as CNKeyDescriptor,
                                                                           CNContactPhoneNumbersKey as CNKeyDescriptor,
                                                                           CNContactEmailAddressesKey as CNKeyDescriptor])
            try contactStore.enumerateContacts(with: contactsFetchRequest, usingBlock: { (cnContact, error) in
                if let contact = self.convertToContacts(cnContact) { contacts.append(contact) }
            })

            completion(true, contacts)
        } catch {
            completion(false, nil)
        }
    }
    
    // MARK: - Private
    
    private func convertToContacts(_ cnContact: CNContact) -> Contact? {
        if !cnContact.isKeyAvailable(CNContactGivenNameKey) && !cnContact.isKeyAvailable(CNContactFamilyNameKey) { return nil }
        
        let contact = Contact()
        contact.identifier = cnContact.identifier
        contact.givenName = cnContact.givenName
        contact.familyName = cnContact.familyName
        contact.emails = cnContact.emailAddresses.map { ($0.value as String) }
        contact.phones = cnContact.phoneNumbers.map { $0.value.stringValue }
        
        return contact
    }
    
}
