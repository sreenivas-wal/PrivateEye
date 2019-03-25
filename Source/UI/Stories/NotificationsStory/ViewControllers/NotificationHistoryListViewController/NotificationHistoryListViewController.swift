//
//  NotificationHistoryListViewController.swift
//  MyMobileED
//
//  Created by Created by Admin on 14.06.18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation

protocol NotificationHistoryListViewControllerDelegate: class {
    
    func notificationHistoryListViewController(_ viewController: NotificationHistoryListViewController, didTapLeftButton button: UIButton)
    func notificationHistoryListViewController(_ viewController: NotificationHistoryListViewController, didSelectHistoryItem item: NotificationHistoryItem)
}

class NotificationHistoryListViewController: BaseViewController,
UITableViewDataSource, UITableViewDelegate {
    
    // MARK: -
    // MARK: Properties
    weak var delegte: NotificationHistoryListViewControllerDelegate?
    var transition: NotificationsRoutingTransition!
    var notificationsNetworkManager: NotificationsNetworkProtocol!
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var loadingContainerView: UIView!
    @IBOutlet weak var noNotificationsView: UIView!
    
    fileprivate var historyItems: [NotificationHistoryItem] = []
    fileprivate var viewModels: [NotificationListItemViewModel] = []
    
    // MARK: -
    // MARK: Public
    func showLoading() {
        
        guard self.isViewLoaded else { return }
        self.loadingContainerView.isHidden = false
        self.view.bringSubview(toFront: self.loadingContainerView)
    }
    
    func hideLoading() {
        
        guard self.isViewLoaded else { return }
        self.loadingContainerView.isHidden = true
        self.view.sendSubview(toBack: self.loadingContainerView)
    }
    
    // MARK: -
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.loadNotificationHistory()
    }
    
    // MARK: -
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationListItemCell.cellIdentifier) as! NotificationListItemCell
        let viewModel = self.viewModels[indexPath.row]
        cell.configure(with: viewModel)
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let viewModel = self.viewModels[indexPath.row]
        
        guard let requiredDelegate = self.delegte,
            let item = self.historyItems.first(where: { viewModel.itemID == $0.itemID })
            else { return }
        
        requiredDelegate.notificationHistoryListViewController(self, didSelectHistoryItem: item)
    }
    
    // MARK: -
    // MARK: HeaderBarDelegate
    func headerBar(_ header: HeaderBar, didTapLeftButton left: UIButton) {
        
        guard let requiredDelegate = self.delegte else { return }
        requiredDelegate.notificationHistoryListViewController(self, didTapLeftButton: left)
    }
    
    // MARK: -
    // MARK: Private
    fileprivate func setupUI() {
        
        self.tableView.register(NotificationListItemCell.cellNib, forCellReuseIdentifier: NotificationListItemCell.cellIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.headerBar?.textTitleLabel = "NOTIFICATIONS"
        self.headerBar?.leftButtonImage = UIImage(named: "back-arrow")
    }
    
    fileprivate func loadNotificationHistory() {
        
        let paginationQuery = PaginationQuery()
        self.notificationsNetworkManager.getNotificationHistory(query: paginationQuery,
                                                                successBlock: { [weak self] response in
                                                                    
                                                                    guard let strongSelf = self else { return }
                                                                    
                                                                    let requiredItems = response.object as! [NotificationHistoryItem]
                                                                    if requiredItems.count == 0 {
                                                                        self?.tableView.isHidden = true
                                                                        self?.noNotificationsView.isHidden = false
                                                                    } else {
                                                                        strongSelf.historyItems = requiredItems
                                                                        strongSelf.viewModels = strongSelf.viewModels(from: requiredItems)
                                                                        strongSelf.tableView.reloadData()
                                                                    }
            },
                                                                failureBlock: { [weak self] response in
                                                                    
                                                                    guard let strongSelf = self else { return }
                                                                    strongSelf.presentAlert(withMessage: response.message)
        })
    }
    
    fileprivate func viewModels(from historyItems: [NotificationHistoryItem]) -> [NotificationListItemViewModel] {
        
        return historyItems.flatMap({
            
            var subtitle = ""
            if let timestampInDouble = Double($0.timestamp) {
                let dateFromTS = Date(timeIntervalSince1970: timestampInDouble)
                subtitle = DateHelper.formattedStringDateForComment(fromDate: dateFromTS)
            }
            
            return NotificationListItemViewModel(itemID: $0.itemID, title: $0.message, subtitle: subtitle)
        })
    }
}

