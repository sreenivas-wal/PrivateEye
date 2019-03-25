//
//  CaseLogsCoordinator.swift
//  MyMobileED
//
//  Created by Created by Admin on 18.06.18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation

class  CaseLogsCoordinator: CaseLogsCoordinatorProtocol, ReachabilityManagerObserverProtocol {
    
    fileprivate let networkManager: CaseConnectionProtocol
    fileprivate let cacheService: CaseLogsCacheServiceProtocol
    fileprivate var reachabilityManager: ReachabilityManager?
    
    // MARK: -
    // MARK: Init and Deinit
    init(with networkManager: CaseConnectionProtocol,
                cacheService: CaseLogsCacheServiceProtocol,
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
    // MARK: CaseLogsCoordinatorProtocol
    func upload(caselog: CaseLog) {
        
        switch caselog.actionType {
        case .screenShot:
            self.logScreenshot(caselog)
            
        case .connectionUnsuccessful:
            self.logBluetoothDisconnected(caselog)
            
        case .caseNotConnected:
            self.logCaseDisconnected(caselog)
            
        case .connectionUnsecure:
            self.logCaseDisconnected(caselog)
        }
    }
    
   func performCacheUploadIfNeeded() {
    
        self.cacheService.cachedLogs { (logs) in
            
            guard logs.isEmpty == false else { return }
            
            DispatchQueue.global(qos: .background).async { [weak self] in

                for log in logs {
                    self?.upload(caselog: log)
                }
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
    fileprivate func logScreenshot(_ caselog: CaseLog) {
        
        self.networkManager.logScreenshot(caselog,
                                          successBlock: { [weak self] (response) -> (Void) in
                                              self?.remove(caselog)
                                          },
                                          failureBlock: { [weak self] (response) -> (Void) in
                                            
                                              guard response.code == 0 else {
                                                  // error from server, but we expect urlconnection error
                                                  return
                                              }

                                              self?.cache(caselog)
                                          })
    }
    
    fileprivate func logCaseDisconnected(_ caselog: CaseLog) {
        
        self.networkManager.logCaseDisconnected(caselog,
                                                successBlock: { [weak self] (response) in
                                                    self?.remove(caselog)
                                                },
                                                failureBlock: { [weak self] (response) in
                                                    
                                                    guard response.code == 0 else {
                                                        // error from server, but we expect urlconnection error
                                                        return
                                                    }

                                                    self?.cache(caselog)
                                                })
    }

    fileprivate func logBluetoothDisconnected(_ caselog: CaseLog) {
        
        self.networkManager.logBluetoothDisconnected(caselog,
                                                     successBlock: { [weak self] (response) in
                                                         self?.remove(caselog)
                                                     },
                                                     failureBlock: { [weak self] (response) in
                                                        
                                                         guard response.code == 0 else {
                                                             // error from server, but we expect urlconnection error
                                                             return
                                                         }

                                                         self?.cache(caselog)
                                                     })
    }
    
    fileprivate func cache(_ caselog: CaseLog) {
        
        self.cacheService.cache(caselog: caselog,
                           successBlock: {},
                           failureBlock: { (reason) in
                               print(reason)
                           })
    }

    fileprivate func remove(_ caselog: CaseLog) {
        
        self.cacheService.remove(caselog: caselog,
                            successBlock: {},
                            failureBlock: { (reason) in
                                print(reason)
                            })
    }
}
