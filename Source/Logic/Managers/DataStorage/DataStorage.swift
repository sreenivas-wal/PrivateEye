//
//  DataStorage.swift
//  MyMobileED
//
//  Created by Created by Admin on 18.06.18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation

typealias NSCodingItem = NSCoding

protocol DataStorageProtocol {
    
    associatedtype DataStorageItem: NSCodingItem
    
    func item(with identifier: String) -> DataStorageItem?
    func removeItem(with identifier: String) -> Bool
    func save(item: DataStorageItem, identifier: String) -> Bool
    func restoreInformation() -> [DataStorageItem]
    func clearStorage()
}

class DataStorage<Item: NSCodingItem>: DataStorageProtocol {
    
    typealias DataStorageItem = Item

    fileprivate let workPath: String
    
    // MARK: -
    // MARK: Class Func
    class func pathToCachedItems(withItemsFolder name: String) -> String? {
        
        guard let requiredDocumentPath = self.applicationDocumentsDirectoryPath() else { return nil }
        
        let dataPath = requiredDocumentPath.appendingPathComponent(name)
        let dataURL = NSURL(fileURLWithPath: dataPath)
        
        return dataURL.path
    }
    
    fileprivate class func applicationDocumentsDirectoryPath() -> NSString? {
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        guard let requiredPath = paths.first else { return nil }
        return requiredPath as NSString
    }

    // MARK: -
    // MARK: Init and Deinit
    init(withContentPath path: String) {
        
        self.workPath = path
        self.createContentFolderIfNeeded(with: path)
    }
    
    // MARK: -
    // MARK: DataStorageProtocol
    func clearStorage() {
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: self.workPath, isDirectory: nil) {
            
            do {
                try fileManager.removeItem(atPath: self.workPath)
                self.createContentFolderIfNeeded(with: self.workPath)
            }
            catch {
                print("DataStorage | Can`t clearStorage")
                return
            }
        }
    }

    func restoreInformation() -> [DataStorageItem] {
        
        let files = FileManager.default.enumerator(atPath: self.workPath)

        var anarchivedFiles: [DataStorageItem] = []
        
        while let file = files?.nextObject() {
            
            if let requiredIdentifier = file as? String {
                
                let fileFullPath = self.workPath + "/\(requiredIdentifier)"
                if let item = NSKeyedUnarchiver.unarchiveObject(withFile: fileFullPath) as? DataStorageItem {
                    anarchivedFiles.append(item)
                }
            }
        }

        return anarchivedFiles
    }
    
    func item(with identifier: String) -> DataStorageItem? {
        
        let files = FileManager.default.enumerator(atPath: self.workPath)
        
        while let file = files?.nextObject() {
            
            if let fileRelativePath = file as? String,
                   fileRelativePath.hasPrefix(identifier) {
                
                let fileFullPath = self.workPath + "/\(fileRelativePath)"
                
                return NSKeyedUnarchiver.unarchiveObject(withFile: fileFullPath) as? DataStorageItem
            }
        }
        
        return nil
    }
    
    @discardableResult
    func removeItem(with identifier: String) -> Bool {
        
        let fileManager = FileManager.default
        let fullPathToItem = self.workPath + "/\(identifier)"

        if fileManager.fileExists(atPath: fullPathToItem) {
            
            do {
                try fileManager.removeItem(atPath: fullPathToItem)
            }
            catch let error {
                print("DataStorage | Failed to remove item -> \(error)")
                return false
            }
        }
        
        return true
    }
    
    func save(item: DataStorageItem, identifier: String) -> Bool {
        
        let fullPathToItem = self.workPath + "/" + identifier
        
        if FileManager.default.fileExists(atPath: fullPathToItem) {
            self.removeItem(with: fullPathToItem)
        }

        guard NSKeyedArchiver.archiveRootObject(item, toFile: fullPathToItem) else {
            print("DataStorage | Failed during to save item | archiveObject failed ")
            return false
        }

        return true
    }
    
    // MARK: -
    // MARK: Private
    fileprivate func createContentFolderIfNeeded(with dataPath: String) {
        
        guard FileManager.default.fileExists(atPath: dataPath) == false else {
            return
        }
        
        if FileManager.default.fileExists(atPath: dataPath) == false {
            
            do {
                try FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: true, attributes: nil)
            }
            catch let error {
                print("DataStorage | CreateDataFolder failed -> \(error.localizedDescription)")
            }
        }
    }
}
