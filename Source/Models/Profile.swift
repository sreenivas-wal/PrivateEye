//
//  Profile.swift
//  MyMobileED
//
//  Created by Admin on 1/26/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import SwiftyJSON

class Profile: NSObject, NSCoding {
    var username: String?
    var email: String?
    var phone: String?
    var company: String?
    var organization: String?
    
    init?(json: JSON) {
        guard let username = json["name"].string else { return }
        guard let email = json["mail"].string else { return }
        guard let phone = json["field_phone"]["und"][0]["value"].string else { return }
        
        self.username = username
        self.email = email
        self.phone = phone
        
        if let company = json["field_company"]["und"][0]["value"].string {
            self.company = company
        }
        
        if let organization = json["field_department"]["und"][0]["value"].string {
            self.organization = organization
        }
    }
    
    init?(username: String?, phone: String?) {
        if let name = username {
            self.username = name
        }
        
        if let phoneNumber = phone {
            self.phone = phoneNumber
        }
    }

    // generated
    required internal init?(coder aDecoder: NSCoder) {
        self.username = aDecoder.decodeObject(forKey: "username") as! String?
        self.email = aDecoder.decodeObject(forKey: "email") as! String?
        self.phone = aDecoder.decodeObject(forKey: "phone") as! String?
        self.company = aDecoder.decodeObject(forKey: "company") as! String?
        self.organization = aDecoder.decodeObject(forKey: "organization") as! String?
    }

    // generated
    internal func encode(with aCoder: NSCoder) {
        aCoder.encode(self.username, forKey: "username")
        aCoder.encode(self.email, forKey: "email")
        aCoder.encode(self.phone, forKey: "phone")
        aCoder.encode(self.company, forKey: "company")
        aCoder.encode(self.organization, forKey: "organization")
    }

    // generated
    override internal var description: String {
        var string = "\(type(of: self)): "
        string += "username = \(String(describing: self.username)), "
        string += "email = \(String(describing: self.email)), "
        string += "phone = \(String(describing: self.phone)), "
        string += "company = \(String(describing: self.company)), "
        string += "organization = \(String(describing: self.organization))"
        return string
    }
}
