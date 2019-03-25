//
//  PhotoCoordinator.swift
//  MyMobileED
//
//  Created by Created by Admin on 03.05.18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation

class PhotoCoordinator: PhotoCoordinatorProtocol,
                        ReachabilityManagerObserverProtocol,
                        PhotoCoordinatorObserverSubscriptionProtocol {

    typealias CachingResultBlock = (_ result: CachingResult) -> ()

    enum CachingResult {
        case cached(totalCount: Int)
        case failed(reason: String)
    }
    
    // MARK: -
    // MARK: Properties
    fileprivate let networkManager: PhotosNetworkProtocol
    fileprivate let cacheService: PhotoCacheServiceProtocol
    fileprivate var reachabilityManager: ReachabilityManager?
    fileprivate let observers = WeakPointerArray<PhotoCoordinatorObserverProtocol>()

    fileprivate var unsentPhotos: [Photo] = []
    fileprivate let unsentLock = NSLock()
    fileprivate let bgService = BackgroundModeService()

    // MARK: -
    // MARK: Init and Deinit
    init(with networkManager: PhotosNetworkProtocol,
                cacheService: PhotoCacheServiceProtocol,
         reachabilityManager: ReachabilityManager?) {
        
        self.networkManager = networkManager
        self.cacheService = cacheService
        self.reachabilityManager = reachabilityManager
        reachabilityManager?.subscribeForReachabilityChanges(observer: self)
    }
    
    deinit {
        reachabilityManager?.unsubscribeFromReachabilityChanges(observer: self)
    }

    // MARK: -
    // MARK: PhotoCoordinatorProtocol
    func uploadNewPhoto(photo: Photo,
                   completion: @escaping PhotoCoordinatorResultBlock) {
        
        bgService.registerBackgroundTask()
        self.performUploadNewPhoto(photo: photo,
                              completion: { [weak self] (result) in
                   
                                  if case .cached(let totalCount) = result {
                                      self?.notifyObserversAboutCachedItems(count: totalCount)
                                  }
                                
                                  completion(result)
                                  self?.bgService.endBackgroundTask()
                              })
    }
    
    func uploadPhotoToExtistingNode(_ photo: Photo, completion: @escaping PhotoCoordinatorResultBlock) {
        
        bgService.registerBackgroundTask()
        self.performUploadPhotoToExtistingNode(photo,
                                               completion: { [weak self] (result) in
                    
                                                   if case .cached(let totalCount) = result {
                                                       self?.notifyObserversAboutCachedItems(count: totalCount)
                                                   }
                                                
                                                   completion(result)
                                                   self?.bgService.endBackgroundTask()
                                               })
    }
    
    func uploadEditedPhoto(_ photo: Photo, completion: @escaping PhotoCoordinatorResultBlock) {
        
        bgService.registerBackgroundTask()
        self.performUploadEditedPhoto(photo,
                                      completion: { [weak self] (result) in
                                        
                                          if case .cached(let totalCount) = result {
                                              self?.notifyObserversAboutCachedItems(count: totalCount)
                                          }
                                        
                                          completion(result)
                                          self?.bgService.endBackgroundTask()
                                      })
    }
    
    func performCacheUploadIfNeeded() {
        
        DispatchQueue.global(qos: .background).async {

            let startCachedItemCount = self.totalCountOfUnsentItems()
            
            let group = DispatchGroup()
            
            let existingNodePhotos = self.cacheService.cachedPhotos(for: .existingNode)
            if existingNodePhotos.isEmpty == false {
                
                for value in existingNodePhotos {
                    
                    group.enter()
                    self.performUploadPhotoToExtistingNode(value, completion: { (result) in
                        
                        switch result {
                        case .failed(let reason): print(reason)
                        default: break
                        }
                        group.leave()
                    })
                }
            }
            
            group.wait()
            
            let newPhotos = self.cacheService.cachedPhotos(for: .new)
            if newPhotos.isEmpty == false {
                
                for value in newPhotos {
                    
                    group.enter()
                    self.performUploadNewPhoto(photo: value,
                                          completion: { (result) in
                                            
                                              switch result {
                                              case .failed(let reason): print(reason)
                                              default: break
                                              }
                                            
                                              group.leave()
                                          })
                }
            }
            
            group.wait()
            
            let editedPhotos = self.cacheService.cachedPhotos(for: .edited)
            if editedPhotos.isEmpty == false {
                
                for value in editedPhotos {
                    
                    group.enter()
                    self.performUploadEditedPhoto(value,
                                                  completion: { (result) in
                                                    
                                                      switch result {
                                                      case .failed(let reason): print(reason)
                                                      default: break
                                                      }
                                                      group.leave()
                                                  })
                }
            }
            
            group.wait()
            
            let endCachedItemCount = self.totalCountOfUnsentItems()
            if startCachedItemCount > endCachedItemCount {
                self.notifyObserversAboutSuccessUploadCachedItems()
            }
        }
    }
    
    // MARK: -
    // MARK: ReachabilityManagerObserverProtocol
    func reachabilityManagerDidReceiveReachableStatus(_ manager: ReachabilityManager) {
        
        self.performCacheUploadIfNeeded()
    }
    
    // MARK: -
    // MARK: Private
    fileprivate func cache(photo: Photo, destination: PhotoCacheDestination, completion: @escaping CachingResultBlock) {
    
        guard let requiredCacheIdentifier = photo.cacheIdenifier
        else {
            completion(.failed(reason: "PhotoCoordinator | No required cacheIdenifier"))
            return
        }
        
        guard self.unsentPhotos.contains(where: {$0.cacheIdenifier == requiredCacheIdentifier }) == false else {
            
            self.cacheService.removeCachedPhoto(with: requiredCacheIdentifier,
                                     destinationPath: destination,
                                        successBlock: {
                                            
                                            self.cacheService.cache(photo: photo,
                                                               identifier: requiredCacheIdentifier,
                                                              destination: destination,
                                                             successBlock: {
                                                            
                                                                 completion(.cached(totalCount: self.totalCountOfUnsentItems()))
                                                             },
                                                             failureBlock: { (error) in
                                                            
                                                                 completion(.failed(reason: error))
                                                             })
                                        },
                                        failureBlock: { (error) in
                                            completion(.failed(reason: error))
                                        })
            return
        }

        self.cacheService.cache(photo: photo,
                           identifier: requiredCacheIdentifier,
                          destination: destination,
                         successBlock: {
                        
                             self.unsentPhotos.append(photo)
                             completion(.cached(totalCount: self.totalCountOfUnsentItems()))
                         },
                         failureBlock: { (error) in
                        
                             completion(.failed(reason: error))
                         })
    }
    
    fileprivate func removeCachedPhotoIfNeeded(photo: Photo, destination: PhotoCacheDestination) {
        
        guard let requiredCacheIdentifier = photo.cacheIdenifier else { return }
        
        DispatchQueue.global(qos: .background).async {

            self.cacheService.removeCachedPhoto(with: requiredCacheIdentifier,
                                     destinationPath: destination,
                                        successBlock: {},
                                        failureBlock: { (error) in print(error) })

            if self.unsentLock.try() {
                
                for (index, value) in self.unsentPhotos.enumerated() {
                    if photo.cacheIdenifier == value.cacheIdenifier {
                        self.unsentPhotos.remove(at: index)
                    }
                }
                
                self.unsentLock.unlock()
            }
        }
    }
    
    fileprivate func totalCountOfUnsentItems() -> Int {
        
        let existingNodeItems = self.cacheService.cachedPhotos(for: .existingNode)
        let newItems = self.cacheService.cachedPhotos(for: .new)
        let editedItems = self.cacheService.cachedPhotos(for: .edited)
        
        let totalCount = existingNodeItems.count + newItems.count + editedItems.count
        
        return totalCount
    }
    
    fileprivate func performUploadNewPhoto(photo: Photo,
                                      completion: @escaping PhotoCoordinatorResultBlock) {
        self.cache(photo: photo,
             destination: .new,
              completion: { (cachingResult) in
              
                self.networkManager.uploadPhotoToNewNode(
                    photo,
                    successBlock: { [weak self] (response) -> () in
                        
                        self?.removeCachedPhotoIfNeeded(photo: photo, destination: .new)
                        
                        let attachedNode = response.object as! Node
                        photo.nodeID = attachedNode.nodeID
                        photo.link = attachedNode.nodeID
                        
                        completion(.uploaded(photo: photo))
                    },
                    failureBlock: { [weak self] (response) -> () in
                        
                        guard response.code == 0 else {
                            
                            // Not connection error
                            self?.removeCachedPhotoIfNeeded(photo: photo, destination: .new)
                            completion(.failed(reason: response.message))
                            return
                        }
                        
                        switch cachingResult {
                        case .cached(let totalCount):
                            completion(.cached(totalCount: totalCount))
                        case .failed(let cacheFailReason):
                            completion(.failed(reason: cacheFailReason))
                        }
                   })
              })
    }
    
    fileprivate func performUploadPhotoToExtistingNode(_ photo: Photo, completion: @escaping PhotoCoordinatorResultBlock) {
        
        self.cache(photo: photo,
             destination: .existingNode,
              completion: { (cachingResult) in
                
                  self.networkManager.uploadPhotoToExtistingNode(
                      photo,
                      successBlock: { [weak self] (response) -> () in
                        
                          completion(.uploaded(photo: nil))
                          self?.removeCachedPhotoIfNeeded(photo: photo, destination: .existingNode)
                      },
                      failureBlock: { [weak self] (response) -> () in
                        
                          guard response.code == 0 else {
                            
                              // Not connection error
                              self?.removeCachedPhotoIfNeeded(photo: photo, destination: .existingNode)
                              completion(.failed(reason: response.message))
                              return
                          }

                          switch cachingResult {
                          case .cached(let totalCount):
                            completion(.cached(totalCount: totalCount))

                          case .failed(let cacheFailReason):
                            completion(.failed(reason: cacheFailReason))
                          }
                      })
              })
    }
    
    fileprivate func performUploadEditedPhoto(_ photo: Photo, completion: @escaping PhotoCoordinatorResultBlock) {

        self.cache(photo: photo,
             destination: .edited,
              completion: { (cachingResult) in
                
                self.networkManager.editPhoto(
                    fromPhoto: photo,
                 successBlock: { [weak self] (response) -> () in
                    
                        completion(.uploaded(photo: nil))
                        self?.removeCachedPhotoIfNeeded(photo: photo, destination: .edited)
                 },
                 failureBlock: { [weak self] (response) -> () in
                    
                    guard response.code == 0 else {
                        
                        // Not connection error
                        self?.removeCachedPhotoIfNeeded(photo: photo, destination: .edited)
                        completion(.failed(reason: response.message))
                        return
                    }

                    switch cachingResult {
                    case .cached(let totalCount):
                        completion(.cached(totalCount: totalCount))

                    case .failed(let cacheFailReason):
                        completion(.failed(reason: cacheFailReason))
                    }
                 })
              })
    }
    
    // MARK: -
    // MARK: Private ( Observers )
    fileprivate func notifyObserversAboutCachedItems(count: Int) {
        
        DispatchQueue.main.async {
            self.observers.forEach { $0.photoCoordinator(self, didCacheItems: count) }
        }
    }
    
    fileprivate func notifyObserversAboutSuccessUploadCachedItems() {
        
        DispatchQueue.main.async {
            self.observers.forEach { $0.photoCoordinatorDidUploadCachedItems(self) }
        }
    }
    
    // MARK: -
    // MARK: PhotoCoordinatorObserverSubscriptionProtocol 
    func subscribeForPhotoCoordinatorChanges(observer: PhotoCoordinatorObserverProtocol) {
        
        self.observers.add(observer)
    }
    
    func unsubscribeFromPhotoCoordinatorChanges(observer: PhotoCoordinatorObserverProtocol) {
        
        self.observers.remove(observer)
    }
}
