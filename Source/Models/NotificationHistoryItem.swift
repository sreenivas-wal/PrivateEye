//
//  NotificationHistoryItem.swift
//  MyMobileED
//
//  Created by Created by Admin on 24.06.18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation
import SwiftyJSON

extension NotificationHistoryItem {
    
    enum Event {
        case image(id: String)
        case group(id: String)
        case comments(id: String)
        case folder(id: String)
        
        var toString: String {
            
            switch self {
            case .image:       return "image"
            case .group:       return "group"
            case .comments:    return "comments"
            case .folder:      return "folder"
            }
        }
        
        var associatedID: String {
            switch self {
            case .image(let id):       return id
            case .group(let id):       return id
            case .comments(let id):    return id
            case .folder(let id):      return id
            }
        }
        
        static func from(string: String, identifier: String) -> Event? {
            
            switch string {
            case "image":       return .image(id: identifier)
            case "group":       return .group(id: identifier)
            case "comments":    return .comments(id: identifier)
            case "folder":      return .folder(id: identifier)
            default: return nil
            }
        }
        static func mapNotificationTypes(eventType:String) -> String? {
            switch eventType {
            case "subscribe_mmed_comment_in_folder":       return "comments"
            case "subscribe_mmed_comment_in_group":       return "comments"
            case "subscribe_mmed_comment_generic":    return "comments"
            case "subscribe_mmed_group_member_add":      return "group"
            case "subscribe_mmed_group_join":      return "group"
            case "subscribe_mmed_image_in_group":      return "image"
            case "subscribe_mmed_folder_in_group":      return "folder"
            case "subscribe_mmed_image_shared":      return "image"
            case "subscribe_mmed_folder_shared":      return "folder"
                
            default: return ""
            }
        }
        
        static func mapNotificationTypeReference(eventType:String) -> String? {
            switch eventType {
            case "subscribe_mmed_comment_in_folder":       return "field_image_reference"
            case "subscribe_mmed_comment_in_group":       return "field_image_reference"
            case "subscribe_mmed_comment_generic":    return "field_image_reference"
            case "subscribe_mmed_group_member_add":      return "field_group_reference"
            case "subscribe_mmed_group_join":      return "field_group_reference"
            case "subscribe_mmed_image_in_group":      return "field_image_reference"
            case "subscribe_mmed_folder_in_group":      return "field_folder_reference"
            case "subscribe_mmed_image_shared":      return "field_image_reference"
            case "subscribe_mmed_folder_shared":      return "field_folder_reference"
                
            default: return ""
            }
        }
    }
}

class NotificationHistoryItem: NSObject, NSCoding {
    
    let itemID: String
    let message: String
    let timestamp: String
    let eventType: NotificationHistoryItem.Event
    var groupTitle: String?
    var folderTitle: String?
    var groupId: String?
    var memberCount: Int?
    
    init?(json: JSON) {
        
        guard let requiredID = json["mid"].string,
            let requiredMessage = json["message"].string,
            let requiredTimestamp = json["timestamp"].string,
            let requiredType = (json["type"].string),
            let requiredEventType = NotificationHistoryItem.Event.mapNotificationTypeReference(eventType: requiredType),
            let requiredEventTypeID = json[requiredEventType].string,
            let type = NotificationHistoryItem.Event.mapNotificationTypes(eventType: requiredType),
            let requiredEvent = NotificationHistoryItem.Event.from(string: type, identifier: requiredEventTypeID)
            else {
                return nil
        }
        let groupId = (json["group_uid"].string)
        self.itemID = requiredID
        self.message = requiredMessage
        self.timestamp = requiredTimestamp
        self.eventType = requiredEvent
        self.folderTitle = ""
        self.groupTitle = ""
        self.memberCount = 0
        self.groupId = groupId
        if let folderTitle = (json["folder_name"].string) {
            self.folderTitle = folderTitle
        }
        if let groupTitle = (json["group_title"].string) {
            self.groupTitle = groupTitle
        }
        if let memberCount = (json["group_member_count"].int) {
            self.memberCount = memberCount
        }
    }
    
    init(with itemID: String, message: String, timestamp: String, eventType: NotificationHistoryItem.Event, groupTitle: String, groupMemberCount: Int, folderTitle: String ) {
        self.itemID = itemID
        self.message = message
        self.timestamp = timestamp
        self.eventType = eventType
        self.groupTitle = groupTitle
        self.memberCount = groupMemberCount
        self.folderTitle = folderTitle
    }
    
    // MARK: -
    // MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        
        let dictionary = NSMutableDictionary(dictionary: [
            "itemID" : self.itemID,
            "message" : self.message,
            "timestamp" : self.timestamp,
            "eventType" : self.eventType.toString,
            "eventTypeAssociatedID" : self.eventType.associatedID,
            "groupTitle" : self.groupTitle,
            "memberCount" : self.memberCount,
            "folderTitle" : self.folderTitle
            ])
        
        aCoder.encode(dictionary, forKey: NSStringFromClass(NotificationHistoryItem.self))
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        
        guard let requiredObjectDictionary = aDecoder.decodeObject(forKey: NSStringFromClass(NotificationHistoryItem.self)) as? [String : Any],
            let requiredItemID = requiredObjectDictionary["itemID"] as? String,
            let requiredMessage = requiredObjectDictionary["message"] as? String,
            let requiredTimestamp = requiredObjectDictionary["timestamp"] as? String,
            let requiredEventString = requiredObjectDictionary["eventType"] as? String,
            let requiredEventAssociatedID = requiredObjectDictionary["eventTypeAssociatedID"] as? String,
            let requiredEvent = NotificationHistoryItem.Event.from(string: requiredEventString, identifier: requiredEventAssociatedID),
            let folderTitle = requiredObjectDictionary["folderTitle"] as? String,
            let groupTitle = requiredObjectDictionary["groupTitle"] as? String,
            let memberCount = requiredObjectDictionary["memberCount"] as? Int
            else { return nil }
        
        self.init(with: requiredItemID, message: requiredMessage, timestamp: requiredTimestamp, eventType: requiredEvent, groupTitle: groupTitle, groupMemberCount: memberCount, folderTitle: folderTitle)
    }
}
