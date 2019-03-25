//
//  ShareUser.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 8/18/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

class ShareUser: NSObject {

    var userID: String?
    var username: String?
    
    init(userID: String, username: String?) {
        self.userID = userID
        self.username = username
    }
    
}
