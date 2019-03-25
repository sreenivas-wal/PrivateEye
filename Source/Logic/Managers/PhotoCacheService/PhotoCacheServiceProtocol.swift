//
//  PhotoCacheServiceProtocol.swift
//  MyMobileED
//
//  Created by Created by Admin on 06.05.18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation


typealias PhotoCacheServiceFailureBlock = (_ error: String) -> ()

enum PhotoCacheDestination {
    case new
    case existingNode
    case edited
    
    var description: String {
        switch self {
        case .new:          return "new photos"
        case .existingNode: return "photos with existing node"
        case .edited:       return "edited photos"
        }
    }
}

protocol PhotoCacheServiceProtocol {
    
    func cachedPhotos(for destination: PhotoCacheDestination) -> [Photo]
    
    func clearAllInformation(successBlock: @escaping VoidBlock,
                             failureBlock: @escaping PhotoCacheServiceFailureBlock)

    func cache(photo: Photo,
          identifier: String,
         destination: PhotoCacheDestination,
        successBlock: @escaping VoidBlock,
        failureBlock: @escaping PhotoCacheServiceFailureBlock)

    func removeCachedPhoto(with identifier: String,
                           destinationPath: PhotoCacheDestination,
                              successBlock: @escaping VoidBlock,
                              failureBlock: @escaping PhotoCacheServiceFailureBlock)
}
