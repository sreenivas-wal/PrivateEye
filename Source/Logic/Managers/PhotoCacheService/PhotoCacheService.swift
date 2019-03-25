//
//  PhotoCacheService.swift
//  MyMobileED
//
//  Created by Created by Admin on 03.05.18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation

class PhotoCacheService: PhotoCacheServiceProtocol {
    
    fileprivate var newPhotosCache: [Photo]
    fileprivate var existingNodePhotosCache: [Photo]
    fileprivate var editedPhotosCache: [Photo]

    init() {
        
        self.newPhotosCache = PhotoCacheService.restoreInformation(from: .new)
        self.existingNodePhotosCache = PhotoCacheService.restoreInformation(from: .existingNode)
        self.editedPhotosCache = PhotoCacheService.restoreInformation(from: .edited)
    }
    
    // MARK: -
    // MARK: PhotoCacheServiceProtocol
    func cachedPhotos(for destination: PhotoCacheDestination) -> [Photo] {
        
        switch destination {
        case .new:          return self.newPhotosCache
        case .existingNode: return self.existingNodePhotosCache
        case .edited:       return self.editedPhotosCache
        }
    }

    func clearAllInformation(successBlock: @escaping VoidBlock,
                             failureBlock: @escaping PhotoCacheServiceFailureBlock) {
        
        DispatchQueue.global(qos: .background).async {
            
            guard let requiredPathToDataFolder = PhotoCacheService.pathToCachedPhotosRootFolder(),
                  FileManager.default.fileExists(atPath: requiredPathToDataFolder)
                else {
                    failureBlock("PhotoCacheService | Failed during to clear all | Can`t find directory")
                    return
            }
            
            do {
                try FileManager.default.removeItem(atPath: requiredPathToDataFolder)
                self.newPhotosCache.removeAll()
                self.existingNodePhotosCache.removeAll()
                successBlock()
            }
            catch let error {
                failureBlock("PhotoCacheService | Failed during to clear all | \(error.localizedDescription)")
            }
        }
    }
    
    func cache(photo: Photo,
          identifier: String,
         destination: PhotoCacheDestination,
        successBlock: @escaping VoidBlock,
        failureBlock: @escaping PhotoCacheServiceFailureBlock) {
    
        PhotoCacheService.createPhotosDataFolderIfNeeded(for: destination)
        
        if let _ = self.photo(with: identifier, destination: destination) {
            successBlock()
            return
        }
        
        guard let newItemPath = self.fullPathToItem(with: identifier, destinationPath: destination) else {
            failureBlock("PhotoCacheService | Failed during to save photo | fullPathToItem == nil")
            return
        }

        guard NSKeyedArchiver.archiveRootObject(photo, toFile: newItemPath) else {
            failureBlock("PhotoCacheService | Failed during to save photo | archiveObject failed ")
            return
        }
        
        switch destination {
        case .new:          self.newPhotosCache.append(photo)
        case .existingNode: self.existingNodePhotosCache.append(photo)
        case .edited:       self.editedPhotosCache.append(photo)
        }

        successBlock()
    }
    
    func removeCachedPhoto(with identifier: String,
                           destinationPath: PhotoCacheDestination,
                              successBlock: @escaping VoidBlock,
                              failureBlock: @escaping PhotoCacheServiceFailureBlock) {
        
        guard self.removePhoto(with: identifier, inDestinationPath: destinationPath) else {
            failureBlock("PhotoCacheService | failred during to remove photo")
            return
        }
        
        switch destinationPath {
        case .new:          self.newPhotosCache = self.newPhotosCache.filter({ $0.cacheIdenifier != identifier })
        case .existingNode: self.existingNodePhotosCache = self.existingNodePhotosCache.filter({ $0.cacheIdenifier != identifier })
        case .edited:       self.editedPhotosCache = self.editedPhotosCache.filter({ $0.cacheIdenifier != identifier })
        }
        
        successBlock()
    }

