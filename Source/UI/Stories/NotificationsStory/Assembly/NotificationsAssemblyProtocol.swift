//
//  NotificationsAssemblyProtocol.swift
//  MyMobileED
//
//  Created by Created by Admin on 14.06.18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation

protocol NotificationsAssemblyProtocol {
    
    var servicesAssembly: ServicesAssemblyProtocol { get }

    func assemblyNotificationSettingsViewController(with transition: NotificationsRoutingTransition) -> NotificationSettingsViewController
    func assemblyNotificationHistoryListViewController(with transition: NotificationsRoutingTransition) -> NotificationHistoryListViewController
}
