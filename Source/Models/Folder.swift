//
//  Folder.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 8/17/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import SwiftyJSON

class Folder: NSObject {
    
    var folderID: String?
    var title: String?
    var subfolders: [Folder] = []
    var photos: [Photo] = []
    var isEditable: Bool = true
    var uid: String?
    var subfoldersCount: Int = 0
    var photosCount: Int = 0
    var contentLoaded: Bool = false
    var isUpdated: Bool = false
    
    init?(json: JSON) {
        super.init()
        
        var folders: [Folder] = []

        if let foldersArray = json["subfolders"].array {
            for currentFolderJSON in foldersArray {
                guard let title = currentFolderJSON["name"].string else { return }
                guard let tid = currentFolderJSON["tid"].string else { return }
                guard let uid = currentFolderJSON["uid"].string else { return }
                guard let editableString = currentFolderJSON["field_editable"]["und"][0]["value"].string else { return }
                let editableInt = Int(editableString)
                let isEditable: Bool = (editableInt != 0)
                
                let photosCount = currentFolderJSON["count"].intValue
                let subfoldersCount = currentFolderJSON["count_subfolders"].intValue
                
                let isUpdated = currentFolderJSON["isUpdated"].boolValue

                let subfolder = Folder(folderID: tid, title: title, isEditable: isEditable, photosCount: photosCount, subfoldersCount: subfoldersCount, isUpdated: isUpdated)
                subfolder.uid = uid
                folders.append(subfolder)
            }
        }
        
        var photos: [Photo] = []

        if let photosArray = json["nodes"].arrayObject {
            for currentPhoto in photosArray {
                if let subJSON = JSON(currentPhoto)["node"].dictionary {
                    if let photo: Photo = Photo(json:JSON(subJSON)) {
                        photo.folder = self
                        photos.append(photo)
                    }
                }
            }
        }
        
        self.subfolders = folders
        self.photos = photos
    }
    
    init(folderID: String?, title: String, isEditable: Bool, photosCount: Int, subfoldersCount: Int, isUpdated: Bool = false) {
        self.folderID = folderID
        self.title = title
        self.isEditable = isEditable
        self.photosCount = photosCount
        self.subfoldersCount = subfoldersCount
        self.isUpdated = isUpdated
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        
        guard let requiredObject = object,
              let comparableObject = requiredObject as? Folder
        else { return false }
        
        return self == comparableObject
    }
}


func == (lhs: Folder, rhs: Folder) -> Bool {
    
    let folderPhotosCountAreEqual = lhs.photosCount == rhs.photosCount
    let folderSubfoldersCountAreEqual = lhs.subfoldersCount == rhs.subfoldersCount
    let folderContentLoadedAreEqual = lhs.contentLoaded == rhs.contentLoaded
    let foldersEditableAreEqual = lhs.isEditable == rhs.isEditable
    
    var folderIDsAreEqual = false
    if let requiredLHSFolderID = lhs.folderID,
       let requiredRHSFolderID = rhs.folderID {
        
        folderIDsAreEqual = requiredLHSFolderID == requiredRHSFolderID
    }
    else if lhs.folderID == nil && rhs.folderID == nil {
        folderIDsAreEqual = true
    }
    
    var folderTitlesAreEqual = false
    if let requiredLHSTitle = lhs.title,
       let requiredRHSTitle = rhs.title {
        
        folderTitlesAreEqual = requiredLHSTitle == requiredRHSTitle
    }
    else if lhs.title == nil && rhs.title == nil {
        folderTitlesAreEqual = true
    }

    var folderUIDsAreEqual = false
    if let requiredLhsUID = lhs.uid,
       let requiredRhsUID = rhs.uid {
        
        folderUIDsAreEqual = requiredLhsUID == requiredRhsUID
    }
    else if lhs.uid == nil && rhs.uid == nil {
        folderUIDsAreEqual = true
    }
    
    let subfoldersAreEqual = lhs.subfolders.elementsEqual(rhs.subfolders)
    let photosAreEqual = lhs.photos.elementsEqual(rhs.photos)
    let isUpdateValueAreEqual = rhs.isUpdated == lhs.isUpdated
    
    return folderPhotosCountAreEqual &&
           folderSubfoldersCountAreEqual &&
           folderContentLoadedAreEqual &&
           foldersEditableAreEqual &&
           folderIDsAreEqual &&
           folderTitlesAreEqual &&
           folderUIDsAreEqual &&
           subfoldersAreEqual &&
           photosAreEqual &&
           isUpdateValueAreEqual
}
