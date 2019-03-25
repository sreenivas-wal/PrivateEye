//
//  UserProfileRecognizer.swift
//  MyMobileED
//
//  Created by Created by Admin on 09.05.18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation
import SwiftyJSON

enum UserProfileType {
    
    case newUser
    case profileNotFoundforEmail
    case freemiumProfile
    case enterpriseProfile
    case profileNotFoundforNumber
    case profileNotFoundforEmailAndNumber
}

class UserProfileRecognizer {
    
    var accountType: UserProfileType
    var phoneHostNames: [Hostname] = []
    var emailHostNames: [Hostname] = []
    var hostnames: [Hostname] = []

    init?(json: JSON) {
        
        guard json["success"].bool  == true  else { return nil }
        let allHostnames = json["services"].arrayValue
        let aa = "Found a profile by phone number, but it did not match the email address."
        let bb = "Found a profile by email address, but it did not match the phone number."
        let isNewUser = (json["services"].array)
        
        // "Profile Not Found" would be when `by_phone` is not empty but `by_email` is empty.
        // "New User" would be when both are empty.
        if isNewUser != nil && isNewUser?.count == 0 {
            self.accountType = .newUser
            return
        }
        else {
           if (json["services"]["errors"][0]).string == aa && (json["services"]["errors"][1]).string == bb{
                self.accountType = .profileNotFoundforEmailAndNumber
                return
           } else if (json["services"]["errors"][0]).string == bb{
            self.accountType = .profileNotFoundforNumber
            return
           } else if (json["services"]["errors"][0]).string == aa{
            self.accountType = .profileNotFoundforEmail
            return
            }
            self.accountType = .enterpriseProfile
            self.hostnames = allHostnames.flatMap({ Hostname(json: $0) })
        }
    }
}
