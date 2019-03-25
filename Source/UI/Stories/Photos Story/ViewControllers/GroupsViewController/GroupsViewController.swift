//
//  GroupsViewController.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 1/22/18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit
import ExpandingMenu


class GroupsViewController: ExpandingMenuDataViewController,GroupsDataSourceDelegate, UITextFieldDelegate {

    enum GroupsManageMode {
        case normal
        case sharing
        case edit
        case delete
    }

    // MARK: -
    // MARK: Properties
    @IBOutlet weak var noResultView: NoResultView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var headerTitleButton: UIButton!
    @IBOutlet weak var groupMenuButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    var dataSource: GroupsDataSourceProtocol?
//    var foldersNavigationDataSource: FoldersNavigationDataSourceProtocol?
    
    fileprivate var manageMode: GroupsManageMode = .normal
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
        self.manageMode = self.isSharing ? .sharing : .normal
        
        switch self.manageMode {
        case .sharing:
            configureHeaderBarForSharing()
            addLeftHeaderbackButton()
            
            headerTitleButton?.setImage(nil, for: .normal)
            headerTitleButton?.setTitle("SELECT GROUP", for: .normal)
        default: break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource?.reloadGroups(withKeywords: "")
        self.configureExpandingMenuForCamera(headerTitleButton: headerTitleButton, progressView: progressView)
    }
    
    // MARK: - Private

    private func addLeftHeaderbackButton() {
        headerBar?.leftButtonImage = UIImage(named: "back-arrow")
        headerBar?.leftButtonHide = false
    }
    
    private func configureDataSource() {
        let dataSource = GroupsDataSource(tableView: tableView, networkManager: networkManager!, userManager: userManager!, alertManager: alertsManager as! AlertsManager, viewController: self, router: self.router!, delegate: self)
        self.dataSource = dataSource
    }
    
    private func showAddNewGroupAlertController() {
        let handler: ((String) -> ()) = { [unowned self] (_ text: String) in
            self.networkManager?.createGroup(with: text, successBlock: { [unowned self] (response) -> (Void) in
                let response = response.object as! CreateGroupResponse
                let group = Group(groupID: response.nid)
                
                self.reloadContent()
                self.showAddMembersAlertController(forGroup: group)
            }, failureBlock: { [unowned self] (error) -> (Void) in
                self.presentAlert(withMessage: error.message)
            })
        }
        alertsManager?.showAlertWithTextField(forViewController: self,
                                              with: "New Group",
                                              message: "Enter group name below",
                                              textFieldPlaceholder: "Group name",
                                              actionHandler: handler)
    }
    
    private func showEditAlertController(for group: Group) {

        let handler: ((String) -> ()) = { [unowned self] (_ text: String) in

            self.networkManager?.editGroup(group,
                                           with: text,
                                           successBlock: { [unowned self] (response) -> (Void) in
                                               self.reloadContent()
                                           },
                                           failureBlock: { [unowned self] (error) -> (Void) in
                                               self.presentAlert(withMessage: error.message)
                                           })
        }
        
        alertsManager?.showAlertWithTextField(forViewController: self,
                                                           with: "Edit Group",
                                                        message: "Enter group name below",
                                           textFieldPlaceholder: "Group name",
                                                  actionHandler: handler)

    }
    
    private func showDeleteAlertController(for group: Group) {
        
        let alert = UIAlertController(title: "Delete Group?",
                                    message: nil,
                             preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { [weak self, alert] (action) in
            
            guard let strongSelf = self else { return }
            strongSelf.networkManager?.deleteGroup(group,
                                             successBlock: { (response) -> (Void) in
                                                 strongSelf.reloadContent()
                                             },
                                             failureBlock: { (response) -> (Void) in
                                                 strongSelf.presentAlert(withMessage: response.message)
                                             })
            alert.dismiss(animated: true, completion: nil)
        }

        let noAction = UIAlertAction(title: "No", style: .default) { [weak alert] (action) in
            alert?.dismiss(animated: true, completion: nil)
        }

        alert.addAction(yesAction)
        alert.addAction(noAction)

        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Overriden
    
    override func reloadContent() {
        dataSource?.reloadGroups(withKeywords: searchTextField.text ?? "")
    }
    
    // MARK: - Actions

    @IBAction func groupButtonTapped(_ sender: Any) {
        
        self.showGroupActionAlert()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dataSource?.reloadGroups(withKeywords: textField.text!)
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        dataSource?.reloadGroups(withKeywords: "")
        
        textField.text = ""
        textField.resignFirstResponder()
        
        return false
    }
    
    // MARK: CameraViewControllerDelegate

    
    // MARK: - GroupsDataSourceDelegate

    func groupsDataSourceWillAddNewGroup(_ dataSource: GroupsDataSourceProtocol) {
        DispatchQueue.main.async {
            self.showAddNewGroupAlertController()
        }
    }
    
    func groupsDataSource(_ dataSource: GroupsDataSourceProtocol, isEmptyGroups isEmpty: Bool) {
        noResultView.isHidden = !isEmpty
    }
    
    func groupsDataSource(_ dataSource: GroupsDataSourceProtocol, didSelect group: Group) {
        
        foldersNavigationDataSource?.replace(withItems: [])

        switch self.manageMode {
        case .normal:
            router?.showPhotosViewController(fromViewController: self,
                                                  withAnimation: true,
                                                           with: .group(group: group),
                                                isEnableContent: !isSharing)
            
        case .sharing:
            router?.showSharePhotosViewController(fromViewController: self,
                                                       withAnimation: true,
                                                                with: .group(group: group),
                                            sharingCompletionHandler: sharingCompletionHandler)
            
        case .edit:
            let isGroupOwner = userManager?.currentUser?.userID == group.ownerId
            if isGroupOwner {
                self.showEditAlertController(for: group)
            }
        
        case .delete:
            let isGroupOwner = userManager?.currentUser?.userID == group.ownerId
            if isGroupOwner {
                self.showDeleteAlertController(for: group)
            }
        }
        
        self.manageMode = self.isSharing ? .sharing : .normal
    }
    
    // MARK: - HeaderBarDelegate
    
    func headerBar(_ header: HeaderBar, didTapLeftButton left: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Alert
    func showGroupActionAlert() {

        let actionSheet = UIAlertController(title: nil,
                                          message: nil,
                                   preferredStyle: .actionSheet)
        
        let newGroupAction = UIAlertAction(title: "New Group", style: .default) { [weak self, actionSheet] (action) in
            
            guard let strongSelf = self else { return }
            
            strongSelf.showAddNewGroupAlertController()
            actionSheet.dismiss(animated: true, completion: nil)
        }
        
        let editGroupAction = UIAlertAction(title: "Edit Group", style: .default) { [weak self, actionSheet] (action) in
            
            guard let strongSelf = self else { return }
            strongSelf.manageMode = .edit
            actionSheet.dismiss(animated: true, completion: nil)
        }
        
        let deleteGroupAction = UIAlertAction(title: "Delete Group", style: .default) {  [weak self, actionSheet] (action) in
            
            guard let strongSelf = self else { return }
            strongSelf.manageMode = .delete
            actionSheet.dismiss(animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak actionSheet] (action) in
            
            actionSheet?.dismiss(animated: true, completion: nil)
        }
        
        actionSheet.addAction(newGroupAction)
        actionSheet.addAction(editGroupAction)
        actionSheet.addAction(deleteGroupAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
}
