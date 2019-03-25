//
//  NotificationsNetworkProtocol.swift
//  MyMobileED
//
//  Created by Created by Admin on 24.06.18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation

protocol NotificationsNetworkProtocol: class {
    
    func getNotificationHistory(query: PaginationQuery,
                         successBlock: @escaping NetworkJSONSuccessBlock,
                         failureBlock: @escaping NetworkJSONFailureBlock)
    func getNotificationSettings(query: PaginationQuery,
                                successBlock: @escaping NetworkJSONSuccessBlock,
                                failureBlock: @escaping NetworkJSONFailureBlock)

    func postNotificationSettingType(with messageType: String,
                            subscribed: Bool,
                            successBlock: @escaping NetworkJSONSuccessBlock,
                            failureBlock: @escaping NetworkJSONFailureBlock)
    
}
