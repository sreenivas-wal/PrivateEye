//
//  NotificationsAssembly.swift
//  MyMobileED
//
//  Created by Created by Admin on 14.06.18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation

class NotificationsAssembly: NotificationsAssemblyProtocol {
    
    let servicesAssembly: ServicesAssemblyProtocol

    required init(withServicesAssembly servicesAssembly: ServicesAssemblyProtocol) {
        self.servicesAssembly = servicesAssembly
    }
    
    // MARK: -
    // MARK: NotificationsAssemblyProtocol
    func assemblyNotificationSettingsViewController(with transition: NotificationsRoutingTransition) -> NotificationSettingsViewController {
        
        let settingsViewController = self.storyboard.instantiateViewController(withIdentifier: "NotificationSettingsViewController") as! NotificationSettingsViewController
        settingsViewController.transition = transition
        settingsViewController.notificationsNetworkManager = self.servicesAssembly.networkManager as! NotificationsNetworkProtocol
        settingsViewController.bluetoothManager = self.servicesAssembly.bluetoothManager
        settingsViewController.networkCaseConnectionManager = self.servicesAssembly.networkManager as? CaseConnectionProtocol

        return settingsViewController
    }
    
    func assemblyNotificationHistoryListViewController(with transition: NotificationsRoutingTransition) -> NotificationHistoryListViewController {
        
        let historyListViewController = self.storyboard.instantiateViewController(withIdentifier: "NotificationHistoryListViewController") as! NotificationHistoryListViewController
        historyListViewController.transition = transition
        
        historyListViewController.bluetoothManager = self.servicesAssembly.bluetoothManager
        historyListViewController.networkCaseConnectionManager = self.servicesAssembly.networkManager as? CaseConnectionProtocol
        historyListViewController.notificationsNetworkManager = self.servicesAssembly.networkManager as! NotificationsNetworkProtocol

        return historyListViewController
    }

    // MARK: -
    // MARK: Private
    fileprivate var storyboard: UIStoryboard { return UIStoryboard(name: "Notifications", bundle: nil) }
}
