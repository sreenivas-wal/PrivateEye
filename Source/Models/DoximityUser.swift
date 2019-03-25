//
//  DoximityUser.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 9/13/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import SwiftyJSON

class DoximityUser: NSObject {

    var mail: String?
    var phone: String?
    var accessToken: String?
    var isVerified: Bool = false
    
    init?(json: JSON) {
        guard let accessToken = json["access_token"].string else { return }
        let mail = json["user"]["mail"].string
        let phone = json["user"]["field_phone"]["und"][0]["value"].string
        let verified = json["verified"].boolValue
        
        self.mail = mail
        self.accessToken = accessToken
        self.phone = phone
        self.isVerified = verified
    }
    
    init(accessToken: String) {
        self.accessToken = accessToken
    }
}
