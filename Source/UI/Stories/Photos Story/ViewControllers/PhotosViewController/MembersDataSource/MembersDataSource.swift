//
//  MembersDataSource.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 1/25/18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit

enum GroupMembersContentSections: Int {
    case newMember = 0
    case members
    case pending
    
    static var numberOfSections: Int { return 3 }
    
    func cellHeight() -> CGFloat {
        switch self {
        case .newMember:
            return 60
        case .members, .pending:
            return 65
        }
    }
}

protocol MembersDataSourceDelegate: class {
    func membersDataSource(_ dataSource: MembersDataSourceProtocol, willAddNewMemberToGroup group: Group)
    func membersDataSource(_ dataSource: MembersDataSourceProtocol, willDeleteMember member: GroupMember, fromGroup group: Group)
    func membersDataSource(_ dataSource: MembersDataSourceProtocol, willDeleteRecipient recipient: Recipient, fromGroup group: Group)
    func membersDataSource(_ dataSource: MembersDataSourceProtocol, didLoadedMembers members: [GroupMember])
}

class MembersDataSource: NSObject, MembersDataSourceProtocol, UITableViewDelegate, UITableViewDataSource, ContactListTableViewCellDelegate {
    
    private let paginationItemOnPage: Int = 20
    
    private weak var delegate: MembersDataSourceDelegate?
    private var membersRequest: NetworkRequest?
    
    private var members: [GroupMember] = []
    private var membersViewModels: [GroupMemberViewModel] = []
    
    private var recipients: [Recipient] = []
    
    private var paginationQuery: GroupMembersPaginationQuery = GroupMembersPaginationQuery()
    private var groupsRequest: NetworkRequest?
    private var tableView: UITableView?
    private var networkManager: PhotosNetworkProtocol?
    private var userManager: SessionUserProtocol?
    private var group: Group!
    
    init(tableView: UITableView, networkManager: PhotosNetworkProtocol, userManager: SessionUserProtocol, delegate: MembersDataSourceDelegate, group: Group) {
        super.init()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView = tableView
        self.networkManager = networkManager
        self.userManager = userManager
        self.group = group
        self.delegate = delegate
        
        registerCells()
    }
    
    // MARK: - MembersDataSourceProtocol
    
    func fetchMembers() {
        paginationQuery.page = 0
        paginationQuery.groupID = group?.groupID
        paginationQuery.itemsOnPage = paginationItemOnPage
        
        membersRequest = networkManager?.getGroupMembers(withPaginationQuery: paginationQuery, successBlock: { [unowned self] (response) -> (Void) in
            let membersLoadingResponse = response.object as! GroupMembersLoadingPageResponse
            self.paginationQuery.limit = membersLoadingResponse.limit
            
            let members = membersLoadingResponse.groupMembers
            self.members = members
            self.membersViewModels = self.convertToViewModels(members)
            
            self.recipients = membersLoadingResponse.pendingMembers
            
            self.delegate?.membersDataSource(self, didLoadedMembers: members)
            
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
            
            self.membersRequest = nil
        }, failureBlock: { [unowned self] (error) -> (Void) in
            self.membersRequest = nil
        })
    }

    func isGroupLeader() -> Bool {
        let isLeader = (userManager?.currentUser?.userID == group!.ownerId)
        
        return isLeader
    }

    func contentHeight() -> CGFloat {
        let membersHeight = CGFloat(members.count) * GroupMembersContentSections.members.cellHeight()
        let recipientHeight = CGFloat(recipients.count) * GroupMembersContentSections.pending.cellHeight()
        let newMemberHeight = isGroupLeader() ? GroupMembersContentSections.newMember.cellHeight() : 0
        
        return membersHeight + newMemberHeight + recipientHeight
    }
    
    // MARK: - Private
    
    private func registerCells() {
        tableView?.register(UINib.init(nibName: "ContactListTableViewCell", bundle: nil), forCellReuseIdentifier: "ContactListTableViewCell")
        tableView?.register(UINib.init(nibName: "AddItemTableViewCell", bundle: nil), forCellReuseIdentifier: "AddItemTableViewCell")
        tableView?.tableFooterView = UIView()
    }

