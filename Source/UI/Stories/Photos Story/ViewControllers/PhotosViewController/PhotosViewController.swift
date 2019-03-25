//
//  PhotosViewController.swift
//  MyMobileED
//
//  Created by Admin on 1/18/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import MBProgressHUD
import ExpandingMenu

protocol PhotosViewControllerDelegate: class {
    func photosNotaddedForUnverifiedUser(viewController:PhotosViewController,alertManager:AlertsManager,currentUser:User)
}


class PhotosViewController: BaseContentViewController, CameraViewControllerDelegate, PhotosDataSourceDelegate, NotificationManagerDelegate, EditPhotoViewControllerDelegate, FullScreenPhotoViewControllerDelegate, MembersDataSourceDelegate, PhotoLibraryViewControllerDelegate {
    
    enum ProgressViewState {
        case start
        case proceed(currentNumber: Int, totalCount: Int)
        case finished
        case abort
    }
    
    // MARK: -
    // MARK: Properties
    var delegate:PhotosViewControllerDelegate?
    var photoUploadCoordinator: PhotoCoordinatorProtocol!
    var photosProvider: PhotosProviderProtocol?
    var notificationManager: NotificationManagerProtocol?
    var ownership: PhotosOwnership = .my
    var photosDataSource: PhotosDataSourceProtocol?
    var foldersNavigationDataSource: FoldersNavigationDataSourceProtocol?
    var shouldShowConnectionAlert: Bool = false
    var isOpenedFromNotificationsFeed = false
    
    // MARK: Photos
    @IBOutlet weak var allPhotosSearchBar: UIView!
    @IBOutlet weak var myPhotosSearchBar: UIView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var noResultView: NoResultView!
    @IBOutlet weak var headerTitleButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    
    // MARK: Members
    private let membersViewMinimunHeight: CGFloat = 50.0
    private let membersTopOffset: CGFloat = 116.0
    private let disableContentAlpha: CGFloat = 0.5
    fileprivate var isDisplayView: Bool = true
    
    fileprivate let dispatchGroup: DispatchGroup = DispatchGroup()
    fileprivate var photosInUploadQueue: [Photo] = []
    fileprivate var currentUploadedPhotoNumber: Int = 0
    fileprivate var progressAnimationDuration = 0.6
    
    @IBOutlet weak var membersView: UIView!
    @IBOutlet weak var membersViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var membersTableView: UITableView!
    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var membersContentView: UIView!
    @IBOutlet weak var membersContentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var progressView: UIProgressView!
    fileprivate var cameraMenu: ExpandingMenuButton!
    
    var membersDataSource: MembersDataSourceProtocol?
    var membersViewGestureRecognizer: UITapGestureRecognizer!
    var shouldShowMembersView: Bool = false
    
    // MARK: -
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurePhotosDataSource()
        configureViewNotification()
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadMembersIfNeeded()
        reloadContentIfNeeded()
        configureView()
        isDisplayView = true
        
        configureStatusBar()
        
        let isMyFolder = photosDataSource!.canEditFolderContent()
        
        photosDataSource?.isMyFolder = isMyFolder
        
        self.configureExpandingMenu()
        
        showBluetoothConnectionAlertIfNeeded()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isDisplayView = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if popUpView != nil && popUpView?.superview == self.view {
            self.hideView(popUpView!)
        }
        
        NotificationCenter.default.removeObserver(self)
        
