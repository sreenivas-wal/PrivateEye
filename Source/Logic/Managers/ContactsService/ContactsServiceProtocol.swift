//
//  ContactsServiceProtocol.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 11/14/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

protocol ContactsServiceProtocol: class {
    func requestAccessToContacts(_ completion: @escaping (_ success: Bool) -> Void)
    func retrieveContacts(_ completion: (_ success: Bool, _ contacts: [Contact]?) -> Void)
}
