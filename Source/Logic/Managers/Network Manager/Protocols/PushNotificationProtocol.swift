//
//  PushNotificationProtocol.swift
//  MyMobileED
//
//  Created by Admin on 2/13/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

protocol PushNotificationProtocol: class {
    func registerDeviceToken(deviceTokenString: String,
                             successBlock: @escaping NetworkJSONSuccessBlock,
                             failureBlock: @escaping NetworkJSONFailureBlock)
    func deRegisterDeviceToken(deviceTokenString: String,
                               successBlock: @escaping NetworkJSONSuccessBlock,
                               failureBlock: @escaping NetworkJSONFailureBlock)
    
}

