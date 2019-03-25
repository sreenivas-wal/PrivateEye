//
//  GroupsDataSource.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 1/22/18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit

enum GroupsContentSections: Int {
    case groups = 0
    case newGroup
    
    static var numberOfSections: Int { return 2 }
    
    func cellHeight() -> CGFloat {
        switch self {
        case .groups:
            return 100
        case .newGroup:
            return 60
        }
    }
}

protocol GroupsDataSourceDelegate: class {
    func groupsDataSourceWillAddNewGroup(_ dataSource: GroupsDataSourceProtocol)
    func groupsDataSource(_ dataSource: GroupsDataSourceProtocol, isEmptyGroups isEmpty: Bool)
    func groupsDataSource(_ dataSource: GroupsDataSourceProtocol, didSelect group: Group)
}

class GroupsDataSource: NSObject, GroupsDataSourceProtocol, UITableViewDelegate, UITableViewDataSource {

    private weak var delegate: GroupsDataSourceDelegate?
    private var groups: [Group] = []
    private var viewModels: [GroupViewModel] = []
    private var paginationQuery: GroupsPaginationQuery = GroupsPaginationQuery()
    private var groupsRequest: NetworkRequest?
    private var tableView: UITableView?
    private var networkManager: PhotosNetworkProtocol?
    private var userManager: SessionUserProtocol?
    private var alertManager:AlertsManager?
    private var router:PhotosRouterProtocol?
    var groupsViewController:GroupsViewController?
    
    init(tableView: UITableView, networkManager: PhotosNetworkProtocol, userManager: SessionUserProtocol,alertManager:AlertsManager,viewController:GroupsViewController, router:PhotosRouterProtocol, delegate: GroupsDataSourceDelegate) {
        super.init()
        self.groupsViewController = viewController
        tableView.delegate = self
        tableView.dataSource = self
        self.alertManager = alertManager
        self.tableView = tableView
        self.networkManager = networkManager
        self.userManager = userManager
        self.delegate = delegate
        self.router = router
        registerCells() 
    }
    
    // MARK: - GroupsDataSourceProtocol
    
    func reloadGroups(withKeywords keywords: String) {
        paginationQuery.page = 0
        paginationQuery.keywords = keywords
        
        groupsRequest = networkManager?.getGroups(withQuery: paginationQuery, successBlock: { [unowned self] (response) -> (Void) in
            let groupsLoadingResponse = response.object as! GroupsLoadingPageResponse
            self.paginationQuery.limit = groupsLoadingResponse.limit
            
            let groups = groupsLoadingResponse.groups!
            self.delegate?.groupsDataSource(self, isEmptyGroups: groups.count == 0)
            
            self.groups = groups
            self.viewModels = self.convertToViewModels(groups)
            
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
            
            self.groupsRequest = nil
        }, failureBlock: { [unowned self] (error) -> (Void) in
            self.groupsRequest = nil
        })
    }
    
    // MARK: - Private
    
    private func registerCells() {
        tableView?.register(UINib.init(nibName: "GroupTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupTableViewCell")
        tableView?.register(UINib.init(nibName: "AddItemTableViewCell", bundle: nil), forCellReuseIdentifier: "AddItemTableViewCell")
        tableView?.tableFooterView = UIView()
    }
    
    private func convertToViewModel(_ group: Group) -> GroupViewModel {
        let title = group.title ?? ""
        let membersInfo = String(format: "%ld User%@", group.usersCount, (group.usersCount == 1) ? "" : "s")
        
        let isLeader = (userManager?.currentUser?.userID == group.ownerId)
        let ownerName = isLeader ? "You" : group.ownerName ?? ""
        let ownerInformation = String(format: "Owner: %@", ownerName)
        
        return GroupViewModel(title: title, membersInfo: membersInfo, ownerInformation: ownerInformation, isOwner: isLeader)
    }
    
    private func convertToViewModels(_ groups: [Group]) -> [GroupViewModel] {
        var groupsViewModels = [GroupViewModel]()
        
        groups.forEach { (group) in
            let viewModel = self.convertToViewModel(group)
            groupsViewModels.append(viewModel)
        }
        
        return groupsViewModels
    }

    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch GroupsContentSections(rawValue: section) {
        case .groups?:
            return viewModels.count
        case .newGroup?:
            return 1
        case .none:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch GroupsContentSections(rawValue: indexPath.section) {
        case .groups?:
            let groupCell = tableView.dequeueReusableCell(withIdentifier: "GroupTableViewCell") as! GroupTableViewCell
            groupCell.configure(with: viewModels[indexPath.row])
            
            return groupCell
        case .newGroup?:
            let newGroupCell = tableView.dequeueReusableCell(withIdentifier: "AddItemTableViewCell") as! AddItemTableViewCell
            newGroupCell.configure(with: "+ NEW GROUP")
            
            return newGroupCell
        case .none:
            return UITableViewCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return GroupsContentSections.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard GroupsContentSections(rawValue: indexPath.section) == .groups else { return }
        
        if paginationQuery.page >= (paginationQuery.limit - 1) {
            return
        }
        
        if indexPath.row == groups.endIndex - 1 {
            paginationQuery.nextPage()
            
            groupsRequest = networkManager?.getGroups(withQuery: paginationQuery, successBlock: { [unowned self] (response) -> (Void) in
                let groupsLoadingResponse = response.object as! GroupsLoadingPageResponse
                self.paginationQuery.limit = groupsLoadingResponse.limit
                
                let groups = groupsLoadingResponse.groups!
                self.groups.append(contentsOf: groups)
                self.viewModels.append(contentsOf: self.convertToViewModels(groups))
                
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                }
                
                self.groupsRequest = nil
            }, failureBlock: { [unowned self] (error) -> (Void) in
                self.groupsRequest = nil
            })
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GroupsContentSections(rawValue: indexPath.section)!.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch GroupsContentSections(rawValue: indexPath.section) {
        case .groups?:
            let group = groups[indexPath.row]
            delegate?.groupsDataSource(self, didSelect: group)
            
            break
        case .newGroup?:
            if userManager?.currentUser?.userRole == "unverified" {
                self.alertManager?.showUnVerifiedAlertController(forViewController: (self.groupsViewController)!, withOkayCallback: { () -> (Void) in
                    
                }, withOpenCallback: { () -> (Void) in
                    self.router?.showPEVerificationViewController(fromViewController: (self.groupsViewController)!, navigationController: (self.groupsViewController)!.navigationController!, withAnimation: false)
                })
            } else if userManager?.currentUser?.userRole == "in_progress" {
                self.alertManager?.showInReviewAlertController(forViewController: (self.groupsViewController)!, withOkayCallback: { () -> (Void) in
                })
            }
            delegate?.groupsDataSourceWillAddNewGroup(self)
            break
        case .none:
            break
        }
    }
    
}