        super.viewWillDisappear(animated)
    }
    
    // MARK: -
    // MARK: Private
    private func configureProgressView(with state: PhotosViewController.ProgressViewState) {
        
        switch state {
        case .start:
            self.progressView.isHidden = false
            self.progressView.progress = 0.1 // minimum progress
            
        case .proceed(let currentNumber, let totalCount):
            print(Float(currentNumber) / Float(totalCount))
            progressView.isHidden = false
            
            if currentNumber == totalCount {
                self.configureProgressView(with: .finished)
                return
            }
            
            let progress = Float(currentNumber) / Float(totalCount)
            progressView.setProgress(progress, animated: true)
            
        case .finished:
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                self.progressView.progress = 0
                self.progressView.isHidden = true
            })
            self.progressView.setProgress(1.0, animated: true)
            CATransaction.commit()
            
        case .abort:
            self.progressView.progress = 0
            self.progressView.isHidden = true
        }
    }
    
    private func configureView() {
        switch ownership {
        case .group(let group):
            setupMembersConstraintsConstant(membersViewMinimunHeight)
            configureHeaderBarWithGroup(group)
            
            configureSelectedContactsViewGestureRecognizer()
            configureMembersDataSource()
            
            break
        case .all, .allInFolder, .my:
            setupMembersConstraintsConstant(0)
            configureHeaderBarWithFolder()
            
            break
        }
    }
    
    private func reloadContentIfNeeded() {
        selectedFolder = foldersNavigationDataSource?.peek()
        
        photosDataSource?.changeOwnershipFilter(ownership)
        photosDataSource?.reloadContent(forFolder: selectedFolder)
    }
    
    private func reloadMembersIfNeeded() {
        if case .group(_) = ownership {
            DispatchQueue.main.async {
                self.reloadView(animated: false)
                self.membersDataSource?.fetchMembers()
            }
        }
    }
    
    private func setupMembersConstraintsConstant(_ constant: CGFloat) {
        membersContentViewHeightConstraint.constant = constant
        membersViewHeightConstraint.constant = constant
        tableViewTopConstraint.constant = constant
    }
    
    private func configureStatusBar() {
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    private func showBluetoothConnectionAlertIfNeeded() {
        if bluetoothManager?.isConnected() == false && shouldShowConnectionAlert {
            shouldShowConnectionAlert = false
            
            self.tableViewBottomConstraint.constant = 0
            self.showUnsecureConnectionView(withConnectionState: .noCaseConnection, completionBlock: {
                self.router?.showBluetoothViewController(fromViewController: self, withAnimation: true)
            })
        }
    }
    
    private func configureHeaderBarWithFolder() {
        let isAllPhotos = (ownership == .all)
        
        var parentFolderTitle = "MY PHOTOS"
        var rightButtonImage = UIImage(named: "profile-icon")
        
        if let folderTitle = selectedFolder?.title {
            parentFolderTitle = folderTitle
        }
        
        if isAllPhotos {
            parentFolderTitle = "ALL PHOTOS"
        } else {
            rightButtonImage = UIImage(named: "navigation-folder-icon")
            parentFolderTitle = parentFolderTitle.uppercased()
        }
        
        headerTitleButton?.setTitle(parentFolderTitle, for: .normal)
        headerBar?.rightButtonImage = rightButtonImage
        
        self.configureViewNotification()
        
        if isDisplayView {
            UIApplication.shared.statusBarStyle = .lightContent
            UIApplication.shared.isStatusBarHidden = false
        }
        
        if foldersNavigationDataSource!.fetchAll().count > 1 {
            headerBar?.leftButtonImage = UIImage(named: "back-arrow")
            headerBar?.leftButtonHide = false
        }
        
        if self.isOpenedFromNotificationsFeed {
            
            headerBar?.leftButtonImage = UIImage(named: "back-arrow")
            headerBar?.leftButtonHide = false
        }
    }
    
    private func configureHeaderBarWithGroup(_ group: Group) {
        if let folderTitle = selectedFolder?.title {
            headerTitleButton?.setTitle(folderTitle.uppercased(), for: .normal)
        } else {
            headerTitleButton?.setTitle(group.title!.uppercased(), for: .normal)
        }
        
        if isSharing {
            configureHeaderBarForSharing()
            disableActions()
            headerTitleButton?.setImage(nil, for: .normal)
        } else {
            headerBar?.rightButtonImage = UIImage(named: "navigation-folder-icon")
        }
        
        headerBar?.leftButtonImage = UIImage(named: "back-arrow")
        headerBar?.leftButtonHide = false
    }
    
    private func disableActions() {
        searchTextField.isEnabled = false
        searchTextField.alpha = disableContentAlpha
        
        filterButton.isEnabled = false
        filterButton.alpha = disableContentAlpha
    }
    
    private func configurePhotosDataSource() {
        let currentUser = userManager?.currentUser
        let dataSource = PhotosDataSource(tableView: self.tableView,
                                          networkManager: networkManager!,
                                          delegate: self,
                                          router: self.router!,
                                          photosProvider: photosProvider!,
                                          currentUser: currentUser!,
                                          alertsManager: alertsManager as! AlertsManager,
                                          viewContoller:self,
                                          isEnabledContent: !isSharing)
        photosDataSource = dataSource
    }
    
    private func configureMembersDataSource() {
        guard let group = ownership.associatedValue() as! Group? else { return }
        
        let dataSource = MembersDataSource(tableView: membersTableView,
                                           networkManager: networkManager!,
                                           userManager: userManager!,
                                           delegate: self,
                                           group: group)
        membersDataSource = dataSource
    }
    
    private func configureViewNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive(_:)), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc private func didBecomeActive(_ notification: Notification) {
        if photosDataSource?.ownershiFilter() == .all {
            photosDataSource?.reloadContent(forFolder: selectedFolder)
        }
    }
    
    private func showFolderOptionsAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let isAllInFolderOwnership = (ownership == .allInFolder)
        let viewAllActionTitle = (isAllInFolderOwnership ? "View All Folders" : "View All Photos")
        let viewAllAction = UIAlertAction(title: viewAllActionTitle, style: .default, handler: { (action) in
            let changedOwnership: PhotosOwnership = (isAllInFolderOwnership ? .my : .allInFolder)
            
            self.ownership = changedOwnership
            self.photosDataSource?.changeOwnershipFilter(changedOwnership)
            self.photosDataSource?.reloadContent(forFolder: self.selectedFolder)
        })
        
        let newFolderAction = UIAlertAction(title: "New Folder", style: .default, handler: { (action) in self.showNewFolderAlertController() })
        
        let shareActions = UIAlertAction(title: "Share Folder", style: .default) { (action) in self.shareFolder(self.selectedFolder!) }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(viewAllAction)
        alert.addAction(cancelAction)
        
        if photosDataSource!.canEditFolderContent() && ownership == .my {
            alert.addAction(newFolderAction)
            
            if !isRootFolder() {
                alert.addAction(shareActions)
            }
        }
        else if case .group(let group) = self.ownership,
            self.userManager?.currentUser?.userID == group.ownerId {
            
            let editFolderAction = UIAlertAction(title: "Edit Group", style: .default, handler: { (action) in self.showEditAlertController(for: group) })
            let deleteFolderAction = UIAlertAction(title: "Delete Group", style: .default, handler: { (action) in self.showDeleteAlertController(for: group) })
            
            alert.addAction(editFolderAction)
            alert.addAction(deleteFolderAction)
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    private func shareFolder(_ folder: Folder) {
        alertsManager?.showShareAlertController(forViewController: self, withShareToUserCallback: { () -> (Void) in
            self.shareFolderToUser(folder)
        }, shareToDoximityCallback: { () -> (Void) in
            self.shareToDoximity { self.shareFolderToDoximity(folder) }
        }, shareByEmailCallback: { () -> (Void) in
            self.shareFolderByEmail(folder)
        }, shareByTextCallback: { () -> (Void) in
            self.shareFolderByText(folder)
        }, shareToGroupCallback: { [unowned self] () -> (Void) in
            self.router?.showShareGroupsViewController(fromViewController: self, withAnimation: true, sharingCompletionHandler: { [unowned self] (group) in
                self.networkManager?.shareFolder(folder, toGroup: group, successBlock: { [unowned self](response) -> (Void) in
                    DispatchQueue.main.async {
                        self.navigationController?.popToViewController(self, animated: true)
                        self.photosDataSource?.didShareContent()
                        self.alertsManager?.showSuccessSharedContentAlertController(forViewController: self)
                    }
                    }, failureBlock: { [unowned self] (error) -> (Void) in
                        DispatchQueue.main.async {
                            if error.code == 403 {
                                self.presentAlert(withMessage: "To share a folder in the group, you should be part of that group.")
                            }
                        }
                })
            })
        })
    }
    
    private func shareFolderToUser(_ folder: Folder) {
        let sharingCompletionHandler: (([ShareUser], UIViewController) -> (Void)) = { [unowned self] (users, presenting) -> (Void) in
            self.networkManager?.shareFolderToUser(folder, forUsers: users, successBlock: { [unowned self] (response) -> (Void) in
                self.photosDataSource?.didShareContent()
                self.dismiss(animated: true, completion: nil)
                self.alertsManager?.showSuccessSharedFolderAlertController(forViewController: self, isMultiple: users.count > 1)
                }, failureBlock: { (error) -> (Void) in
                    DispatchQueue.main.async { self.presentAlert(withMessage: error.message) }
            }
            )}
        
        let alertSharingHandler: (([ShareUser], UIViewController) -> (Void)) = { [unowned self] (users, presenting) -> (Void) in
            self.navigationController?.popViewController(animated: true)
            self.router?.showShareUsersAlertViewController(fromViewController: self,
                                                           withAnimation: true,
                                                           viewModel: UserDisplayingInformationViewModel.shareToInstitutionViewModel(),
                                                           forSharingDestination: .user,
                                                           users: users,
                                                           shareCallback: sharingCompletionHandler)
        }
        
        router?.showShareViewController(fromViewController: self,
                                        withAnimation: true,
                                        shareCompletionHandler: alertSharingHandler,
                                        cancelSharingCompletionHandler: { () -> (Void) in
                                            self.navigationController?.popViewController(animated: true)
        },
                                        doximityAuthorizationFailureBlock: nil,
                                        forSharingDestination: .user)
    }
    
    private func sharePhotoToUser(_ photo: Photo) {
        let sharingCompletionHandler: (([ShareUser], UIViewController) -> (Void)) = { [unowned self] (users, presenting) -> (Void) in
            self.networkManager?.sharePhotoToUser(photo, forUsers: users, successBlock: { [unowned self] (response) -> (Void) in
                self.photosDataSource?.didShareContent()
                self.dismiss(animated: true, completion: nil)
                self.alertsManager?.showSuccessSharedPhotoAlertController(forViewController: self, isMultiple: users.count > 1)
                }, failureBlock: { (error) -> (Void) in
                    DispatchQueue.main.async { self.presentAlert(withMessage: error.message) }
            }
            )}
        
        let alertSharingHandler: (([ShareUser], UIViewController) -> (Void)) = { [unowned self] (users, presenting) -> (Void) in
            self.navigationController?.popViewController(animated: true)
            self.router?.showShareUsersAlertViewController(fromViewController: self,
                                                           withAnimation: true,
                                                           viewModel: UserDisplayingInformationViewModel.shareToInstitutionViewModel(),
                                                           forSharingDestination: .user,
                                                           users: users,
                                                           shareCallback: sharingCompletionHandler)
        }
        
        router?.showShareViewController(fromViewController: self, withAnimation: true,
                                        shareCompletionHandler: alertSharingHandler,
                                        cancelSharingCompletionHandler: { () -> (Void) in
                                            DispatchQueue.main.async { self.navigationController?.popViewController(animated: true) }
        },
                                        doximityAuthorizationFailureBlock: nil,
                                        forSharingDestination: .user)
    }
    
    private func shareFolderToDoximity(_ folder: Folder) {
        let sharingCompletionHandler: (([ShareUser], UIViewController) -> (Void)) = { [unowned self] (users, presenting) -> (Void) in
            self.networkManager?.shareFolderToDoximityUser(folder, forUsers: users, successBlock: { (response) -> (Void) in
                DispatchQueue.main.async {
                    self.photosDataSource?.didShareContent()
                    self.dismiss(animated: true, completion: nil)
                    self.alertsManager?.showSuccessSharedPhotoAlertController(forViewController: self, isMultiple: users.count > 1)
                }
            }, failureBlock: { (error) -> (Void) in
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
        
        let alertSharingHandler: (([ShareUser], UIViewController) -> (Void)) = { [unowned self] (users, presenting) -> (Void) in
            self.navigationController?.popViewController(animated: true)
            self.router?.showShareUsersAlertViewController(fromViewController: self,
                                                           withAnimation: true,
                                                           viewModel: UserDisplayingInformationViewModel.shareToDoximityViewModel(),
                                                           forSharingDestination: .doximity,
                                                           users: users,
                                                           shareCallback: sharingCompletionHandler)
        }
        
        router?.showShareViewController(fromViewController: self, withAnimation: true,
                                        shareCompletionHandler: alertSharingHandler,
                                        cancelSharingCompletionHandler: { () -> (Void) in
                                            DispatchQueue.main.async { self.navigationController?.popViewController(animated: true) }
        },
                                        doximityAuthorizationFailureBlock: { [weak self] showShareViewController in
                                            
                                            guard let strongSelf = self else { return }
                                            
                                            DispatchQueue.main.async { strongSelf.navigationController?.popViewController(animated: true) }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                                                
                                                strongSelf.router?.showDoximityUpdateTokenAuthorization(from: strongSelf, animated: true, resultBlock: { [weak self] (result) in
                                                    
                                                    guard let strongSelf = self else { return }
                                                    
                                                    switch result {
                                                    case .success: strongSelf.shareFolderToDoximity(folder)
                                                    default: break
                                                    }
                                                })
                                            })
            },
                                        forSharingDestination: .doximity)
    }
    
    private func shareFolderByEmail(_ folder: Folder) {
        let screenViewModel = ShareContactsAlertViewControllerViewModel(actionTitle: "Share",
                                                                        userDisplayingInformationViewModel: UserDisplayingInformationViewModel.shareBySMSViewModel(),
                                                                        displayingInfo: .emails)
        
        router?.showShareContactsAlertViewController(fromViewController: self,
                                                     withAnimation: true,
                                                     viewModel: screenViewModel,
                                                     shareCallback: { [unowned self] (textValues, viewController) -> (Void) in
                                                        self.networkManager?.shareFolder(folder, byEmails: textValues, successBlock: { (response) -> (Void) in
                                                            DispatchQueue.main.async {
                                                                viewController.dismiss(animated: true, completion: nil)
                                                                self.photosDataSource?.didShareContent()
                                                                self.alertsManager?.showSuccessSharedByEmailAlertController(forViewController: self, isMultiple: textValues.count > 1)
                                                            }
                                                        }, failureBlock: { (error) -> (Void) in
                                                    DispatchQueue.main.async {
                                                                if error.code == 403 {
                                                                    self.presentAlert(withMessage: "To share a photo in the group, you should be part of that group.")
                                                                }else {
                                                                    self.presentAlert(withMessage: error.message)
                                                                }
                                                            }
                                                        })
        })
    }
    
    private func shareFolderByText(_ folder: Folder) {
        
        let screenViewModel = ShareContactsAlertViewControllerViewModel(actionTitle: "Share",
                                                                        userDisplayingInformationViewModel: UserDisplayingInformationViewModel.shareBySMSViewModel(),
                                                                        displayingInfo: .phones)
        
        router?.showShareContactsAlertViewController(fromViewController: self,
                                                     withAnimation: true,
                                                     viewModel: screenViewModel,
                                                     shareCallback: { [unowned self] (textValues, viewController) -> (Void) in
                                                        self.networkManager?.shareFolder(folder, byTexts: textValues, successBlock: { (response) -> (Void) in
                                                            DispatchQueue.main.async {
                                                                viewController.dismiss(animated: true, completion: nil)
                                                                self.photosDataSource?.didShareContent()
                                                                self.alertsManager?.showSuccessSharedByTextAlertController(forViewController: self, isMultiple: textValues.count > 1)
                                                            }
                                                        }, failureBlock: { (error) -> (Void) in
                                                            DispatchQueue.main.async { self.presentAlert(withMessage: error.message) }
                                                        })
        })
    }
    
    private func sharePhotoToDoximity(_ photo: Photo) {
        let sharingCompletionHandler: (([ShareUser], UIViewController) -> (Void)) = { [unowned self] (users, presenting) -> (Void) in
            self.networkManager?.sharePhotoToDoximityUser(photo, forUsers: users, successBlock: { [unowned self] (response) -> (Void) in
                DispatchQueue.main.async {
                    self.photosDataSource?.didShareContent()
                    self.dismiss(animated: true, completion: nil)
                    self.alertsManager?.showSuccessSharedPhotoAlertController(forViewController: self, isMultiple: users.count > 1)
                }
                }, failureBlock: { [unowned self] (error) -> (Void) in
                    if error.code == noDoximityUserExistErrorCode {
                        DispatchQueue.main.async {
                            presenting.dismiss(animated: true, completion: {
                                self.showInviteAlert(forViewController: self)
                            })
                        }
                    }
                    else {
                        DispatchQueue.main.async { self.alertsManager?.showErrorAlert(forViewController: self, withMessage: error.message) }
                    }
                }
            )}
        
        let alertSharingHandler: (([ShareUser], UIViewController) -> (Void)) = { [unowned self] (users, presenting) -> (Void) in
            self.navigationController?.popViewController(animated: true)
            self.router?.showShareUsersAlertViewController(fromViewController: self,
                                                           withAnimation: true,
                                                           viewModel: UserDisplayingInformationViewModel.shareToDoximityViewModel(),
                                                           forSharingDestination: .doximity,
                                                           users: users,
                                                           shareCallback: sharingCompletionHandler)
        }
        
        router?.showShareViewController(fromViewController: self, withAnimation: true,
                                        shareCompletionHandler: alertSharingHandler,
                                        cancelSharingCompletionHandler: { () -> (Void) in
                                            DispatchQueue.main.async { self.navigationController?.popViewController(animated: true) }
        },
                                        doximityAuthorizationFailureBlock: { [weak self] showShareViewController in
                                            
                                            guard let strongSelf = self else { return }
                                            
                                            DispatchQueue.main.async { strongSelf.navigationController?.popViewController(animated: true) }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                                                
                                                strongSelf.router?.showDoximityUpdateTokenAuthorization(from: strongSelf, animated: true, resultBlock: { [weak self] (result) in
                                                    
                                                    guard let strongSelf = self else { return }
                                                    
                                                    switch result {
                                                    case .success: strongSelf.sharePhotoToDoximity(photo)
                                                    default: break
                                                    }
                                                })
                                            })
            },
                                        forSharingDestination: .doximity)
    }
    
    private func sharePhotoByEmail(_ photo: Photo) {
        
        let screenViewModel = ShareContactsAlertViewControllerViewModel(actionTitle: "Share",
                                                                        userDisplayingInformationViewModel: UserDisplayingInformationViewModel.shareByEmailsViewModel(),
                                                                        displayingInfo: .emails)
        
        router?.showShareContactsAlertViewController(fromViewController: self,
                                                     withAnimation: true,
                                                     viewModel: screenViewModel,
                                                     shareCallback: { [unowned self] (textValues, viewController) -> (Void) in
                                                        self.networkManager?.sharePhoto(photo, byEmails: textValues, successBlock: { (response) -> (Void) in
                                                            DispatchQueue.main.async {
                                                                viewController.dismiss(animated: true, completion: nil)
                                                                self.photosDataSource?.didShareContent()
                                                                self.alertsManager?.showSuccessSharedByEmailAlertController(forViewController: self, isMultiple: textValues.count > 1)
                                                            }
                                                        }, failureBlock: { (error) -> (Void) in
                                                            DispatchQueue.main.async { self.presentAlert(withMessage: error.message) }
                                                        })
        })
    }
    
    private func sharePhotoByText(_ photo: Photo) {
        
        let screenViewModel = ShareContactsAlertViewControllerViewModel(actionTitle: "Share",
                                                                        userDisplayingInformationViewModel: UserDisplayingInformationViewModel.shareBySMSViewModel(),
                                                                        displayingInfo: .phones)
        
        router?.showShareContactsAlertViewController(fromViewController: self,
                                                     withAnimation: true,
                                                     viewModel: screenViewModel,
                                                     shareCallback: { [unowned self] (textValues, viewController) -> (Void) in
                                                        self.networkManager?.sharePhoto(photo, byTexts: textValues, successBlock: { (response) -> (Void) in
                                                            DispatchQueue.main.async {
                                                                viewController.dismiss(animated: true, completion: nil)
                                                                self.photosDataSource?.didShareContent()
                                                                self.alertsManager?.showSuccessSharedByTextAlertController(forViewController: self, isMultiple: textValues.count > 1)
                                                            }
                                                        }, failureBlock: { (error) -> (Void) in
                                                            DispatchQueue.main.async { self.presentAlert(withMessage: error.message) }
                                                        })
        })
    }
    
    fileprivate func configureExpandingMenu() {
        
        let menuButtonSize: CGSize = CGSize(width: 60.0, height: 60.0)
        let menuImageSize: CGSize = CGSize(width: 35.0, height: 35.0)
        self.delegate?.photosNotaddedForUnverifiedUser(viewController: self, alertManager: alertsManager as! AlertsManager, currentUser: (userManager?.currentUser)!)
        
        let menuButton = ExpandingMenuButton(frame: CGRect(origin: CGPoint.zero, size: menuButtonSize),
                                             image: UIImage(named: "chooser-button-tab")!,
                                             rotatedImage: UIImage(named: "chooser-button-tab-highlighted")!)
        
        
        menuButton.willPresentMenuItems = { (menu) -> Void in
            print("MenuItems will present.")
            if self.userManager?.currentUser?.userRole == "unverified", case .group(_) = self.ownership {
                self.alertsManager?.showUnVerifiedAlertController(forViewController: self, withOkayCallback: { () -> (Void) in
                    
                }, withOpenCallback: { () -> (Void) in
                    self.verifyNow(router: (self.router)!)
                })
            } else if self.userManager?.currentUser?.userRole == "in_progress", case .group(_) = self.ownership {
                self.alertsManager?.showInReviewAlertController(forViewController: self, withOkayCallback: { () -> (Void) in
                    
                })
            }
        }
        
        self.view.addSubview(menuButton)
        let btmPadding: CGFloat = 24.0
        let rightPadding: CGFloat = 24.0
        
        menuButton.center = CGPoint(x: self.view.frame.maxX - (rightPadding + menuButtonSize.width / 2),
                                    y: self.view.frame.maxY - (btmPadding + menuButtonSize.height / 2))
        
        let cameraItem = ExpandingMenuItem(size: menuButtonSize,
                                           title: "",
                                           image: UIImage(named: "chooser-moment-icon-camera")!,
                                           highlightedImage: UIImage(named: "chooser-moment-icon-camera-highlighted")!,
                                           backgroundImage: UIImage(named: "chooser-moment-button"),
                                           backgroundHighlightedImage: UIImage(named: "chooser-moment-button-highlighted"),
                                           itemTapped: { [weak self] () -> Void in
                                            
                                            guard let strongSelf = self else { return }
                                            strongSelf.makePhoto()
        })
        
        let photoLibraryBgImage = self.circleImage(with: menuImageSize, color: UIColor.gray)
        let photoLibraryItem = ExpandingMenuItem(size: menuButtonSize,
                                                 title: "",
                                                 image: UIImage(named: "upload")!,
                                                 highlightedImage: UIImage(named: "upload")!,
                                                 backgroundImage: photoLibraryBgImage,
                                                 backgroundHighlightedImage: photoLibraryBgImage,
                                                 itemTapped: { [weak self] () -> Void in
                                                    
                                                    guard let strongSelf = self else { return }
                                                    
                                                    let isMyFolder = strongSelf.photosDataSource!.canEditFolderContent()
                                                    var selectedGroup: Group? = nil
                                                    
                                                    if case .group(let group) = strongSelf.ownership {
                                                        selectedGroup = group
                                                    }
                                                    
                                                    strongSelf.router?.showPhotoLibraryViewController(with: strongSelf,
                                                                                                      inFolder: (isMyFolder ? strongSelf.selectedFolder : nil),
                                                                                                      group: selectedGroup,
                                                                                                      fromViewController: strongSelf,
                                                                                                      animated: false)
        })
        if userManager?.currentUser?.userRole != "verified" {
            switch ownership {
            case .group(_): break
            case .all, .allInFolder, .my:
                menuButton.addMenuItems([cameraItem, photoLibraryItem])
            }
        } else {
            menuButton.addMenuItems([cameraItem, photoLibraryItem])
        }
        menuButton.bottomViewAlpha = 0.2
        menuButton.menuItemMargin = 0
        
        self.cameraMenu = menuButton
        let isMyFolder = photosDataSource!.canEditFolderContent()
        self.cameraMenu.isHidden = self.isSharing
    }
    
    fileprivate func circleImage(with size: CGSize, color: UIColor?) -> UIImage {
        
        let rect = CGRect(origin: CGPoint.zero, size: size)
        let resultColor = color ?? UIColor.white
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let contextRef = UIGraphicsGetCurrentContext()
        contextRef?.setFillColor(resultColor.cgColor)
        contextRef?.fillEllipse(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    fileprivate func makePhoto() {
        let isMyFolder = photosDataSource!.canEditFolderContent()
        var selectedGroup: Group? = nil
        
        if case .group(let group) = ownership {
            selectedGroup = group
        }
        
        if bluetoothManager?.isConnected() == true {
            bluetoothManager?.sendSignalOpen()
            router?.showCameraViewController(fromViewController: self,
                                             withAnimation: true,
                                             inFolder: (isMyFolder ? selectedFolder : nil),
                                             group: selectedGroup,
                                             delegate: self)
        }
        else {
            tableViewBottomConstraint.constant = 0
            sendCaseDisconnectedRequest()
            
            showUnsecureConnectionView(withConnectionState: .unsecureConnection, completionBlock: { [unowned self] in
                self.router?.showBluetoothViewController(fromViewController: self, withAnimation: true)
            })
        }
    }
    
    fileprivate func upload(new photo: Photo, resultBlock: @escaping (PhotoCoordinatorResult) -> ()) {
        
        if self.photosInUploadQueue.isEmpty {
            self.configureProgressView(with: .start)
        }
        
        self.photosInUploadQueue.append(photo)
        
        self.dispatchGroup.enter()
        self.photoUploadCoordinator.uploadNewPhoto(photo: photo,
                                                   completion: { (result) in
                                                    
                                                    DispatchQueue.main.async {
                                                        
                                                        switch result {
                                                        case .uploaded:
                                                            let timestampString = DateHelper.stringDateFrom(Date())
                                                            let defaults = UserDefaults.standard
                                                            defaults.set(timestampString, forKey: "LastUpdateTimestamp")
                                                            
                                                            self.currentUploadedPhotoNumber += 1
                                                            self.configureProgressView(with: .proceed(currentNumber: self.currentUploadedPhotoNumber,
                                                                                                      totalCount: self.photosInUploadQueue.count))
                                                            
                                                        case .cached: fallthrough
                                                        case .failed: self.configureProgressView(with: .abort)
                                                        }
                                                    }
                                                    
                                                    resultBlock(result)
                                                    self.dispatchGroup.leave()
        })
        
        dispatchGroup.notify(
            queue: .main, execute: {
                
                print("complete 👍")
                self.photosInUploadQueue.removeAll()
                self.currentUploadedPhotoNumber = 0
        })
    }
    
    // MARK: Members views
    
    private func configureSelectedContactsViewGestureRecognizer() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectedViewDidTap(_:)))
        
        membersContentView.addGestureRecognizer(gestureRecognizer)
        membersViewGestureRecognizer = gestureRecognizer
    }
    
    @objc private func selectedViewDidTap(_ gestureRecognizer: UITapGestureRecognizer) {
        shouldShowMembersView = !shouldShowMembersView
        reloadView(animated: true)
    }
    
    func reloadView(animated: Bool) {
        guard case .group(let group) = ownership else { return }
        
        let membersCount = group.usersCount
        let isNoMembers = (membersCount == 0)
        var text = ""
        
        if isNoMembers {
            membersLabel.textColor = UIColor(red: 93/255, green: 95/255, blue: 98/255, alpha: 1.0)
            text = "0 Members"
        } else {
            membersLabel.textColor = BaseColors.darkBlue.color()
            text = String(format: "%ld Member%@", membersCount, (membersCount == 1) ? "" : "s")
        }
        
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: animated ? 0.3 : 0) {
            self.configureViewLayout()
            self.view.layoutIfNeeded()
        }
        
        membersLabel.text = text
    }
    
    private func configureViewLayout() {
        if shouldShowMembersView {
            setupExpandedSelectedView()
        } else {
            setupCollapsedSelectedView()
        }
    }
    
    private func setupExpandedSelectedView() {
        let membersEstimatedViewHeight = membersDataSource!.contentHeight() + membersViewMinimunHeight
        
        let viewHeight = view.frame.height
        let isOverHeight = (membersTopOffset + membersEstimatedViewHeight) > viewHeight
        
        membersViewHeightConstraint.constant = isOverHeight ? viewHeight - membersView.frame.origin.y : membersEstimatedViewHeight
        membersContentView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1)
        
        arrowImageView.image = UIImage(named: "chevronUp")
    }
    
    private func setupCollapsedSelectedView() {
        membersViewHeightConstraint.constant = 50
        membersContentView.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        arrowImageView.image = UIImage(named: "chevronDown")
    }
    
    private func showRemoveMemberAlertController(withCompletionHandler completionHandler: @escaping () -> (Void)) {
        let alertController = UIAlertController(title: "Remove Group Member",
                                                message: "Are you sure you want to remove this user from the group? They will lose access to any shared content.",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            completionHandler()
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func showRemoveSelfAlertController() {
        let alertController = UIAlertController(title: "",
                                                message: "You are admin of group and can't remove self from the group.",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func showEditAlertController(for group: Group) {
        
        let handler: ((String) -> ()) = { [unowned self] (_ text: String) in
            
            self.networkManager?.editGroup(group,
                                           with: text,
                                           successBlock: { [unowned self] (response) -> (Void) in
                                            
                                            guard case .group(let group) = self.ownership else { return }
                                            group.title = text
                                            self.ownership = .group(group: group)
                                            self.configureHeaderBarWithGroup(group)
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
                                                    
                                                    strongSelf.navigationController?.popToRootViewController(animated: true)
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
    
    // MARK: Custom views
    
    private func showFilterView() {
        popUpView?.removeFromSuperview()
        
        if popUpView == nil || (popUpView as? FilterView) == nil {
            let filterHeight: CGFloat = FilterView.viewHeight()
            let yPosition = self.view.bounds.size.height - filterHeight
            let filterView = FilterView(frame: CGRect(x: 0, y: yPosition, width: self.view.bounds.size.width, height: filterHeight))
            filterView.setupViewState(withFilter: self.photosDataSource!.dateFilter())
            
            filterView.selectRowCallback = { (filter: PhotosFilterDate) in
                self.hideView(filterView)
                
                if filter == .custom {
                    self.showDateFilterView()
                    return
                }
                
                if filter != self.photosDataSource?.dateFilter() {
                    self.photosDataSource?.changeDateFilter(filter)
                    self.photosDataSource?.reloadContent(forFolder: self.selectedFolder)
                }
            }
            
            filterView.closeCallback = { self.hideView(filterView) }
            
            self.popUpView = filterView
        }
        
        popUpView?.show(fromView: self.view)
        tableViewBottomConstraint.constant = FilterView.viewHeight()
    }
    
    private func showDateFilterView() {
        popUpView?.removeFromSuperview()
        
        let dateFilterHeight: CGFloat = DateFilterView.viewHeight()
        let yPosition = self.view.bounds.height - dateFilterHeight
        let dateFilterView = DateFilterView(frame: CGRect(x: 0, y: yPosition, width: self.view.bounds.size.width, height: dateFilterHeight))
        
        if photosDataSource?.dateFilter() == .custom {
            if let startDate = photosDataSource?.startCustomDate(), let endDate = photosDataSource?.endCustomDate() {
                dateFilterView.setupStartDate(startDate, endDate: endDate)
            }
        }
        
        dateFilterView.cancelButtonTapCallback = {
            self.hideView(self.popUpView!)
        }
        
        dateFilterView.doneButtonTapCallback = { (startDate: Date, endDate: Date) in
            self.photosDataSource?.changeCustomDateFilter(withStartDate: startDate, betweenEndDate: endDate)
            self.photosDataSource?.reloadContent(forFolder: self.selectedFolder)
            self.hideView(self.popUpView!)
        }
        
        self.popUpView = dateFilterView
        
        popUpView?.show(fromView: self.view)
        tableViewBottomConstraint.constant = DateFilterView.viewHeight()
    }
    
    private func showNotificationView() {
        if let popUp = popUpView {
            if popUp.superview != nil {
                self.hideView(popUp)
            }
        }
        
        if popUpView == nil || (popUpView as? NotificationView) == nil {
            let popUpHeight: CGFloat = NotificationView.viewHeight()
            let yPosition = self.view.bounds.height - popUpHeight
            let notificationPopUp = NotificationView(frame: CGRect(x: 0, y: yPosition, width: self.view.bounds.size.width, height: popUpHeight))
            
            notificationPopUp.buttonDoneTapCallback = {
                self.hideView(self.popUpView!)
            }
            
            self.popUpView = notificationPopUp
        }
        
        popUpView?.show(fromView: self.view)
        tableViewBottomConstraint.constant = NotificationView.viewHeight()
    }
    
    private func hideView(_ popView: PopUpView) {
        popView.hideView(fromView: self.view)
        tableViewBottomConstraint.constant = 0
    }
    
    private func performNavigation(to folder: Folder?) {
        
        // it's strange logic, but if Folder == nil that means a selected folder is root folder
        guard let requiredFolder = folder
            else {
                self.foldersNavigationDataSource?.popToRoot()
                
                switch ownership {
                case .group(_): break
                case .all, .allInFolder, .my:
                    router?.popPhotosViewController(self, withAnimation: true)
                    photosDataSource?.changeOwnershipFilter(.my)
                }
                
                return
        }
        
        guard let requiredNavidationDataSourse = self.foldersNavigationDataSource,
            requiredFolder.folderID != self.selectedFolder?.folderID
            else { return }
        
        requiredNavidationDataSourse.popToRoot()
        
        requiredNavidationDataSourse.push(requiredFolder)
        self.router?.showPhotosViewController(fromViewController: self,
                                              withAnimation: true,
                                              with: self.ownership,
                                              isEnableContent: !self.isSharing)
    }
    
    override func showPurchaseCaseView() {
        super.showPurchaseCaseView()
        
        tableViewBottomConstraint.constant = 0
    }
    
    // MARK: - Actions
    @IBAction func filterButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        
        if popUpView?.superview != self.view {
            showFilterView()
        } else {
            self.hideView(self.popUpView!)
        }
        
        self.tableView.setNeedsDisplay()
        self.tableView.layoutIfNeeded()
    }
    
    // MARK: NotificationManagerDelegate
    
    func notificationManagerDidReceiveRemoteNotification(_ notificationManager: NotificationManagerProtocol) {
        print("notificationManagerDidReceiveRemoteNotification")
        self.showNotificationView()
    }
    
    // MARK: PhotosDataSourceDelegate
    
    func photosDataSource(dataSource: PhotosDataSource, willEditPhoto photo: Photo, inCell cell: PhotoTableViewCell) {
        _ = photosProvider?.retrieveImage(byNodeID: photo.nodeID!, successBlock: { [unowned self] (image) in
            photo.image = image
            
            self.router?.showEditPhotoViewController(fromViewController: self, withAnimation: true, forPhoto: photo, in: self.selectedFolder, delegate: self)
            }, failureBlock: { (error) in
                print("Error = \(error)")
        })
    }
    
    func photosDataSource(dataSource: PhotosDataSource, willDeletePhoto photo: Photo, currentUser: User, inCell cell: PhotoTableViewCell) {
        
        if popUpView?.superview == self.view {
            self.hideView(popUpView!)
        }
            self.networkManager?.deletePhoto(photo, successBlock: { (response) -> (Void) in
                self.photosDataSource?.didDeletePhoto(inCell: cell)
                self.foldersNavigationDataSource?.needUpdateStack()
            }, failureBlock: { (error) -> (Void) in
                print("Error deleting row = '\(error.message)")
            })
    }
    
    func photosDataSource(dataSource: PhotosDataSource, willSharePhoto photo: Photo, inCell cell: PhotoTableViewCell) {
        alertsManager?.showShareAlertController(forViewController: self, withShareToUserCallback: { [unowned self] () -> (Void) in
            self.sharePhotoToUser(photo)
            }, shareToDoximityCallback: { [unowned self] () -> (Void) in
                self.shareToDoximity { self.sharePhotoToDoximity(photo) }
            }, shareByEmailCallback: { [unowned self] () -> (Void) in
                self.sharePhotoByEmail(photo)
            }, shareByTextCallback: { [unowned self] () -> (Void) in
                self.sharePhotoByText(photo)
            }, shareToGroupCallback: { [unowned self] () -> (Void) in
                self.router?.showShareGroupsViewController(fromViewController: self, withAnimation: true, sharingCompletionHandler: { [unowned self] (group) in
                    self.networkManager?.sharePhoto(photo, toGroup: group, successBlock: { [unowned self](response) -> (Void) in
                        DispatchQueue.main.async {
                            self.navigationController?.popToViewController(self, animated: true)
                            self.photosDataSource?.didShareContent()
                            self.alertsManager?.showSuccessSharedContentAlertController(forViewController: self)
                        }
                        }, failureBlock: {[unowned self] (error) -> (Void) in
                            DispatchQueue.main.async {
                                if error.code == 403 {
                                    self.presentAlert(withMessage: "To share a photo in the group, you should be part of that group.")
                                }else {
                                    self.presentAlert(withMessage: error.message)
                                }
                            }
                            
                    })
                })
        })
    }
    
    func photosDataSource(dataSource: PhotosDataSource, didTapPhoto photo: Photo, canEditPhoto canEdit: Bool) {
        
        self.router?.showFullScreenViewControler(fromViewController: self,
                                                 withAnimation: false,
                                                 currentPhoto: photo,
                                                 canEdit: canEdit,
                                                 in: self.selectedFolder,
                                                 photoDelegate: self)
    }
    
    private func isRootFolder() -> Bool {
        guard let folder = selectedFolder else { return true }
        
        return folder.folderID == nil
    }
    
    func photosDataSource(dataSource: PhotosDataSource, isEmptyPhotos isEmpty: Bool) {
        var descriptionText = ""
        
        if case .group(_) = ownership {
            descriptionText = "No content has been shared to this group."
        } else {
            descriptionText = "No file exists with the search criteria."
        }
        
        noResultView.descriptionText = descriptionText
        noResultView.isHidden = !isEmpty
    }
    
    func photosDataSourceNewPhotosAdded(dataSource: PhotosDataSource) {
        self.showNotificationView()
    }
    
    func selectFolderDataSource(_ sender: SelectFolderDataSourceProtocol, didTapFolder folder: Folder) {
        
        guard let requiredFoldersDataSourse = self.foldersNavigationDataSource else { return }
        requiredFoldersDataSourse.push(folder)
        
        if self.isOpenedFromNotificationsFeed {
            
            router?.showPhotosViewController(from: self,
                                             withAnimation: true,
                                             with: ownership,
                                             folderDataSourse: requiredFoldersDataSourse)
        }
        else {
            router?.showPhotosViewController(fromViewController: self,
                                             withAnimation: true,
                                             with: ownership,
                                             isEnableContent: !isSharing)
        }
    }
    
    func photosDataSource(dataSource: PhotosDataSource, didLoadedFolder folder: Folder?) {
        selectedFolder = folder
        
        guard let folder = folder else { return }
        foldersNavigationDataSource?.replaceTop(folder)
    }
    
    func selectFolderDataSource(_ sender: SelectFolderDataSourceProtocol, willDeleteFolder folder: Folder, inCell cell: FolderTableViewCell) {
        let deleteFolderAlertController = UIAlertController(title: "Warning",
                                                            message: "Deleting this folder will erase all its contents. Continue?",
                                                            preferredStyle: .alert)
        deleteFolderAlertController.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (action) in
            self.networkManager?.deleteFolder(folder, successBlock: { (response) -> (Void) in
                self.foldersNavigationDataSource?.needUpdateStack()
                self.photosDataSource?.didDeleteFolder?(inCell: cell)
            }, failureBlock: { (error) -> (Void) in
                print("Error = \(error)")
                self.presentAlert(withMessage: error.message)
            })
        }))
        deleteFolderAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(deleteFolderAlertController, animated: true, completion: nil)
    }
    
    func selectFolderDataSource(_ sender: SelectFolderDataSourceProtocol, willEditFolder folder: Folder, inCell cell: FolderTableViewCell) {
        let newFolderAlertController = UIAlertController(title: "Edit Folder", message: "Edit folder name", preferredStyle: .alert)
        newFolderAlertController.addTextField { (textField) in
            textField.placeholder = "Folder name"
        }
        newFolderAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        newFolderAlertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (alertAction) in
            if let alertTextField = newFolderAlertController.textFields?.first {
                let folderName = alertTextField.text
                folder.title = folderName
                
                self.networkManager?.editFolder(folder, successBlock: { (response) -> (Void) in
                    self.foldersNavigationDataSource?.needUpdateStack()
                    
                    self.photosDataSource?.didChangeFolderTitle?(folderName!, inCell: cell)
                }, failureBlock: { (error) -> (Void) in
                    if error.code == folderDuplicateNameErrorCode {
                        self.showDuplicateFolderNameAlertController()
                    } else {
                        self.presentAlert(withMessage: error.message)
                    }
                })
            }
        }))
        
        present(newFolderAlertController, animated: true, completion: nil)
    }
    
    func selectFolderDataSource(_ sender: SelectFolderDataSourceProtocol, willShareFolder folder: Folder, inCell cell: FolderTableViewCell) {
        shareFolder(folder)
    }
    
    func selectFolderDataSourceDidTapNewFolder(_ sender: SelectFolderDataSourceProtocol) {
        showNewFolderAlertController()
    }
    
    // MARK: MembersDataSourceDelegate
    
    func membersDataSource(_ dataSource: MembersDataSourceProtocol, willAddNewMemberToGroup group: Group) {
        DispatchQueue.main.async {
            self.showAddMembersAlertController(forGroup: group)
        }
    }
    
    func membersDataSource(_ dataSource: MembersDataSourceProtocol, willDeleteMember member: GroupMember, fromGroup group: Group) {
        DispatchQueue.main.async {
            if case .group(let group) = self.ownership, let ownerId = group.ownerId, ownerId == member.uid! {
                self.showRemoveSelfAlertController()
                return
            }
            self.showRemoveMemberAlertController(withCompletionHandler: { [unowned self] () -> (Void) in
                self.networkManager?.removeMember(member, from: group, successBlock: { [unowned self] (response) -> (Void) in
                    self.membersDataSource?.fetchMembers()
                    self.updateGroupMembers(with: -1)
                    }, failureBlock: { [unowned self] (error) -> (Void) in
                        self.presentAlert(withMessage: error.message)
                })
            })
        }
    }
    
    func membersDataSource(_ dataSource: MembersDataSourceProtocol, willDeleteRecipient recipient: Recipient, fromGroup group: Group) {
        DispatchQueue.main.async {
            self.showRemoveMemberAlertController(withCompletionHandler: { [unowned self] () -> (Void) in
                self.networkManager?.removePotentialMember(recipient, from: group, successBlock: { [unowned self] (response) -> (Void) in
                    self.membersDataSource?.fetchMembers()
                    }, failureBlock: { [unowned self] (error) -> (Void) in
                        self.presentAlert(withMessage: error.message)
                })
            })
        }
    }
    
    func membersDataSource(_ dataSource: MembersDataSourceProtocol, didLoadedMembers members: [GroupMember]) {
        DispatchQueue.main.async {
            self.reloadView(animated: false)
        }
    }
    
    // MARK: Overridden
    
    override func handleSuccessFolderSaving() {
        foldersNavigationDataSource?.needUpdateStack()
        
        self.photosDataSource?.reloadContent(forFolder: selectedFolder)
    }
    
    override func reloadContent() {
        DispatchQueue.main.async {
            self.membersDataSource?.fetchMembers()
        }
    }
    
    override func updateGroupMembers(with members: Int) {
        guard case .group(let group) = ownership else { return }
        
        group.usersCount += members
    }
    
    override func createFolder(withName name: String) {
        var selectedGroup: Group? = nil
        
        if case .group(let group) = ownership {
            selectedGroup = group
        }
        
        self.networkManager?.createFolder(withTitle: name, forParentFolder: self.selectedFolder, group: selectedGroup, successBlock: { (response) -> (Void) in
            self.handleSuccessFolderSaving()
        }, failureBlock: { (error) -> (Void) in
            if error.code == folderDuplicateNameErrorCode {
                self.showDuplicateFolderNameAlertController()
            } else {
                self.presentAlert(withMessage: error.message)
            }
        })
    }
    
    override func configureNotificationsIcon() {
        
        self.headerBar?.nearToLeftButtonImage = UIImage(named: "icn_notifications_bell")
        
        if self.isSharing || isOpenedFromNotificationsFeed {
            self.headerBar?.nearToLeftButtonHide = true
        }
        else {
            self.headerBar?.nearToLeftButtonHide = false
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        photosDataSource?.searchPhotos(withValues: textField.text!)
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        textField.resignFirstResponder()
        photosDataSource?.cancelSearch()
        
        return false
    }
    
    // MARK: HeaderBarDelegate
    
    func headerBar(_ header: HeaderBar, didTapRightButton right: UIButton) {
        if isSharing, case .group(let group) = ownership {
            sharingCompletionHandler?(group)
            return
        }
        
        if ownership == .all {
            self.router?.showProfileViewController(fromViewController: self, withAnimation: true)
        } else {
            showFolderOptionsAlert()
        }
    }
    
    func headerBar(_ header: HeaderBar, didTapLeftButton left: UIButton) {
        _ = foldersNavigationDataSource?.pop()
        
        if self.isOpenedFromNotificationsFeed {
            navigationController?.popViewController(animated: true)
            return
        }
        
        switch ownership {
        case .group(_):
            navigationController?.popViewController(animated: true)
            
        case .all, .allInFolder, .my:
            router?.popPhotosViewController(self, withAnimation: true)
            photosDataSource?.changeOwnershipFilter(.my)
        }
    }
    
    // MARK: CameraViewControllerDelegate
    
    func cameraViewControllerUnsecureConnection(_ sender: CameraViewController) {
        popUpView = nil
        
        dismiss(animated: true, completion: { [unowned self] in
            self.tableViewBottomConstraint.constant = 0
            
            self.showUnsecureConnectionView(withConnectionState: .unsecureConnection, completionBlock: {
                self.router?.showBluetoothViewController(fromViewController: self, withAnimation: true)
            })
        })
    }
    
    func cameraViewController(_ sender: CameraViewController, didAddPhotoToFolder folder: Folder?) {
        selectedFolder = folder
        configureView()
        
        foldersNavigationDataSource?.needUpdateStack()
        photosDataSource?.reloadContent(forFolder: folder)
    }
    
    func cameraViewControllerDidConnectionError() {
        self.configureProgressView(with: .abort)
    }
    
    func cameraViewController(_ sender: CameraViewController,
                              didTapSave photo: Photo,
                              resultBlock: @escaping (PhotoCoordinatorResult) -> ()) {
        
        self.upload(new: photo, resultBlock: resultBlock)
    }
    
    // MARK: EditPhotoViewControllerDelegate
    
    func editPhotoViewController(_ sender: EditPhotoViewController, didChangePhoto photo: Photo, inFolder: Folder?) {
        
        sender.dismiss(animated: true, completion: nil)
        
        self.configureProgressView(with: .start)
        photoUploadCoordinator.uploadPhotoToExtistingNode(photo) { (result) in
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + self.progressAnimationDuration , execute: {
                
                switch result {
                case .uploaded(_):
                    DispatchQueue.main.async {
                        
                        self.configureProgressView(with: .finished)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.progressAnimationDuration , execute: {
                        
                        self.foldersNavigationDataSource?.needUpdateStack()
                        self.photosProvider?.replaceImage(photo.image!, withNodeID: photo.nodeID!)
                        
                        self.performNavigation(to: inFolder)
                        self.photosDataSource?.reloadContent(forFolder: inFolder)
                        
                    })
                    
                case .cached(_):
                    DispatchQueue.main.async {
                        
                        if let requiredNodeID = photo.nodeID {
                            self.photosProvider?.removeImage(withNodeID: requiredNodeID)
                        }
                    }
                    
                case .failed(let reason):
                    DispatchQueue.main.async { self.configureProgressView(with: .abort) }
                    print(reason)
                }
            })
        }
    }
    
    func editPhotoViewControllerDidCancelEditing(_ sender: EditPhotoViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: FullScreenPhotoViewControllerDelegate
    
    func fullscreenPhotoViewControllerDidNeedUpdateDataSource(_ sender: FullScreenPhotoViewController) {
        foldersNavigationDataSource?.needUpdateStack()
        
        photosDataSource?.reloadContent(forFolder: selectedFolder)
    }
    
    func fullscreenPhotoViewController(_ sender: FullScreenPhotoViewController, didStartToUpload editedPhoto: Photo, to folder: Folder?) {
        
        self.configureProgressView(with: .start)
    }
    
    func fullscreenPhotoViewController(_ sender: FullScreenPhotoViewController, didFinishToUpload editedPhoto: Photo, to folder: Folder?) {
        
        self.configureProgressView(with: .finished)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + self.progressAnimationDuration , execute: {
            
            self.foldersNavigationDataSource?.needUpdateStack()
            self.photosDataSource?.reloadContent(forFolder: folder)
            self.performNavigation(to: folder)
        })
    }
    
    func fullscreenPhotoViewController(_ sender: FullScreenPhotoViewController, didFailToUpload editedPhoto: Photo, to folder: Folder?) {
        
        self.configureProgressView(with: .abort)
    }
    
    func fullscreenPhotoViewController(_ sender: FullScreenPhotoViewController,
                                       didTapSaveCopiedPhoto photo: Photo,
                                       resultBlock: @escaping PhotoCoordinatorResultBlock) -> () {
        
        self.upload(new: photo, resultBlock: resultBlock)
    }
    
    // MARK: -
    // MARK: PhotoLibraryViewControllerDelegate
    func photoLibraryViewController(_ sender: PhotoLibraryViewController,
                                    didTapSave photo: Photo,
                                    resultBlock: @escaping PhotoCoordinatorResultBlock) -> () {
        
        self.upload(new: photo, resultBlock: resultBlock)
    }
    
    func photoLibraryViewController(_ sender: PhotoLibraryViewController, didFinishToUpload photo: Photo, toFolder folder: Folder?) {
        
        self.foldersNavigationDataSource?.needUpdateStack()
        self.photosDataSource?.reloadContent(forFolder: folder)
        self.performNavigation(to: folder)
    }
    
    func photoLibraryViewController(_ sender: PhotoLibraryViewController, didFailToUpload photo: Photo, toFolder folder: Folder?) {
        
        self.configureProgressView(with: .abort)
    }
}
