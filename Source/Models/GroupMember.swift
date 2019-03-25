//
//  GroupMember.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 1/24/18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation
import SwiftyJSON

class GroupMember: NSObject {

    var uid: String?
    var name: String?

    init?(json: JSON) {
        guard let uid = json["uid"].string else { return }
        let name = json["name"].string
        
        self.name = name
        self.uid = uid
    }
}
