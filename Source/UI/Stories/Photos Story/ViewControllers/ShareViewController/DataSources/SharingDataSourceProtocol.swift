//
//  SharingDataSourceProtocol.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 9/25/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

protocol ShareDataSourceDelegate: class {
    
    func shareDataSource(_ sender: SharingDataSourceProtocol, didSelectUser user: ShareUser, atIndex index: Int)
    func shareDataSourceDidHandleDoximityTokenExparation(_ sender: SharingDataSourceProtocol)
}

protocol SharingDataSourceProtocol: class {
    func searchUsers(withKeywords keywords: String,withResetValue reset:Bool)
    func reloadUsers()
    
    func setupUserSelection(_ user: ShareUser, atIndex index: Int)
    func selectedUser(at index: Int) -> ShareUser
    func selectedUserViewModel(at index: Int) -> ShareUserViewModel
    func removeSelectedUser(_ user: ShareUser, atIndex index: Int)
    
    func fetchSelectedUsers() -> [ShareUser]
}
