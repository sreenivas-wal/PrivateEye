//
//  ShareUsersDataSource.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 9/25/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

class ShareUsersDataSource: SharingDataSource {

    private var paginationQuery: SearchUsersPaginationQuery = SearchUsersPaginationQuery()
    private var searchRequest: NetworkRequest?

    // MARK: - SharingDataSourceProtocol
    
    override func searchUsers(withKeywords keywords: String,withResetValue reset: Bool) {
        paginationQuery.page = 0
        paginationQuery.keywords = keywords
        paginationQuery.excludeCurrentUser = true
        
        searchRequest?.dataRequest?.cancel()
        clearUsers()
        
        searchRequest = networkManager?.searchUsers(withQuery: paginationQuery, successBlock: { [unowned self] (response) -> (Void) in
            let usersLoadingResponse = response.object as! ShareUserLoadingPageResponse
            self.paginationQuery.limit = usersLoadingResponse.limit!
            
            let users = usersLoadingResponse.users!
            self.users = users
            self.usersViewModels = self.setupViewModels(forUsers: users)
            
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
            
            self.searchRequest = nil
            }, failureBlock: { (error) -> (Void) in
                print("Error = \(error)")
                self.searchRequest = nil
        })
    }

    // MARK: - Private
    
    private func clearUsers() {
        users = []
        tableView?.reloadData()
    }

    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if paginationQuery.page >= (paginationQuery.limit - 1) {
            return
        }
        
        if indexPath.row == users.endIndex - 1 {
            paginationQuery.nextPage()
            
            searchRequest = networkManager?.searchUsers(withQuery: paginationQuery, successBlock: { [unowned self] (response) -> (Void) in
                let response = response.object as! ShareUserLoadingPageResponse
                let users = response.users!
                self.users.append(contentsOf: users)
                self.usersViewModels.append(contentsOf: self.setupViewModels(forUsers: users))
                
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                }
                
                self.searchRequest = nil
            }, failureBlock: { (error) -> (Void) in
                self.searchRequest = nil
            })
        }
    }

}
