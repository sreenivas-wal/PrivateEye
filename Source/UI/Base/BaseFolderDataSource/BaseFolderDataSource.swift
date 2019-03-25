//
//  BaseFolderDataSource.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 8/30/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class BaseFolderDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {

    let swipeButtonWidth: CGFloat = 100.0
    
    var tableView: UITableView?
    var networkManager: PhotosNetworkProtocol?
    var paginationQuery: PhotosPaginationQuery = PhotosPaginationQuery()
    var folders: [Folder] = [Folder]()
    var folderViewModels: [FolderViewModel] = []
    
    // MARK: - Initialization
    
    private override init() { }
    
    init(tableView: UITableView, networkManager: PhotosNetworkProtocol) {
        super.init()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView = tableView
        self.networkManager = networkManager
        
        registerCells()
    }
    
    // MARK: - Cells
    
    func registerCells() {
        tableView?.register(UINib.init(nibName: "FolderTableViewCell", bundle: nil), forCellReuseIdentifier: "FolderTableViewCell")
        tableView?.register(UINib.init(nibName: "AddItemTableViewCell", bundle: nil), forCellReuseIdentifier: "AddItemTableViewCell")
        tableView?.tableFooterView = UIView()
    }
    
    func createTableViewCellEditButton(withCallback callback: @escaping MGSwipeButtonCallback) -> MGSwipeButton {
        let editButton = MGSwipeButton(title: "",
                                       icon: UIImage(named:"edit-photo-icon"),
                                       backgroundColor: BaseColors.darkBlue.color(),
                                       insets: UIEdgeInsets(top: 38, left: 40, bottom: 38, right: 40),
                                       callback: callback)
        
        editButton.buttonWidth = swipeButtonWidth
        editButton.imageView?.contentMode = .scaleAspectFit
        editButton.imageView?.sizeToFit()
        
        return editButton
    }
    
    func createTableViewCellDeleteButton(withCallback callback: @escaping MGSwipeButtonCallback) -> MGSwipeButton {
        let deleteButton = MGSwipeButton(title: "",
                                         icon: UIImage(named:"delete-photo-icon"),
                                         backgroundColor: BaseColors.darkRed.color(),
                                         insets: UIEdgeInsets(top: 38, left: 39, bottom: 38, right: 39),
                                         callback: callback)
        deleteButton.buttonWidth = swipeButtonWidth
        deleteButton.imageView?.contentMode = .scaleAspectFit
        deleteButton.imageView?.sizeToFit()
        
        return deleteButton
    }
    
    func createTableViewCellShareButton(withCallback callback: @escaping MGSwipeButtonCallback) -> MGSwipeButton {
        let shareButton = MGSwipeButton(title: "",
                                        icon: UIImage(named: "share-icon"),
                                        backgroundColor: BaseColors.orange.color(),
                                        callback: callback)
        shareButton.buttonWidth = swipeButtonWidth
        shareButton.imageView?.contentMode = .scaleAspectFit
        shareButton.imageView?.sizeToFit()
        
        return shareButton
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("Override with method in subclasses")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError("Override with method in subclasses")
    }
}
