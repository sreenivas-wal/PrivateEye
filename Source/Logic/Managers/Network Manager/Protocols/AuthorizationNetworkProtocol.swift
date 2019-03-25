//
//  AuthorizationNetworkProtocol.swift
//  MyMobileED
//
//  Created by Admin on 1/17/17.
//  Copyright © 2017 Company. All rights reserved.
//

import Foundation

protocol AuthorizationNetworkProtocol: class {
    func requestAuthorization(withPhoneNumber phoneNumber: String,
                              successBlock: @escaping NetworkJSONSuccessBlock,
                              failureBlock: @escaping NetworkJSONFailureBlock)
    
    func verifyMobileNumber(with authorizationModel: AuthorizationModel,
                            code: String,
                            successBlock: @escaping NetworkJSONSuccessBlock,
                            failureBlock: @escaping NetworkJSONFailureBlock)
    
    func signIn(with login: String,
                password: String,
                successBlock: @escaping NetworkJSONSuccessBlock,
                failureBlock: @escaping NetworkJSONFailureBlock)
    
    func signUp(with name:String,password: String,authorizationModel: AuthorizationModel,
        successBlock: @escaping NetworkJSONSuccessBlock,
        failureBlock: @escaping NetworkJSONFailureBlock)
    
    func logOut(successBlock: @escaping NetworkJSONSuccessBlock,
                failureBlock: @escaping NetworkJSONFailureBlock)
    
    func getProfileInformation(successBlock: @escaping NetworkJSONSuccessBlock,
                               failureBlock: @escaping NetworkJSONFailureBlock)
    
    func resetPassword(with email: String,
                       successBlock: @escaping NetworkJSONSuccessBlock,
                       failureBlock: @escaping NetworkJSONFailureBlock)
    
    func changeProfileInformation(_ profile: Profile,
                                  successBlock: @escaping NetworkJSONSuccessBlock,
                                  failureBlock: @escaping NetworkJSONFailureBlock)
    
    func changePassword(_ password: String,
                        successBlock: @escaping NetworkJSONSuccessBlock,
                        failureBlock: @escaping NetworkJSONFailureBlock)
    
    func searchHostnames(withSearchFilter searchFilter: String,
                         successBlock: @escaping NetworkJSONSuccessBlock,
                         failureBlock: @escaping NetworkJSONFailureBlock) -> NetworkRequest?
    
    func doximityLogin(withAccessToken accessToken: String,
                       successBlock: @escaping NetworkJSONSuccessBlock,
                       failureBlock: @escaping NetworkJSONFailureBlock)
    
    func doximityAccessToken(withCode code: String,
                               phoneNumber: String?,
                              successBlock: @escaping NetworkJSONSuccessBlock,
                              failureBlock: @escaping NetworkJSONFailureBlock)
}
