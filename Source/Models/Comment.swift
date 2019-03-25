//
//  Comment.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 10/18/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import SwiftyJSON

class Comment: NSObject {
    
    var id: String?
    var subject: String?
    var username: String?
    var comment: String?
    var createdDate: String?
    
    init?(json: JSON) {
        guard let id = json["cid"].string else { return nil }
        let subject = json["subject"].string
        let username = json["name"].string
        let createdDate = json["created"].string
        let comment = json["comment"].string
        
        self.id = id
        self.subject = subject
        self.username = username
        self.createdDate = createdDate
        self.comment = comment
    }
    
}
