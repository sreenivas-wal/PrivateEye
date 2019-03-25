//
//  BaseContentViewController.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 9/1/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

class BaseContentViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    weak var router: PhotosRouterProtocol?
    var networkManager: (PhotosNetworkProtocol & InviteUsersProtocol & AuthorizationNetworkProtocol)?
    var userManager: SessionUserProtocol?
    var alertsManager: AlertsManagerProtocol?
    var contactsService: ContactsServiceProtocol?
    var selectedFolder: Folder?
    var isSharing: Bool = false
    var sharingCompletionHandler: ((_ group: Group) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNotificationsIcon()
    }
    
    // MARK: Overriden
    override func unsecureConnection() {
        super.unsecureConnection()

        showUnsecureConnectionView(withConnectionState: .unsecureConnection, completionBlock: { [unowned self] in
            self.router?.showBluetoothViewController(fromViewController: self, withAnimation: true)
        })
    }

    // MARK: - Actions
    @IBAction func headerTitleTapped(_ sender: Any) {
        if isSharing { return }
        
        router?.openMenu(animated: true)
    }
    
    // MARK: - HeaderBarDelegate
    func headerBar(_ header: HeaderBar, didTapNearToLeft button: UIButton) {
        self.router?.showNotificationsHistory(from: self, animated: true)
    }
    
    // MARK: - Public
    
    func showNewFolderAlertController() {
        let newFolderAlertController = UIAlertController(title: "New Folder", message: "Enter folder name below", preferredStyle: .alert)
        newFolderAlertController.addTextField { (textField) in
            textField.placeholder = "Subfolder name"
        }
        newFolderAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        newFolderAlertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
            if let alertTextField = newFolderAlertController.textFields?.first {
                guard let folderName = alertTextField.text else { return }
                
                self.createFolder(withName: folderName)
            }
        }))
        
        present(newFolderAlertController, animated: true, completion: nil)
    }
    
    func handleSuccessFolderSaving() {
        print("Override in subclasses")
    }
    
    func createFolder(withName name: String) {
        fatalError("Override this method")
    }
    
    func updateGroupMembers(with members: Int) { }
    
    func showDuplicateFolderNameAlertController() {
        let duplicateNameAlertController = UIAlertController(title: "Error", message: "Folder name already exists. Enter a new name.", preferredStyle: .alert)
        duplicateNameAlertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        present(duplicateNameAlertController, animated: true, completion: nil)
    }
    
    func shareToDoximity(withSuccessCompletionHandler successHandler: @escaping () -> (Void)) {
        let doximityID = userManager?.currentUser?.doximityID ?? ""
        let hasDoximityAccount = !doximityID.isEmpty
        
        if hasDoximityAccount {
            successHandler()
        } else {
            let doximitySignUpAlert = UIAlertController.signUpToDoximityAlertController(withLoginHandler: { [unowned self] in
                
                self.router?.showDoximityFullAuthorization(from: self,
                                                       animated: true,
                                                    resultBlock: { (authorizationResult) in
                                                            
                                                        switch authorizationResult {
                                                        case.success:
                                                            self.router?.relogin(fromViewController: self, withAnimation: false)
                                                        case .failure(_): break
                                                        }
                                                    })
            })
            
            present(doximitySignUpAlert, animated: true, completion: nil)
        }
    }
    
    func showInviteAlert(forViewController viewController: UIViewController) {
        let inviteMessage = "This Doximity user is not a member of PrivateEyeHC. Invite this user to join PrivateEyeHC by:"
        
        alertsManager?.showInviteAlertController(forViewController: self, withMessage: inviteMessage, withDoximityInviteHandler: { [unowned self] () -> (Void) in
            self.networkManager?.inviteUserInDoximity()
            }, withEmailInviteHandler: { [unowned self] () -> (Void) in
            let selectionHandler: (([String]) -> (Void)) = { [unowned self] (_ textValues: [String]) in
                DispatchQueue.main.async {
                    let textValue = textValues.last ?? ""
                    self.alertsManager?.showInviteByEmailAlertController(forViewController: self, textValue: textValue, withSuccessHandler: { [unowned self] (email) -> (Void) in
                        self.inviteUser(byEmail: email)
                    })
                }
            }
            
            self.contactsService?.requestAccessToContacts({ [unowned self] (isSuccess) in
                if isSuccess {
                    DispatchQueue.main.async {
                        self.router?.showContactsViewController(fromViewController: self, withAnimation: true, forDisplayingInfo: .emails, selectionHandler: selectionHandler)
                    }
                } else {
                    selectionHandler([])
                }
            })
        }, textInviteHandler: { [unowned self] () -> (Void) in
            let selectionHandler: (([String]) -> (Void)) = { [unowned self] (_ textValues: [String]) in
                DispatchQueue.main.async {
                    let textValue = textValues.last ?? ""
                    self.alertsManager?.showInviteByTextAlertController(forViewController: self, textValue: textValue, withSuccessHandler: { [unowned self] (phone) -> (Void) in
                        self.inviteUser(byText: phone)
                    })
                }
            }
            
            self.contactsService?.requestAccessToContacts({ [unowned self] (isSuccess) in
                if isSuccess {
                    DispatchQueue.main.async {
                        self.router?.showContactsViewController(fromViewController: self, withAnimation: true, forDisplayingInfo: .phones, selectionHandler: selectionHandler)
                    }
                } else {
                    selectionHandler([])
                }
            })
        })
    }
    
    func inviteUser(byEmail email: String) {
        networkManager?.inviteUser(byEmail: email, successBlock: { (response) -> (Void) in
            DispatchQueue.main.async { self.alertsManager?.showSuccessInviteAlertController(forViewController: self) }
        }, failureBlock: { (error) -> (Void) in
            DispatchQueue.main.async { self.presentAlert(withMessage: error.message) }
        })
    }
    
    func inviteUser(byText text: String) {
        networkManager?.inviteUser(byText: text, successBlock: { (response) -> (Void) in
            DispatchQueue.main.async { self.alertsManager?.showSuccessInviteAlertController(forViewController: self)  }
        }, failureBlock: { (error) -> (Void) in
            DispatchQueue.main.async {  self.presentAlert(withMessage: error.message) }
        })
    }
    
    func showAddMembersAlertController(forGroup group: Group) {
        alertsManager?.showAddMembersAlertController(forViewController: self, withUserSelectionCallback: { [unowned self] () -> (Void) in
            self.shareGroupToUser(group)
        }, doximitySelectionCallback: { [unowned self] () -> (Void) in
            self.shareToDoximity(withSuccessCompletionHandler: { [unowned self] () -> (Void) in
                self.shareGroupToDoximity(group)
            })
        }, emailSelectionCallback: { [unowned self] () -> (Void) in
            self.shareGroupByEmails(group)
        }, textSelectionCallback: { [unowned self] () -> (Void) in
            self.shareGroupByTexts(group)
        })
    }
    
    func reloadContent() {
        fatalError("Override thid method")
    }
    
    private func shareGroupToUser(_ group: Group) {
        let sharingCompletionHandler: (([ShareUser], UIViewController) -> (Void)) = { [unowned self] (users, presenting) -> (Void) in
            presenting.view.isUserInteractionEnabled = false
            
            self.networkManager?.shareGroupToUser(group, forUsers: users, successBlock: { [unowned self] (response) -> (Void) in
                let sharingResponse = response.object as! GroupSharingResponse
                let recipients = sharingResponse.recipient
                
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                    self.reloadContent()
                    self.updateGroupMembers(with: users.count - recipients.count)
                    
                    if sharingResponse.isSuccess {
                        self.alertsManager?.showSuccessMembersAddedAlertController(forViewController: self, withSuccessHandler: { [unowned self] in
                            self.showAddMembersAlertController(forGroup: group)
                        })
                    } else {
                        self.convertRecipients(recipients, withUsers: users)
                    }
                }
            }, failureBlock: { (error) -> (Void) in
                DispatchQueue.main.async {
                    presenting.view.isUserInteractionEnabled = true
                    self.presentAlert(withMessage: error.message)
                }
            }
        )}
        
        router?.showShareViewController(fromViewController: self,
                                        withAnimation: true,
                                        shareCompletionHandler: sharingCompletionHandler,
                                        cancelSharingCompletionHandler: { () -> (Void) in
                                            self.navigationController?.popViewController(animated: true)
                                        },
                                        doximityAuthorizationFailureBlock: nil,
                                        forSharingDestination: .user)
    }
    
    private func shareGroupToDoximity(_ group: Group) {
        let sharingCompletionHandler: (([ShareUser], UIViewController) -> (Void)) = { [unowned self] (users, presenting) -> (Void) in
            presenting.view.isUserInteractionEnabled = false
            
            self.networkManager?.shareGroupToDoximityUser(group, forUsers: users, successBlock: { (response) -> (Void) in
                let sharingResponse = response.object as! GroupSharingResponse
                let recipients = sharingResponse.recipient
                
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                    self.reloadContent()
                    self.updateGroupMembers(with: users.count - recipients.count)
                    
                    if sharingResponse.isSuccess {
                        self.alertsManager?.showSuccessMembersAddedAlertController(forViewController: self, withSuccessHandler: { [unowned self] in
                            self.showAddMembersAlertController(forGroup: group)
                        })
                    } else {
                        self.convertRecipients(recipients, withUsers: users)
                    }
                }
            }, failureBlock: { (error) -> (Void) in
                presenting.view.isUserInteractionEnabled = true
                
                if error.code == noDoximityUserExistErrorCode {
                    DispatchQueue.main.async {
                        presenting.dismiss(animated: true, completion: {
                            self.showInviteAlert(forViewController: self)
                        })
                    }
                } else {
                    DispatchQueue.main.async { self.alertsManager?.showErrorAlert(forViewController: self, withMessage: error.message) }
                }
            }
        )}
        
        router?.showShareViewController(fromViewController: self, withAnimation: true,
                                        shareCompletionHandler: sharingCompletionHandler,
                                        cancelSharingCompletionHandler: { () -> (Void) in
                                            DispatchQueue.main.async { self.navigationController?.popViewController(animated: true) }
                                        },
                                        doximityAuthorizationFailureBlock: { [weak self] shareViewController in
                                            
                                            guard let strongSelf = self else { return }
                                            
                                            DispatchQueue.main.async { strongSelf.navigationController?.popViewController(animated: true) }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                                                
                                                strongSelf.router?.showDoximityUpdateTokenAuthorization(from: strongSelf, animated: true, resultBlock: { [weak self] (result) in
                                                    
                                                    guard let strongSelf = self else { return }
                                                    
                                                    switch result {
                                                    case .success: strongSelf.shareGroupToDoximity(group)
                                                    default: break
                                                    }
                                                })
                                            })
                                        },
                                        forSharingDestination: .doximity)
    }
    
    
    private func shareGroupByEmails(_ group: Group) {
        
        let screenViewModel = ShareContactsAlertViewControllerViewModel(actionTitle: "Share",
                                                 userDisplayingInformationViewModel: UserDisplayingInformationViewModel.addMemberByEmailsViewModel(),
                                                                     displayingInfo: .emails)
        
        router?.showShareContactsAlertViewController(fromViewController: self,
                                                          withAnimation: true,
                                                              viewModel: screenViewModel,
                                                          shareCallback: { [unowned self] (textValues, viewController) -> (Void) in
                                                             self.networkManager?.shareGroup(group, byEmails: textValues, successBlock: { (response) -> (Void) in
                                                                 let sharingResponse = response.object as! GroupSharingResponse
                                                                 let recipients = sharingResponse.recipient
                                                                
                                                                 DispatchQueue.main.async {
                                                                     viewController.dismiss(animated: true, completion: nil)
                                                                     self.reloadContent()
                                                                     self.updateGroupMembers(with: textValues.count - recipients.count)
                                                                    
                                                                     if sharingResponse.isSuccess {
                                                                         self.alertsManager?.showSuccessMembersAddedAlertController(forViewController: self, withSuccessHandler: { [unowned  self] in
                                                                             self.showAddMembersAlertController(forGroup: group)
                                                                         })
                                                                     }
                                                                      else {
                                                                         self.convertRecipients(recipients, withTextValues: textValues)
                                                                     }
                                                                 }
                                                          },
                                                          failureBlock: { (error) -> (Void) in
                                                              DispatchQueue.main.async { self.presentAlert(withMessage: error.message) }
                                                          })
        })
    }
    
    private func shareGroupByTexts(_ group: Group) {
        
        let screenViewModel = ShareContactsAlertViewControllerViewModel(actionTitle: "Share",
                                                 userDisplayingInformationViewModel: UserDisplayingInformationViewModel.addMemberBySMSViewModel(),
                                                                     displayingInfo: .phones)
        
        router?.showShareContactsAlertViewController(fromViewController: self,
                                                     withAnimation: true,
                                                     viewModel: screenViewModel,
                                                     shareCallback: { [unowned self] (textValues, viewController) -> (Void) in
                                                        self.networkManager?.shareGroup(group, byTexts: textValues, successBlock: { (response) -> (Void) in
                                                            let sharingResponse = response.object as! GroupSharingResponse
                                                            let recipients = sharingResponse.recipient
                                                            
                                                            DispatchQueue.main.async {
                                                                viewController.dismiss(animated: true, completion: nil)
                                                                self.reloadContent()
                                                                self.updateGroupMembers(with: textValues.count - recipients.count)
                                                                
                                                                if sharingResponse.isSuccess {
                                                                    self.alertsManager?.showSuccessMembersAddedAlertController(forViewController: self, withSuccessHandler: { [unowned self] in
                                                                        self.showAddMembersAlertController(forGroup: group)
                                                                    })
                                                                } else {
                                                                    self.convertRecipients(recipients, withTextValues: textValues)
                                                                }
                                                            }
                                                        }, failureBlock: { (error) -> (Void) in
                                                            DispatchQueue.main.async { self.presentAlert(withMessage: error.message) }
                                                        })
        })
    }
    
    private func convertRecipients(_ recipients: [Recipient], withUsers users: [ShareUser]) {
        var existingMembersViewModels: [ContactViewModel] = []
        var profileNotFoundViewModels: [ContactViewModel] = []
        
        for recipient in recipients {
            if recipient.code == recipientProfileNotFoundCode {
                guard let viewModel = self.convertAccount(recipient, users: users) else { continue }
                profileNotFoundViewModels.append(viewModel)
            } else if recipient.code == existingRecipientCode {
                guard let viewModel = self.convertAccount(recipient, users: users) else { continue }
                existingMembersViewModels.append(viewModel)
            }
        }
        
        showRecipientsAlertControllersIfNeeded(existingMembersViewModels, profileNotFoundViewModels: profileNotFoundViewModels)
    }
    
    private func convertRecipients(_ recipients: [Recipient], withTextValues textValues: [String]) {
        var existingMembersViewModels: [ContactViewModel] = []
        var profileNotFoundViewModels: [ContactViewModel] = []
        
        for recipient in recipients {
            if recipient.code == recipientProfileNotFoundCode {
                let viewModel = ContactViewModel(contactName: recipient.recipientID, displayingInfo: nil, canSelect: false, isSelected: false)
                profileNotFoundViewModels.append(viewModel)
            } else if recipient.code == existingRecipientCode {
                let viewModel = ContactViewModel(contactName: recipient.recipientID, displayingInfo: nil, canSelect: false, isSelected: false)
                existingMembersViewModels.append(viewModel)
            }
        }
        
        showRecipientsAlertControllersIfNeeded(existingMembersViewModels, profileNotFoundViewModels: profileNotFoundViewModels)
    }
    
    private func showRecipientsAlertControllersIfNeeded(_ existingMembersViewModels: [ContactViewModel], profileNotFoundViewModels: [ContactViewModel]) {
        if existingMembersViewModels.count > 0 {
            let addMemberDisplayingViewModel = AddMemberDisplayingInfoViewModel.existingMembersDisplayingViewModel(existingMembersViewModels)
            self.router?.showAddMemberAlertViewController(fromViewController: self, withAnimation: true, viewModel: addMemberDisplayingViewModel, withCompletionHandler: { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            })
        } else {
            if profileNotFoundViewModels.count == 0 { return }
            
            let addMemberDisplayingViewModel = AddMemberDisplayingInfoViewModel.profilesNotFoundDisplayingViewModel(profileNotFoundViewModels)
            self.router?.showAddMemberAlertViewController(fromViewController: self, withAnimation: true, viewModel: addMemberDisplayingViewModel, withCompletionHandler: { [unowned self] in
                self.dismiss(animated: true, completion: nil)
                
                if existingMembersViewModels.count == 0 { return }
                
                let addMemberDisplayingViewModel = AddMemberDisplayingInfoViewModel.existingMembersDisplayingViewModel(existingMembersViewModels)
                self.router?.showAddMemberAlertViewController(fromViewController: self, withAnimation: true, viewModel: addMemberDisplayingViewModel, withCompletionHandler: { [unowned self] in
                    self.dismiss(animated: true, completion: nil)
                })
            })
        }
    }
    
    private func convertAccount(_ account: Recipient, users: [ShareUser]) -> ContactViewModel? {
        for user in users {
            if user.userID == account.recipientID {
                let viewModel = ContactViewModel(contactName: user.username, displayingInfo: nil, canSelect: true, isSelected: true)
                return viewModel
            }
        }
        
        return nil
    }
    
    func configureHeaderBarForSharing() {
        headerBar?.rightButtonText = "Select"
        headerBar?.rightButtonEnable = true
        headerBar?.rightButtonImage = nil
        
        headerBar?.secureButtonHide = true
    }
    
    internal func configureNotificationsIcon() {
        
        self.headerBar?.nearToLeftButtonImage = UIImage(named: "icn_notifications_bell")

        if isSharing {
            self.headerBar?.nearToLeftButtonHide = true
        }
        else {
            self.headerBar?.nearToLeftButtonHide = false
        }
    }
}
