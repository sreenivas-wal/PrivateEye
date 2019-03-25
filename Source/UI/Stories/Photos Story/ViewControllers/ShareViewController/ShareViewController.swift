//
//  ShareViewController.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 8/18/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

typealias ShareViewControllerAuthorizationFailureBlock = ((_ viewController: ShareViewController) -> ())

enum SharingDestination: Int {
    case user
    case doximity
}

class ShareViewController: MultipleSelectionViewController, UITextFieldDelegate, ShareDataSourceDelegate, ContactListTableViewCellDelegate {

    private let tableViewEstimatedRowHeight: CGFloat = 92
    var router: PhotosRouterProtocol?
    var networkManager: PhotosNetworkProtocol?
    var sharingDestination: SharingDestination = .user
    
    var dataSource: SharingDataSourceProtocol!
    
    var shareCompletionHandler: ((_ users: [ShareUser], _ presentingController: UIViewController) -> (Void))?
    var cancelSharingCompletionHandler: (() -> (Void))?
    var doximityAuthorizationFailureBlock: ShareViewControllerAuthorizationFailureBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.searchUsers(withKeywords: "", withResetValue: false)
        reloadView(animated: false)
    }
    
    // MARK: - Overriden
    
    override func configureDataSource() {
        switch sharingDestination {
        case .user:
            dataSource = ShareUsersDataSource(tableView: listContactsTableView, networkManager: networkManager, delegate: self)
            refreshButton.isHidden = true
            break
        case .doximity:
            dataSource = ShareDoximityDataSource(tableView: listContactsTableView, networkManager: networkManager, delegate: self)
            break
        }
    }

    override func selectedCount() -> Int {
        return dataSource.fetchSelectedUsers().count

    }
    
    override func reloadView(animated: Bool) {
        super.reloadView(animated: animated)
        
        dataSource.fetchSelectedUsers().count > 0 ? enableNextButton() : disableNextButton()
    }
    
    // MARK: - Private
    
    private func disableNextButton() {
        headerBar?.rightButtonEnable = false
        headerBar?.rightButtonTextColor = .lightGray
    }
    
    private func enableNextButton() {
        headerBar?.rightButtonEnable = true
        headerBar?.rightButtonTextColor = .white
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.fetchSelectedUsers().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactListTableViewCell") as! ContactListTableViewCell
        let viewModel = dataSource.selectedUserViewModel(at: indexPath.row)
        cell.configure(withUserViewModel: viewModel)
        cell.delegate = self
        
        return cell
    }
    
    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        dataSource.searchUsers(withKeywords: textField.text!, withResetValue: false)
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        textField.resignFirstResponder()
        
        dataSource.searchUsers(withKeywords: "", withResetValue: false)
        
        return false
    }
    
    
    @IBAction func refreshDoximityList(_ sender: Any) {
        dataSource.searchUsers(withKeywords: "", withResetValue: true)
    }
    
    // MARK: - ContactListTableViewCellDelegate
    
    func contactListTableViewCellDidTapDelete(_ sender: ContactListTableViewCell) {
        guard let indexPath = selectedContactsTableView.indexPath(for: sender) else { return }
        
        let user = dataSource.selectedUser(at: indexPath.row)
        dataSource.removeSelectedUser(user, atIndex: indexPath.row)
        dataSource.reloadUsers()
        reloadView(animated: false)
    }
    
    // MARK: - ShareDataSourceDelegate
    
    func shareDataSource(_ sender: SharingDataSourceProtocol, didSelectUser user: ShareUser, atIndex index: Int) {
        dataSource.setupUserSelection(user, atIndex: index)
        reloadView(animated: true)
    }
    
    func shareDataSourceDidHandleDoximityTokenExparation(_ sender: SharingDataSourceProtocol) {
        
        guard let requiredDoximityAuthorizationFailureBlock = doximityAuthorizationFailureBlock else { return }
        requiredDoximityAuthorizationFailureBlock(self)
        doximityAuthorizationFailureBlock = nil
    }

    // MARK: - HeaderBarDelegate
    
    func headerBar(_ header: HeaderBar, didTapLeftButton left: UIButton) {
        if let cancelSharingCompletionHandler = cancelSharingCompletionHandler {
            cancelSharingCompletionHandler()
        }
    }
    
    func headerBar(_ header: HeaderBar, didTapRightButton right: UIButton) {
        let selectedUsers = dataSource.fetchSelectedUsers()
        shareCompletionHandler?(selectedUsers, self)
    }

}

