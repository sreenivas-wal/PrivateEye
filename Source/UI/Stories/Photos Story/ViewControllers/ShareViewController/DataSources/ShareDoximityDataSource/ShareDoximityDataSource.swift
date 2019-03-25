//
//  ShareDoximityDataSource.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 9/25/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

class ShareDoximityDataSource: SharingDataSource {

    // MARK: - SharingDataSourceProtocol
    
    override func searchUsers(withKeywords keywords: String, withResetValue reset: Bool) {
        self.keywords = keywords
        
        networkManager?.retrieveDoximityUsers(withKeywords: keywords, withResetValue: reset, successBlock: { [unowned self] (response) -> (Void) in
            let colleaguesLoadingPageResponse = response.object as! DoximityColleaguesLoadingPageResponse
            self.users = self.convertColleaguesToShareUser(colleaguesLoadingPageResponse.colleagues!)
            self.usersViewModels = self.users.map({ (user) -> ShareUserViewModel in
                return self.convertToViewModel(user)
            })
            
            self.tableView?.reloadData()
        }, failureBlock: { [weak self] (response) -> (Void) in
            print("Error = \(response)")
           
            if response.code == 401 {
                
                guard let strongSelf = self else { return }
                strongSelf.delegate?.shareDataSourceDidHandleDoximityTokenExparation(strongSelf)
            }
        })
    }
    
    // MARK: - Private
    
    private func convertColleaguesToShareUser(_ colleagues: [DoximityColleague]) -> [ShareUser] {
        var users: [ShareUser] = []
        
        for colleague in colleagues {
            var username = colleague.firstName
            username = username?.appendingFormat(" %@", colleague.lastName!)
            
            if let uid = colleague.uid {
                let user = ShareUser(userID: String(uid), username: username)
                users.append(user)
            }
        }
        
        return users
    }
    
}
