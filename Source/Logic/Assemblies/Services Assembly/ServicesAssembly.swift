//
//  ServicesAssembly.swift
//  MyMobileED
//
//  Created by Admin on 1/13/17/Users/manishan/PrivateEyeHC/Source/Logic/Assemblies/Services Assembly/ServicesAssembly.swift.
//
//

import Foundation

class ServicesAssembly: NSObject, ServicesAssemblyProtocol {
    
 
    lazy var networkManager: NetworkConnectionProtocol? = {
        let networkManager = NetworkManager()
        networkManager.userManager = self.userManager as! SessionUserProtocol?
        networkManager.locationService = self.locationService
        networkManager.bluetoothManager = self.bluetoothManager
        return networkManager
    }()
    
    lazy var photosProvider: PhotosProviderProtocol? = {
        return PhotosProvider(networkManager: self.networkManager as! PhotosNetworkProtocol)
    }()
    
    lazy var bluetoothManager: BluetoothManagerProtocol? = {
        
        if FeatureFlags.smartCaseEnabled {
            
            return BluetoothManager()
        }
        else {
            
            return DummyBluetoothManager()
        }
    }()
    
    lazy var userManager: PublicUserProtocol? = {
        return UserManager()
    }()
    
    lazy var nm: NotificationManager? = {
        return NotificationManager(networkManager: self.networkManager as! PushNotificationProtocol)
    }()
    

    lazy var notificationManager: NotificationManagerProtocol? = {
        return NotificationManager(networkManager: self.networkManager as! PushNotificationProtocol)
    }()
    
    lazy var locationService: LocationServiceProtocol? = {
        return LocationService()
    }()
    
    lazy var foldersNavigationDataSource: FoldersNavigationDataSourceProtocol? = {
        return FoldersNavigationDataSource()
    }()
    
    lazy var menuNavigationDataSource: FoldersNavigationDataSourceProtocol? = {
        return FoldersNavigationDataSource()
    }()
    
    lazy var validator: Validator? = {
        return Validator()
    }()
    
    lazy var alertsManager: AlertsManagerProtocol? = {
        return AlertsManager(validator: self.validator)
    }()
    
    lazy var contactsService: ContactsServiceProtocol? = {
        return ContactsService()
    }()
    
    lazy var reachabilityManager: ReachabilityManager? = {
        return ReachabilityManager(with: Hostname.defaultHostname().fullHostDomainLink())
    }()
    
    lazy var photoCacheService: PhotoCacheServiceProtocol = {
       return PhotoCacheService()
    }()
    
    lazy var caseLogsCacheService: CaseLogsCacheServiceProtocol = {
        return CaseLogsCacheService()
    }()
    
    lazy var photoCoordinator: PhotoCoordinatorProtocol & PhotoCoordinatorObserverSubscriptionProtocol = {
       return PhotoCoordinator(with: self.networkManager as! PhotosNetworkProtocol,
                       cacheService: self.photoCacheService,
                reachabilityManager: self.reachabilityManager)
    }()
    
    lazy var caseLogsCoordinator: CaseLogsCoordinatorProtocol = {
        
        if FeatureFlags.smartCaseEnabled {
            
            return CaseLogsCoordinator(with: self.networkManager as! CaseConnectionProtocol,
                               cacheService: self.caseLogsCacheService,
                        reachabilityManager: self.reachabilityManager)
        }
        else {
            
            return DummyCaseLogsCoordinator()
        }
    }()
}
