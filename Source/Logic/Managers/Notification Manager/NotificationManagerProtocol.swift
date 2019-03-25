//
//  NetworkManagerProtocol.swift
//  MyMobileED
//
//  Created by Admin on 1/13/17.
//
//

import Foundation

protocol NotificationManagerProtocol: class {
    var delegate: NotificationManagerDelegate? { get set }
    
    func subscribeToPushNotification(withDeviceToken deviceToken: Data)
    func didReceiveRemoteNotification(withUserInfo userInfo: [AnyHashable : Any])
}
