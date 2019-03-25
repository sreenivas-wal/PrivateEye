//
//  NetworkManager.swift
//  MyMobileED
//
//  Created by Admin on 1/13/17.
//
//

import Foundation

protocol NotificationManagerDelegate: class {
    func notificationManagerDidReceiveRemoteNotification(_ notificationManager: NotificationManagerProtocol)
}

class NotificationManager: NSObject, NotificationManagerProtocol {
    
    var networkManager: PushNotificationProtocol?
    var delegate: NotificationManagerDelegate?
    
    init?(networkManager: PushNotificationProtocol) {
        super.init()
        
        self.networkManager = networkManager
    }
    
    func subscribeToPushNotification(withDeviceToken deviceToken: Data) {
        let deviceTokenString = self.convertDeviceTokenData(dataDeviceToken: deviceToken)
        
        networkManager?.registerDeviceToken(deviceTokenString: deviceTokenString, successBlock: { (response) -> (Void) in
            print("Response subscribe = \(response)")
        }, failureBlock: { (error) -> (Void) in
            print("Error subscribe = \(error)")
        })
    }

    func didReceiveRemoteNotification(withUserInfo userInfo: [AnyHashable : Any]) {
        self.delegate?.notificationManagerDidReceiveRemoteNotification(self)
    }
    
    // MARK: Private
    
     func convertDeviceTokenData(dataDeviceToken: Data) -> String {
        var token = ""
        
        for i in 0..<dataDeviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [(dataDeviceToken[i])])
        }
        
        print("Device token = \(token)")
        
        return token
    }
}
