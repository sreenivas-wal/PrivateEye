//
//  MenuViewController.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 8/25/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import UserNotifications

enum MenuFolders: Int {
    case all = 0
    case my
    case shared
    
    static var foldersCount: Int { return 3 }
}

class MenuViewController: BaseMenuViewController, UITableViewDelegate, UITableViewDataSource {
    
    var shouldShowCaseSelectionScreen: Bool = false
    var user: User?
    var alertsManager: AlertsManagerProtocol?
    
    private var folders: [Folder] = [Folder(folderID: nil, title: "All Photos", isEditable: false, photosCount: 0, subfoldersCount: 0),
                                     Folder(folderID: nil, title: "My Photos", isEditable: true, photosCount: 0, subfoldersCount: 0),
                                     Folder(folderID: nil, title: "Shared With Me", isEditable: false, photosCount: 0, subfoldersCount: 0)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showCaseSelectionScreenIfNeeded()
        configurePushNotifications()
        
        foldersNavigationDataSource?.replace(withItems: [])
        router?.openMenu(animated: false)
        foldersNavigationDataSource?.replace(withItems: [folders[MenuFolders.my.rawValue]])
        if userManager?.currentUser?.userRole == "unverified" {
            self.alertsManager?.showUnVerifiedAlertController(forViewController: self, withOkayCallback: { () -> (Void) in
            }, withOpenCallback: { () -> (Void) in
                self.router?.showPEVerificationViewController(fromViewController: self, navigationController: self.navigationController!, withAnimation: false)
            })
        } else if userManager?.currentUser?.userRole == "in_progress" {
            self.alertsManager?.showInReviewAlertController(forViewController: self, withOkayCallback: { () -> (Void) in
            })
        }
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadFolders()
        configureHeaderBar()
    }
    
    func shouldShowInitialMenuController() -> Bool {
        return foldersNavigationDataSource!.fetchAll().count > 0
    }
    
    // MARK: - Overridden
    
    override func configureHeaderBar() {
        headerBar?.titleLabelFont = UIFont(name: "Avenir-Roman", size: 19)!
        headerBar?.textTitleLabel = userManager?.retriveProfile()?.username
    }
    
    // MARK: - Actions
    
    @IBAction func showGroupsViewTapped(_ sender: UITapGestureRecognizer) {
        foldersNavigationDataSource?.replace(withItems: [])
        router?.showGroupsViewControllerWithAnimation(true)
    }
    
    // MARK: - Private
    
    private func showCaseSelectionScreenIfNeeded() {
        if shouldShowCaseSelectionScreen {
            shouldShowCaseSelectionScreen = false
            router?.showBluetoothViewController(fromViewController: self, withAnimation: true)
        }
    }
    
    private func loadAllPhotosFolderContent() {
        let allPhotosPaginationQuery = PhotosPaginationQuery()
        allPhotosPaginationQuery.ownershipFilter = .all
        _ = networkManager?.getFolderContents(withQuery: allPhotosPaginationQuery, successBlock: { (response) -> (Void) in
            let photosCount = response.json["view"]["count"].intValue
            let allFolder = self.folders[MenuFolders.all.rawValue]
            allFolder.photosCount = photosCount
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }, failureBlock: { (error) -> (Void) in
            print("Error = \(error)")
        })
    }
    
    private func loadMyPhotosFolderContent() {
        let myPhotosPaginationQuery = PhotosPaginationQuery()
        _ = networkManager?.getFolderContents(withQuery: myPhotosPaginationQuery, successBlock: { (response) -> (Void) in
            let photosCount = response.json["view"]["count"].intValue
            let subfoldersCount = response.json["view"]["count_subfolders"].intValue
            
            let myFolder = self.folders[MenuFolders.my.rawValue]
            myFolder.photosCount = photosCount
            myFolder.subfoldersCount = subfoldersCount
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }, failureBlock: { (error) -> (Void) in
            print("Error = \(error)")
        })
    }
    
    private func loadSharedWithMeContent() {
        let sharedWithMePaginationQuery = PhotosPaginationQuery()
        sharedWithMePaginationQuery.isSharedWithMe = true
        _ = networkManager?.getFolderContents(withQuery: sharedWithMePaginationQuery, successBlock: { (response) -> (Void) in
            let photosCount = response.json["view"]["count"].intValue
            let subfoldersCount = response.json["view"]["count_subfolders"].intValue
            
            let sharedWithMeFolder = self.folders[MenuFolders.shared.rawValue]
            sharedWithMeFolder.photosCount = photosCount
            sharedWithMeFolder.subfoldersCount = subfoldersCount
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }, failureBlock: { (error) -> (Void) in
            print("Error = \(error)")
        })
    }
    
    private func configurePushNotifications() {
        
        if #available(iOS 10.0, *) {
            
            let authOptions: UNAuthorizationOptions = [.alert, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { (granted, error) in
                    
                    DispatchQueue.main.async {
                        
                        guard error == nil else { return }
                        UIApplication.shared.registerForRemoteNotifications()
                    }
            })
            
        }
        else {
            
            let notificationTypes: UIUserNotificationType = [.alert, .sound]
            let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
            
            UIApplication.shared.registerUserNotificationSettings(pushNotificationSettings)
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    private func reloadFolders() {
        loadAllPhotosFolderContent()
        loadMyPhotosFolderContent()
        loadSharedWithMeContent()
    }
    
    private func showMenuFolder(forFolder folder: Folder, isEditable: Bool) {
        folder.isEditable = isEditable
        
        menuNavigationDataSource?.push(folder)
        menuNavigationDataSource?.needUpdateStack()
        
        router?.showMenuFolderViewController(fromViewController: self, withAnimation: true, forSelectedFolder: folder)
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch MenuFolders(rawValue: indexPath.row) {
        case .all?:
            router?.showPhotosViewController(withOwnershipFilter: .all, forFoldersStack: [])
            break
        case .my?:
            let myFolders = folders[MenuFolders.my.rawValue]
            showMenuFolder(forFolder: myFolders, isEditable: true)
            
            break
        case .shared?:
            let sharedFolders = folders[MenuFolders.shared.rawValue]
            showMenuFolder(forFolder: sharedFolders, isEditable: false)
            
            break
        case .none:
            break
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var currentFolder: Folder = folders[MenuFolders.my.rawValue]
        
        switch MenuFolders(rawValue: indexPath.row) {
        case .all?:
            currentFolder = folders[MenuFolders.all.rawValue]
            break
        case .my?:
            currentFolder = folders[MenuFolders.my.rawValue]
            break
        case .shared?:
            currentFolder = folders[MenuFolders.shared.rawValue]
            break
        case .none:
            break
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell") as! MenuTableViewCell
        cell.configureCellWith(convertToMenuFolderViewModel(currentFolder))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuFolders.foldersCount
    }
    
    // MARK: HeaderBarDelegate
    
    func headerBar(_ header: HeaderBar, didTapRightButton right: UIButton) {
        router?.showProfileViewControllerWithAnimation(true)
    }
}
