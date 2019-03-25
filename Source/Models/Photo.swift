//
//  Photo.swift
//  MyMobileED
//
//  Created by Admin on 1/19/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import SwiftyJSON

class Photo: NSObject, NSCoding, NSCopying {
    
    weak var folder: Folder?
    var image: UIImage?
    var title: String?
    var timestamp: String?
    var username: String?
    var link: String?
    var note: String?
    var nodeID: String?
    var folderID: String?
    var folderName: String?
    var uid: String?
    var group: Group?
    var cacheIdenifier: String?
    var isUpdated: Bool = false
    
    init(image: UIImage) {
        self.image = image
        self.cacheIdenifier = UUID().uuidString
    }
        
    init?(json: JSON) {
        let photoTitle = json["title"].string
        let fieldDate = json["field_date"].string
        let link = json["field_image"]["src"].string
        let name = json["name"].string
        let note = json["body"].string
        let nid = json["nid"].string
        let folderID = json["folder"].string
        let uid = json["uid"].string
        let folderName = json["folder-name"].string
        
        var isUpdated = false
        if let isUpdatedStringValue = json["isUpdated"].string,
           let isUpdatedIntValue = Int(isUpdatedStringValue) {
            
            isUpdated = Bool(isUpdatedIntValue as NSNumber)
        }

        self.title = photoTitle
        self.timestamp = fieldDate
        self.link = link
        self.username = name
        self.note = note
        self.nodeID = nid
        self.folderID = folderID
        self.uid = uid
        self.folderName = folderName
        self.isUpdated = isUpdated
        
        self.cacheIdenifier = nid
    }
    
    init(with image: UIImage?,
              title: String?,
          timestamp: String?,
           username: String?,
               link: String?,
               note: String?,
             nodeID: String?,
           folderID: String?,
         folderName: String?,
                uid: String?,
              group: Group?,
          isUpdated: Bool,
     cacheIdenifier: String?) {
        
        self.image = image
        self.title = title
        self.timestamp = timestamp
        self.username =  username
        self.link = link
        self.note = note
        self.nodeID = nodeID
        self.folderID = folderID
        self.folderName = folderName
        self.uid = uid
        self.group = group
        self.isUpdated = isUpdated

        self.cacheIdenifier = cacheIdenifier
    }
    
    // generated
    convenience required init?(coder aDecoder: NSCoder) {
        
        guard let requiredObjectDictionary = aDecoder.decodeObject(forKey: NSStringFromClass(Photo.self)) as? [String : Any] else { return nil }
        
        var image: UIImage? = nil
        if let requiredImage = requiredObjectDictionary["image"] as? UIImage { image = requiredImage }

        var title: String? = nil
        if let requiredTitle = requiredObjectDictionary["title"] as? String { title = requiredTitle }
        
        var timestamp: String? = nil
        if let requiredTimestamp = requiredObjectDictionary["timestamp"] as? String { timestamp = requiredTimestamp }

        var username: String? = nil
        if let requiredUsername = requiredObjectDictionary["username"] as? String { username = requiredUsername }

        var link: String? = nil
        if let requiredLink = requiredObjectDictionary["link"] as? String { link = requiredLink }

        var note: String? = nil
        if let requiredNote = requiredObjectDictionary["note"] as? String { note = requiredNote }

        var nodeID: String? = nil
        if let requiredNodeID = requiredObjectDictionary["nodeID"] as? String { nodeID = requiredNodeID }

        var folderID: String? = nil
        if let requiredFolderID = requiredObjectDictionary["folderID"] as? String { folderID = requiredFolderID }

        var folderName: String? = nil
        if let requiredFolderName = requiredObjectDictionary["folderName"] as? String { folderName = requiredFolderName }

        var uid: String? = nil
        if let requiredUid = requiredObjectDictionary["uid"] as? String { uid = requiredUid }

        var group: Group? = nil
        if let requiredGroup = requiredObjectDictionary["group"] as? Group { group = requiredGroup }

        var cacheIdenifier: String? = nil
        if let requiredCacheIdenifier = requiredObjectDictionary["cacheIdenifier"] as? String { cacheIdenifier = requiredCacheIdenifier }
       
        var isUpdated: Bool = false
        if let requiredIsUpdatedValue = requiredObjectDictionary["isUpdated"] as? Bool { isUpdated = requiredIsUpdatedValue }
        
        self.init(with: image,
                 title: title,
             timestamp: timestamp,
              username: username,
                  link: link,
                  note: note,
                nodeID: nodeID,
              folderID: folderID,
            folderName: folderName,
                   uid: uid,
                 group: group,
             isUpdated: isUpdated,
        cacheIdenifier: cacheIdenifier)
    }
    
    // generated
    internal func encode(with aCoder: NSCoder) {

        var dictionary: [String: Any] = [:]
        
        if let requiredImage = self.image { dictionary["image"] = requiredImage }
        if let requiredTitle = self.title { dictionary["title"] = requiredTitle }
        if let requiredTimestamp = self.timestamp { dictionary["timestamp"] = requiredTimestamp }
        if let requiredUsername = self.username { dictionary["username"] = requiredUsername }
        if let requiredLink = self.link { dictionary["link"] = requiredLink }
        if let requiredNote = self.note { dictionary["note"] = requiredNote }
        if let requiredNodeID = self.nodeID { dictionary["nodeID"] = requiredNodeID }
        if let requiredFolderID = self.folderID { dictionary["folderID"] = requiredFolderID }
        if let requiredFolderName = self.folderName { dictionary["folderName"] = requiredFolderName }
        if let requiredUid = self.uid { dictionary["uid"] = requiredUid }
        if let requiredGroup = self.group { dictionary["group"] = requiredGroup }
        if let requiredCacheIdenifier = self.cacheIdenifier { dictionary["cacheIdenifier"] = requiredCacheIdenifier }
        
        dictionary["isUpdated"] = self.isUpdated
        aCoder.encode(dictionary, forKey: NSStringFromClass(Photo.self))
    }
    
    //MARK: NSCopying
    func copy(with zone: NSZone? = nil) -> Any {
        
        return Photo(with: self.image,
                    title: self.title,
                timestamp: self.timestamp,
                 username: self.username,
                     link: self.link,
                     note: self.note,
                   nodeID: self.nodeID,
                 folderID: self.folderID,
               folderName: self.folderName,
                      uid: self.uid,
                    group: self.group,
                isUpdated: self.isUpdated,
           cacheIdenifier: self.cacheIdenifier)
    }
}
