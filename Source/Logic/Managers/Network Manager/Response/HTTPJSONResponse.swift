//
//  HTTPJSONResponse.swift
//  MyMobileED
//
//  Created by Admin on 1/18/17.
//  Copyright © 2017 Company. All rights reserved.
//

import Foundation
import SwiftyJSON

let folderDuplicateNameErrorCode = 1
let noDoximityUserExistErrorCode = 3
let verificationDoximityErrorCode = 4

struct HTTPJSONResponse {
    let json: JSON
    let message: String
    let code: Int
    
    var object: AnyObject = "" as AnyObject
    
    // MARK: Init
    
    init(withJSON json: JSON, code: Int, message: String) {
        self.json = json
        self.code = code
        self.message = message
    }
}
