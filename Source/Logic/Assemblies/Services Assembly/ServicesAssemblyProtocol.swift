//
//  ServicesAssemblyProtocol.swift
//  MyMobileED
//
//  Created by Admin on 1/13/17.
//
//

import Foundation

protocol ServicesAssemblyProtocol: class {
    var networkManager: NetworkConnectionProtocol? { get set }
    var bluetoothManager: BluetoothManagerProtocol? { get set }
    var userManager: PublicUserProtocol? { get set }
    var photosProvider: PhotosProviderProtocol? { get set }
    var notificationManager: NotificationManagerProtocol? { get set }
    var foldersNavigationDataSource: FoldersNavigationDataSourceProtocol? { get set }
    var menuNavigationDataSource: FoldersNavigationDataSourceProtocol? { get set }
    var validator: Validator? { get set }
    var alertsManager: AlertsManagerProtocol? { get set }
    var contactsService: ContactsServiceProtocol? { get set }
    var reachabilityManager: ReachabilityManager? { get set}
    var photoCacheService: PhotoCacheServiceProtocol { get set }
    var photoCoordinator: PhotoCoordinatorProtocol & PhotoCoordinatorObserverSubscriptionProtocol { get }
    var caseLogsCoordinator: CaseLogsCoordinatorProtocol { get }
    var nm : NotificationManager? { get }
}
