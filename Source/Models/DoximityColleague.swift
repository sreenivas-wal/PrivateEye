//
//  DoximityProfile.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 9/27/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import SwiftyJSON

class DoximityColleague: NSObject {

    var uid: Int?
    var firstName: String?
    var lastName: String?
    
    init?(json: JSON) {
        guard let uid = json["id"].int else { return }
        let firstName = json["first_name"].string
        let lastName = json["last_name"].string
        
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
    }
}
