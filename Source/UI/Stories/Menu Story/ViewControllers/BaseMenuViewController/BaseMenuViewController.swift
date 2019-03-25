//
//  BaseMenuViewController.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 9/18/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

class BaseMenuViewController: BaseViewController {
    
    private let estimatedTableViewRowHeight: CGFloat = 80
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var router: MenuRouterProtocol?
    var foldersNavigationDataSource: FoldersNavigationDataSourceProtocol?
    var menuNavigationDataSource: FoldersNavigationDataSourceProtocol?
    var networkManager: (PhotosNetworkProtocol & AuthorizationNetworkProtocol & PushNotificationProtocol)?
    var userManager: SessionUserProtocol?
    var notificationManager: NotificationManager?
    var nm: NetworkManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        configureHeaderBar()
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    // MARK: - Private
    
    private func registerCells() {
        tableView.register(UINib.init(nibName: "MenuTableViewCell", bundle: nil), forCellReuseIdentifier: "MenuTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = estimatedTableViewRowHeight
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Public
    
    func configureHeaderBar() {
        fatalError("Override this method in subclasses")
    }
    
    func convertToMenuFolderViewModel(_ folder: Folder) -> MenuFolderViewModel {
        var subtitle: String = ""
        let subfoldersCount = folder.subfoldersCount
        let photosCounts = folder.photosCount
        
        if subfoldersCount > 0 {
            subtitle = subtitle.appendingFormat("%ld Folder%@", subfoldersCount, (subfoldersCount == 1 ? "" : "s"))
        }
        
        if photosCounts > 0 {
            if subtitle.count > 0 {
                subtitle = subtitle.appending(", ")
            }
            
            subtitle = subtitle.appendingFormat("%ld File%@", photosCounts, (photosCounts == 1 ? "" : "s"))
        }
        
        let title = folder.title?.uppercased()
        let viewModel = MenuFolderViewModel(title: title, subtitle: subtitle)
        
        return viewModel
    }
    
    // MARK: - Actions
    
    @IBAction func buttonLogoutTapped(_ sender: Any) {
        nm?.logOut(bluetoothManager: self.bluetoothManager!)
    }
}
