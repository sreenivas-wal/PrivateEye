//
//  NotificationSettingsViewController.swift
//  MyMobileED
//
//  Created by Created by Admin on 14.06.18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation

protocol NotificationSettingsViewControllerDelegate: class {
    
    func notificationSettingsViewController(_ viewController: NotificationSettingsViewController, didTapLeftButton button: UIButton)
    func notificationSettingsViewController(_ viewController: NotificationSettingsViewController, didTapNotificationHistoryButton button: UIButton)
}

class NotificationSettingsViewController: BaseViewController,
UITableViewDataSource, UITableViewDelegate {
    
    weak var delegte: NotificationSettingsViewControllerDelegate?
    var transition: NotificationsRoutingTransition!
    var notificationsNetworkManager: NotificationsNetworkProtocol!
    @IBOutlet fileprivate weak var tableView: UITableView!
   
    fileprivate var viewModels: [NotificationSettingsItemViewModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.loadSettings()
    }
    
    // MARK: -
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationSettingsItemCell.cellIdentifier) as! NotificationSettingsItemCell
        let viewModel = self.viewModels[indexPath.row]
        cell.configure(with: viewModel)
        cell.notificationsNetworkManager = notificationsNetworkManager
        
        return cell
    }
    
    // MARK: -
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    // MARK: -
    // MARK: HeaderBarDelegate
    func headerBar(_ header: HeaderBar, didTapNearToLeft button: UIButton) {
        guard let requiredDelegate = self.delegte else { return }
        requiredDelegate.notificationSettingsViewController(self, didTapNotificationHistoryButton: button)
    }

    func headerBar(_ header: HeaderBar, didTapLeftButton left: UIButton) {
        
        guard let requiredDelegate = self.delegte else { return }
        requiredDelegate.notificationSettingsViewController(self, didTapLeftButton: left)
    }

    // MARK: -
    // MARK: Private
    fileprivate func loadSettings() {
        
        let viewModels: [NotificationSettingsItemViewModel] = []
        let paginationQuery = PaginationQuery()
        self.notificationsNetworkManager.getNotificationSettings(query: paginationQuery, successBlock: { [weak self] response -> (Void) in
            guard let strongSelf = self else { return }
            let requiredItems = response.object as! [NotificationSettingsItemViewModel]
            strongSelf.viewModels = requiredItems
            strongSelf.tableView.reloadData()
        },
                                                                 failureBlock: { [weak self] response in
                                                                    
                                                                    guard let strongSelf = self else { return }
                                                                    strongSelf.presentAlert(withMessage: response.message)
        })
        self.viewModels = viewModels
        self.tableView.reloadData()
    }
    
    fileprivate func setupUI() {
        self.tableView.register(NotificationSettingsItemCell.cellNib, forCellReuseIdentifier: NotificationSettingsItemCell.cellIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.headerBar?.textTitleLabel = "NOTIFICATIONS"
        self.headerBar?.nearToLeftButtonHide = false
        self.headerBar?.nearToLeftButtonImage = UIImage(named: "icn_notifications_bell")
        self.headerBar?.leftButtonImage = UIImage(named: "back-arrow")
    }
}
