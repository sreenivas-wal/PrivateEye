//
//  PhotoCoordinatorProtocol.swift
//  MyMobileED
//
//  Created by Created by Admin on 06.05.18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation

typealias PhotoCoordinatorResultBlock = (_ result: PhotoCoordinatorResult) -> ()

enum PhotoCoordinatorResult {
    
    case cached(totalCount: Int)
    case uploaded(photo: Photo?)
    case failed(reason: String)
}

protocol PhotoCoordinatorProtocol {
    
    func uploadPhotoToExtistingNode(_ photo: Photo,
                                 completion: @escaping PhotoCoordinatorResultBlock)
    
    func uploadNewPhoto(photo: Photo,
                   completion: @escaping PhotoCoordinatorResultBlock)
    
    func uploadEditedPhoto(_ photo: Photo,
                        completion: @escaping PhotoCoordinatorResultBlock)
    
    func performCacheUploadIfNeeded()
}

protocol PhotoCoordinatorObserverSubscriptionProtocol: class {
    
    func subscribeForPhotoCoordinatorChanges(observer: PhotoCoordinatorObserverProtocol)
    func unsubscribeFromPhotoCoordinatorChanges(observer: PhotoCoordinatorObserverProtocol)
}

protocol PhotoCoordinatorObserverProtocol {
    
    func photoCoordinator(_ coordinator: PhotoCoordinatorProtocol, didCacheItems totalCount: Int)
    func photoCoordinatorDidUploadCachedItems(_ coordinator: PhotoCoordinatorProtocol)
}

extension PhotoCoordinatorObserverProtocol {

    func photoCoordinator(_ coordinator: PhotoCoordinatorProtocol, didCacheItems totalCount: Int) {}
    func photoCoordinatorDidUploadCachedItems(_ coordinator: PhotoCoordinatorProtocol) {}
}

