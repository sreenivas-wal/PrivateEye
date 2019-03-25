//
//  Group.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 1/22/18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit
import SwiftyJSON

class Group: NSObject, NSCoding {
    
    var groupID: String?
    var title: String?
    var usersCount: Int = 0
    var ownerId: String?
    var ownerName: String?
    
    init(groupID: String) {
        self.groupID = groupID
    }
    
    init?(json: JSON) {
        guard let groupID = json["nid"].string else { return }
        guard let ownerId = json["uid"].string else { return }
        let title = json["title"].string
        let ownerName = json["name"].string
        
        self.groupID = groupID
        self.title = title
        self.ownerId = ownerId
        self.ownerName = ownerName
    }
    
    init(with groupID: String?, title: String?, usersCount: Int, ownerId: String?, ownerName: String?) {
        
        self.groupID = groupID
        self.title = title
        self.usersCount = usersCount
        self.ownerId = ownerId
        self.ownerName = ownerName
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        
        guard let requiredObjectDictionary = aDecoder.decodeObject(forKey: NSStringFromClass(Group.self)) as? [String : Any],
              let requiredUsersCount = requiredObjectDictionary["usersCount"] as? Int
        else { return nil }
        
        var groupID: String? = nil
        if let requiredGroupID = requiredObjectDictionary["groupID"] as? String { groupID = requiredGroupID }
        
        var title: String? = nil
        if let requiredTitle = requiredObjectDictionary["title"] as? String { title = requiredTitle }
        
        var ownerId: String? = nil
        if let requiredOwnerId = requiredObjectDictionary["ownerId"] as? String { ownerId = requiredOwnerId }
        
        var ownerName: String? = nil
        if let requiredOwnerName = requiredObjectDictionary["ownerName"] as? String { ownerName = requiredOwnerName }
        
        self.init(with: groupID,
                 title: title,
            usersCount: requiredUsersCount,
               ownerId: ownerId,
             ownerName: ownerName)
    }
    
    internal func encode(with aCoder: NSCoder) {
        
        var dictionary: [String: Any] = [ "usersCount" : self.usersCount ]
        
        if let requiredGroupID = self.groupID { dictionary["groupID"] = requiredGroupID }
        if let requiredTitle = self.title { dictionary["title"] = requiredTitle }
        if let requiredOwnerId = self.ownerId { dictionary["ownerId"] = requiredOwnerId }
        if let requiredOwnerName = self.ownerName { dictionary["ownerName"] = requiredOwnerName }
        
        aCoder.encode(dictionary, forKey: NSStringFromClass(Group.self))
    }
}
