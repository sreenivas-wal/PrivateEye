//
//  ReachabilityManager.swift
//  MyMobileED
//
//  Created by Created by Admin on 02.05.18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation
import Reachability

protocol ReachabilityManagerObserverProtocol {
    
    func reachabilityManagerDidReceiveNotReachableStatus(_ manager: ReachabilityManager)
    func reachabilityManagerDidReceiveReachableStatus(_ manager: ReachabilityManager)
}

protocol ReachabilityManagerObserverSubscriptionProtocol: class {
    
    func subscribeForReachabilityChanges(observer: ReachabilityManagerObserverProtocol)
    func unsubscribeFromReachabilityChanges(observer: ReachabilityManagerObserverProtocol)
}

extension ReachabilityManagerObserverProtocol {
    
    func reachabilityManagerDidReceiveNotReachableStatus(_ manager: ReachabilityManager) {}
    func reachabilityManagerDidReceiveReachableStatus(_ manager: ReachabilityManager) {}
}

class ReachabilityManager {
    
    fileprivate let manager: Reachability
    fileprivate let observers = WeakPointerArray<ReachabilityManagerObserverProtocol>()

    // MARK: - Init and Deinit
    init?(with baseUrlString: String) {
        
        guard let reachability = Reachability() else { return nil }
        
        do {
            try reachability.startNotifier()
        }
        catch {
            return nil
        }
        
        self.manager = reachability
        self.manager.whenUnreachable = { reachability in
            
            self.notifyObserversAboutNotReachableStatus()
        }
        
        self.manager.whenReachable = { reachability in
            
            self.notifyObserversAboutReachableStatus()
        }
    }
    
    deinit {
        self.manager.stopNotifier()
    }
    
    // MARK: - ReachabilityManagerObserverSubscriptionProtocol
    func subscribeForReachabilityChanges(observer: ReachabilityManagerObserverProtocol) {
        
        self.observers.add(observer)
    }
    
    func unsubscribeFromReachabilityChanges(observer: ReachabilityManagerObserverProtocol) {
        
        self.observers.remove(observer)
    }
    
    // MARK: - Private
    fileprivate func notifyObserversAboutNotReachableStatus() {
        
        DispatchQueue.main.async {
            self.observers.forEach { $0.reachabilityManagerDidReceiveNotReachableStatus(self) }
        }
    }
    
    fileprivate func notifyObserversAboutReachableStatus() {
        
        DispatchQueue.main.async {
            self.observers.forEach { $0.reachabilityManagerDidReceiveReachableStatus(self) }
        }
    }
}
