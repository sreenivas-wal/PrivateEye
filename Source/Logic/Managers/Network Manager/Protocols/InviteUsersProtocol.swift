//
//  InviteUsersProtocol.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 9/25/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

protocol InviteUsersProtocol: class {
    
    func inviteUser(byEmail email: String,
                    successBlock: @escaping NetworkJSONSuccessBlock,
                    failureBlock: @escaping NetworkJSONFailureBlock)

    func inviteUser(byText text: String,
                    successBlock: @escaping NetworkJSONSuccessBlock,
                    failureBlock: @escaping NetworkJSONFailureBlock)
    
    func inviteUsers(byEmails emails: [String],
                    successBlock: @escaping NetworkJSONSuccessBlock,
                    failureBlock: @escaping NetworkJSONFailureBlock)
    
    func inviteUsers(byPhones phones: [String],
                       successBlock: @escaping NetworkJSONSuccessBlock,
                       failureBlock: @escaping NetworkJSONFailureBlock)
    
    func inviteUserInDoximity()
}
