//
//  User.swift
//  MyMobileED
//
//  Created by Admin on 1/19/17.
//  Copyright © 2017 Company. All rights reserved.
//

import Foundation
import SwiftyJSON

class User: NSObject, NSCoding {
    var sessionName: String?
    var sessionID: String?
    var token: String?
    var userID: String?
    var doximityID: String?
    var userRole: String?
    var isUnverified:Bool?
    
    init?(json: JSON) {
        guard let sessionName = json["session_name"].string else { return nil }
        guard let sessionID = json["sessid"].string else { return nil }
        guard let token = json["token"].string else { return nil }
        let userID = json["user"]["uid"].string
        let doximityID = json["user"]["field_doximity_id"]["und"][0]["value"].stringValue
        let userRole = json["user"]["field_verification"]["und"][0]["value"].stringValue
        userRole.isEmpty ? (self.userRole = "unverified") : (self.userRole = userRole)
        self.sessionName = sessionName
        self.sessionID = sessionID
        self.token = token
        self.userID = userID
        self.doximityID = doximityID
    }
    
    init(sessionName: String, sessionID: String, token: String, userID: String, doximityID: String?,userRole: String?) {
        self.sessionName = sessionName
        self.sessionID = sessionID
        self.token = token
        self.userID = userID
        self.doximityID = doximityID
        self.userRole = userRole

    }
    
    // generated
    required internal init?(coder aDecoder: NSCoder) {
        self.userRole = aDecoder.decodeObject(forKey: "userRole") as! String?
        self.sessionName = aDecoder.decodeObject(forKey: "sessionName") as! String?
        self.sessionID = aDecoder.decodeObject(forKey: "sessionID") as! String?
        self.token = aDecoder.decodeObject(forKey: "token") as! String?
        self.userID = aDecoder.decodeObject(forKey: "userID") as! String?
        self.doximityID = aDecoder.decodeObject(forKey: "doximityID") as! String?
    }

    // generated
    internal func encode(with aCoder: NSCoder) {
        aCoder.encode(self.userRole, forKey: "userRole")
        aCoder.encode(self.sessionName, forKey: "sessionName")
        aCoder.encode(self.sessionID, forKey: "sessionID")
        aCoder.encode(self.token, forKey: "token")
        aCoder.encode(self.userID, forKey: "userID")
        aCoder.encode(self.doximityID, forKey: "doximityID")
    }

    // generated
    override internal var description: String {
        var string = "\(type(of: self)): "
        string += "userRole = \(String(describing: self.userRole)), "
        string += "sessionName = \(String(describing: self.sessionName)), "
        string += "sessionID = \(String(describing: self.sessionID)), "
        string += "token = \(String(describing: self.token)), "
        string += "userID = \(String(describing: self.userID)), "
        string += "doximityID = \(String(describing: self.doximityID))"
        return string
    }
}
