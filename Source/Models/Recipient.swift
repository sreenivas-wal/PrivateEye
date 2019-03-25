//
//  Recipient.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 1/26/18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit
import SwiftyJSON

let recipientProfileNotFoundCode = 3
let existingRecipientCode = 4

class Recipient: NSObject {
    var recipientID: String?
    var recipientType: String?
    var code: Int = 0
    
    init(recipientID: String, recipientType: String, code: Int) {
        self.recipientID = recipientID
        self.recipientType = recipientType
        self.code = code
    }
    
    init?(json: JSON) {
        guard let recipientID = json["recipient_id"].string else { return }
        guard let recipientType = json["recipient_type"].string else { return }
        let code = json["code"].intValue
        
        self.recipientID = recipientID
        self.recipientType = recipientType
        self.code = code
    }
}
