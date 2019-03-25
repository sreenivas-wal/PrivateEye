//
//  MenuFoldersViewController.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 8/29/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

class MenuFoldersViewController: BaseMenuViewController, UITableViewDelegate, UITableViewDataSource {

    var folders: [Folder] = []
    var selectedFolder: Folder?
    
    private var paginationQuery: PhotosPaginationQuery = PhotosPaginationQuery()

    override func viewDidLoad() {
        super.viewDidLoad()
        selectedFolder = menuNavigationDataSource?.peek()
        configurePaginationQuery()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedFolder = menuNavigationDataSource?.peek()
        configureHeaderBar()
        configurePaginationQuery()
        reloadContentIfNeeded()
    }

    // MARK: - Overridden
    
    override func configureHeaderBar() {
        headerBar?.titleLabelFont = UIFont(name: "Avenir-Roman", size: 19)!
        headerBar?.textTitleLabel = (selectedFolder != nil) ? selectedFolder?.title : "My Photos"
    }

    // MARK: - Private
    
    private func reloadContentIfNeeded() {
        if let folder = selectedFolder {
            if folder.contentLoaded {
                if let subfolders = selectedFolder?.subfolders {
                    folders = subfolders
                    tableView?.reloadData()
                }
            } else {
                reloadFolders()
            }
        }
    }
    
    private func configurePaginationQuery() {
        paginationQuery.ownershipFilter = .my
        paginationQuery.folderID = selectedFolder?.folderID
        paginationQuery.isSharedWithMe = !canEditFolderContent()
    }

    private func reloadFolders() {
        _ = networkManager?.getFolderContents(withQuery: paginationQuery, successBlock: { (response) -> (Void) in
            let photoLoadingResponse = response.object as! PhotoLoadingPageResponse
            let folders = photoLoadingResponse.folder!.subfolders
            let photos = photoLoadingResponse.folder!.photos
            self.folders = folders
            self.selectedFolder?.subfolders = folders
            self.selectedFolder?.photos = photos
            self.selectedFolder?.contentLoaded = true
            
            self.menuNavigationDataSource?.replaceTop(self.selectedFolder!)
            
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }, failureBlock: { (error) -> (Void) in
            print("Error = \(error.message)")
        })
    }
    
    func canEditFolderContent() -> Bool {
        guard let isEditable = selectedFolder?.isEditable else { return true }
        guard let uid = selectedFolder?.uid else { return isEditable }
        let isOwned = (uid == userManager?.currentUser?.userID)
        
        return isEditable && isOwned
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let folder = folders[indexPath.row]
        menuNavigationDataSource?.push(folder)
        
        if folder.subfoldersCount > 0 {
            router?.showMenuFolderViewController(fromViewController: self, withAnimation: true, forSelectedFolder: folder)
        } else {
            router?.showPhotosViewController(withOwnershipFilter: .my, forFoldersStack: menuNavigationDataSource!.fetchAll())
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let folder = folders[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell") as! MenuTableViewCell
        cell.configureCellWith(convertToMenuFolderViewModel(folder))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count
    }
    
    // MARK: HeaderBarDelegate
    
    func headerBar(_ header: HeaderBar, didTapRightButton right: UIButton) {
        router?.showPhotosViewController(withOwnershipFilter: .my, forFoldersStack: menuNavigationDataSource!.fetchAll())
    }
    
    func headerBar(_ header: HeaderBar, didTapLeftButton left: UIButton) {
        _ = menuNavigationDataSource?.pop()
        
        if menuNavigationDataSource!.fetchAll().count > 0 {
            router?.popMenuViewController(fromViewController: self, withAnimation: true)
        } else {
            router?.popToRootMenuViewController(fromViewController: self, withAnimation: true)
        }
    }

}