    // MARK: -
    // MARK: Private
    // TODO: Rewrite with DataStorage Generic
    fileprivate func fullPathToItem(with identifier: String, destinationPath: PhotoCacheDestination) -> String? {
        
        guard let requiredDataFolderPath = PhotoCacheService.pathToCachedPhotosDataFolder(with: destinationPath) else { return nil }
        let itemPath = requiredDataFolderPath + "/\(identifier)"
        
        return itemPath
    }

    fileprivate class func restoreInformation(from destination: PhotoCacheDestination) -> [Photo] {
        
        guard let requiredPathToCahedPhotosDataFolder = PhotoCacheService.pathToCachedPhotosDataFolder(with: destination) else {
            print("PhotoCacheService | requiredPathToCahedPhotosDataFolder does not exist")
            return []
        }
        
        let photoDataFiles = FileManager.default.enumerator(atPath: requiredPathToCahedPhotosDataFolder)

        var anarchivedPhotos: [Photo] = []
        
        while let file = photoDataFiles?.nextObject() {
            
            if let requiredIdentifier = file as? String {
                
                let fileFullPath = requiredPathToCahedPhotosDataFolder + "/\(requiredIdentifier)"
                if let photo = NSKeyedUnarchiver.unarchiveObject(withFile: fileFullPath) as? Photo {
                    anarchivedPhotos.append(photo)
                }
            }
        }

        return anarchivedPhotos
    }
    
    fileprivate func photo(with identifier: String, destination: PhotoCacheDestination) -> Photo? {
        
        guard let dataFolderPath = PhotoCacheService.pathToCachedPhotosDataFolder(with: destination) else {
            print("PhotoCacheService | requiredPathToCahedPhotosDataFolder does not exist")
            return nil
        }
        
        let photoDataFiles = FileManager.default.enumerator(atPath: dataFolderPath)
        
        while let file = photoDataFiles?.nextObject() {
            
            if let fileRelativePath = file as? String,
                   fileRelativePath.hasPrefix(identifier) {
                
                let fileFullPath = dataFolderPath + "/\(fileRelativePath)"
                
                return NSKeyedUnarchiver.unarchiveObject(withFile: fileFullPath) as? Photo
            }
        }
        
        return nil
    }
    
    @discardableResult
    fileprivate func removePhoto(with identifier: String, inDestinationPath: PhotoCacheDestination) -> Bool {
        
        guard let requiredFullPathToItem = self.fullPathToItem(with: identifier, destinationPath: inDestinationPath) else { return false }
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: requiredFullPathToItem) {
            
            do {
                try fileManager.removeItem(atPath: requiredFullPathToItem)
            }
            catch let error {
                print("PhotoCacheService | Failed to remove photo -> \(error)")
                return false
            }
        }
        
        return true
    }

    fileprivate class func createPhotosDataFolderIfNeeded(for destination: PhotoCacheDestination) {
        
        guard let dataPath = self.pathToCachedPhotosDataFolder(with: destination) else { return }
        
        if FileManager.default.fileExists(atPath: dataPath) == false {
            
            do {
                try FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: true, attributes: nil)
            }
            catch let error { print("PhotoCacheService | CreateDataFolder failed -> \(error.localizedDescription)") }
        }
    }
    
    fileprivate class func  pathToCachedPhotosRootFolder() -> String? {
        
        guard let requiredDocumentPath = self.applicationDocumentsDirectoryPath() else { return nil }
        
        let dataPath = requiredDocumentPath.appendingPathComponent("ChachedPhotos")
        let dataURL = NSURL(fileURLWithPath: dataPath)
        
        return dataURL.path
    }
    
    fileprivate class func  pathToCachedPhotosDataFolder(with destination: PhotoCacheDestination) -> String? {
        
        guard let requiredRootPath = self.pathToCachedPhotosRootFolder() else { return nil }
        return requiredRootPath + "/\(destination.description)"
    }
    
    fileprivate class func  applicationDocumentsDirectoryPath() -> NSString? {
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        guard let requiredPath = paths.first else { return nil }
        return requiredPath as NSString
    }
}