    private func convertToViewModel(_ member: GroupMember) -> GroupMemberViewModel {
        let canDelete = isGroupLeader()
        
        return GroupMemberViewModel(name: member.name ?? "", canDelete: canDelete, selected: true)
    }
    
    private func convertToViewModels(_ members: [GroupMember]) -> [GroupMemberViewModel] {
        var membersViewModels = [GroupMemberViewModel]()
        
        members.forEach { (member) in
            let viewModel = self.convertToViewModel(member)
            membersViewModels.append(viewModel)
        }
        
        return membersViewModels
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch GroupMembersContentSections(rawValue: section) {
        case .newMember?:
            return isGroupLeader() ? 1 : 0
        case .members?:
            return members.count
        case .pending?:
            return recipients.count
        case .none:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch GroupMembersContentSections(rawValue: indexPath.section) {
        case .newMember?:
            let newGroupCell = tableView.dequeueReusableCell(withIdentifier: "AddItemTableViewCell") as! AddItemTableViewCell
            newGroupCell.configure(with: "+ ADD NEW MEMBER")
            newGroupCell.backgroundColor = .clear
            newGroupCell.topLine.isHidden = false
            
            return newGroupCell
        case .members?:
            let memberCell = tableView.dequeueReusableCell(withIdentifier: "ContactListTableViewCell") as! ContactListTableViewCell
            memberCell.configure(withGroupMemberViewModel: membersViewModels[indexPath.row])
            memberCell.delegate = self
            
            return memberCell
        case .pending?:
            let viewModel = GroupMemberViewModel(name: recipients[indexPath.row].recipientID ?? "", canDelete: isGroupLeader(), selected: false)
            let memberCell = tableView.dequeueReusableCell(withIdentifier: "ContactListTableViewCell") as! ContactListTableViewCell
            memberCell.configure(withGroupMemberViewModel:viewModel)
            memberCell.delegate = self
            
            return memberCell
        case .none:
            return UITableViewCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return GroupMembersContentSections.numberOfSections
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GroupMembersContentSections(rawValue: indexPath.section)!.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if paginationQuery.page >= (paginationQuery.limit - 1) {
            return
        }
        
        if indexPath.row == members.endIndex - 1 {
            paginationQuery.nextPage()
            
            membersRequest = networkManager?.getGroupMembers(withPaginationQuery: paginationQuery, successBlock: { [unowned self] (response) -> (Void) in
                let membersLoadingResponse = response.object as! GroupMembersLoadingPageResponse
                self.paginationQuery.limit = membersLoadingResponse.limit
                
                let members = membersLoadingResponse.groupMembers
                self.members.append(contentsOf: members)
                self.membersViewModels.append(contentsOf: self.convertToViewModels(members))
                
                self.delegate?.membersDataSource(self, didLoadedMembers: self.members)
                
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                }
                
                self.membersRequest = nil
            }, failureBlock: { [unowned self] (error) -> (Void) in
                self.membersRequest = nil
            })
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch GroupMembersContentSections(rawValue: indexPath.section) {
        case .newMember?:
            delegate?.membersDataSource(self, willAddNewMemberToGroup: group)
            break
        case .members?, .pending?, .none:
            break
        }
    }
    
    // MARK: - ContactListTableViewCellDelegate
    
    func contactListTableViewCellDidTapDelete(_ sender: ContactListTableViewCell) {
        guard let indexPath = tableView?.indexPath(for: sender) else { return }
        
        switch GroupMembersContentSections(rawValue: indexPath.section) {
        case .newMember?, .none:
            break
        case .members?:
            delegate?.membersDataSource(self, willDeleteMember: members[indexPath.row], fromGroup: group)
            break
        case .pending?:
            delegate?.membersDataSource(self, willDeleteRecipient: recipients[indexPath.row], fromGroup: group)
            break
        }
        
    }
}
