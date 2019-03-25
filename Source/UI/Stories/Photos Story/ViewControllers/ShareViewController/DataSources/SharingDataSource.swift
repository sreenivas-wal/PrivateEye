//
//  ShareDataSource.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 1/15/18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit

class SharingDataSource: NSObject, SharingDataSourceProtocol, UITableViewDelegate, UITableViewDataSource {
   
    weak var delegate: ShareDataSourceDelegate?
    var tableView: UITableView?
    var networkManager: PhotosNetworkProtocol?
    
    var users: [ShareUser] = []
    var selectedUsers: [ShareUser] = []
    var usersViewModels: [ShareUserViewModel] = []
    var keywords: String = ""
    
    init(tableView: UITableView, networkManager: PhotosNetworkProtocol?, delegate: ShareDataSourceDelegate) {
        super.init()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.delegate = delegate
        self.tableView = tableView
        self.networkManager = networkManager
    }
    
    // MARK: - SharingDataSourceProtocol
    
    func searchUsers(withKeywords keywords: String, withResetValue reset: Bool) {
        fatalError("Override this method")
    }
    
    func reloadUsers() {
        usersViewModels = setupViewModels(forUsers: users)
        tableView?.reloadData()
    }
    
    func setupUserSelection(_ user: ShareUser, atIndex index: Int) {
        let isSelected = usersViewModels[index].isSelected
        
        if isSelected {
            removeSelectedUser(user, atIndex: index)
        } else {
            selectedUsers.append(user)
        }
        
        usersViewModels[index].isSelected = !isSelected
        tableView?.reloadData()
    }
    
    func selectedUser(at index: Int) -> ShareUser {
        return selectedUsers[index]
    }
    
    func selectedUserViewModel(at index: Int) -> ShareUserViewModel {
        let user = selectedUsers[index]
        
        return convertToViewModel(user)
    }
    
    func removeSelectedUser(_ user: ShareUser, atIndex index: Int) {
        guard let selectedUserIndex = selectedUsers.index(of: user) else { return }
        selectedUsers.remove(at: selectedUserIndex)
        
        tableView?.reloadData()
    }
    
    func fetchSelectedUsers() -> [ShareUser] {
        return selectedUsers
    }
    
    // MARK: - Public
    
    func setupViewModels(forUsers users: [ShareUser]) -> [ShareUserViewModel] {
        return users.map({ (user) -> ShareUserViewModel in
            return self.convertToViewModel(user)
        })
    }
    
    func convertToViewModel(_ user: ShareUser) -> ShareUserViewModel {
        let isSelected = selectedUsers.contains(where: { (selectedUser) -> Bool in
            return selectedUser.userID == user.userID
        })
        let viewModel = ShareUserViewModel(username: user.username, canSelect: true, isSelected: isSelected)
        
        return viewModel
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        delegate?.shareDataSource(self, didSelectUser: user, atIndex: indexPath.row)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell") as! ContactTableViewCell
        cell.configure(withShareViewModel: usersViewModels[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
}
