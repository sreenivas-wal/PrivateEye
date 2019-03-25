//
//  PhotoProvider.swift
//  MyMobileED
//
//  Created by Admin on 2/8/17.
//  Copyright © 2017 Company. All rights reserved.
//

import Foundation

class PhotosProvider: NSObject, PhotosProviderProtocol {
    
    private let photosDirectoryName = "Photos"
    private let previewPhotosDirectoryName = "Preview"
    
    var fileManager: FileManager = FileManager.default
    var networkManager: PhotosNetworkProtocol?
    
    init?(networkManager: PhotosNetworkProtocol) {
        super.init()
        
        self.networkManager = networkManager
    }

    private func documentsDirectory(isPreview: Bool) -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let directory = isPreview == true ? previewPhotosDirectoryName : photosDirectoryName
        let directoryPath = documentsDirectory.appendingPathComponent(directory)
        
        if fileManager.fileExists(atPath: directoryPath.path) == false {
            do {
                try fileManager.createDirectory(atPath: directoryPath.path, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        return directoryPath
    }
    
    func retrieveImage(byNodeID nodeID: String,
                       successBlock: @escaping (_ image: UIImage) -> (),
                       failureBlock: @escaping ((_ message: String) -> ())) -> NetworkRequest?
    {
        let photoPath = nodeID.appending(".png")
        let filePath = documentsDirectory(isPreview: false).appendingPathComponent(photoPath)
        print("File path = \(filePath)")
        
        if fileManager.fileExists(atPath: filePath.path) == true {
            if let data = fileManager.contents(atPath: filePath.path) {
                if let image = UIImage(data: data) {
                    successBlock(image)
                    
                    return nil
                }
            }
            
            failureBlock("Can't retrieve photo.")
        } else {
            return self.networkManager?.retrieveImage(byNode: nodeID, successBlock: { (response) -> (Void) in
                if let image = response.object as? UIImage {
                    successBlock(image)
                    
                    if let data = UIImagePNGRepresentation(image) {
                        try? data.write(to: filePath)
                    }
                } else {
                    failureBlock("Can't map image.")
                }
            }, failureBlock: { (error) -> (Void) in
                failureBlock(error.message)
                print("Error - \(error.message)")
            })
        }
        
        return nil
    }
    
    func retrievePreviewPhoto(byUrl url: URL,
                              successBlock: @escaping (_ image: UIImage) -> (),
                              failureBlock: @escaping ((_ message: String) -> ())) -> NetworkRequest? {
        
        let photoPath = url.lastPathComponent.appending(".png")
        let filePath = documentsDirectory(isPreview: true).appendingPathComponent(photoPath)
        
        if fileManager.fileExists(atPath: filePath.path) == true {
            if let data = fileManager.contents(atPath: filePath.path) {
                if let image = UIImage(data: data) {
                    successBlock(image)
                    
                    return nil
                }
            }

            failureBlock("Can't fetch image")
        } else {
            self.networkManager?.loadImage(fromURL: url, successBlock: { (data) -> (Void) in
                let image = UIImage(data: data)
                
                if let validImage = image {
                    if let data = UIImagePNGRepresentation(validImage) {
                        try? data.write(to: filePath)
                    }
                    
                    DispatchQueue.main.async {
                        successBlock(validImage)
                    }
                }
            }, failureBlock: { (error) -> (Void) in
                print("Error = \(error)")
            })
        }
        
        return nil
    }
    
    func replaceImage(_ image: UIImage, withNodeID nodeID: String) {
        let photoPath = nodeID.appending(".png")
        let filePath = documentsDirectory(isPreview: false).appendingPathComponent(photoPath)

        if fileManager.fileExists(atPath: filePath.path) == true {
            try? fileManager.removeItem(atPath: filePath.path)
            
            if let data = UIImagePNGRepresentation(image) {
                try? data.write(to: filePath)
            }
        }
    }
    
    func removeImage(withNodeID nodeID: String) {
        let photoPath = nodeID.appending(".png")
        let filePath = documentsDirectory(isPreview: false).appendingPathComponent(photoPath)
        
        if fileManager.fileExists(atPath: filePath.path) == true {
            try? fileManager.removeItem(atPath: filePath.path)
        }
    }
    
    func deleteOldPhotos() {
        let previewPhotosDirectory = documentsDirectory(isPreview: true)
        deletePhotos(fromDirectory: previewPhotosDirectory)
        
        let photosDirectoryPath = documentsDirectory(isPreview: false)
        deletePhotos(fromDirectory: photosDirectoryPath)
    }
    
    func deletePhotos(fromDirectory directory: URL) {
        let optionMask: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]
        let keys = [URLResourceKey.contentModificationDateKey]
        
        let currentCalendar = NSCalendar.current
        let deadlineDate = currentCalendar.date(byAdding: .day, value: -1, to: Date())
        
        guard let photos = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: keys, options: optionMask) else { return }
        
        for photo in photos {
            do {
                let values = try photo.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey])
                
                if let date = values.creationDate {
                    if deadlineDate! > date {
                        try? fileManager.removeItem(atPath: photo.path)
                    }
                }
            } catch let error as NSError {
                print("Error deleting = \(error)")
            }
        }
    }
}
