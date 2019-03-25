//
//  AuthentificationHelper.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 8/31/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthentificationHelper: NSObject {
    
    let authenticationContext = LAContext()
    
    func isLocalAuthentificationEnabled() -> Bool {
        guard authenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) else {
            return false
        }
        
        return true
    }
    
    func proceedLocalAuthentification(withSuccessHandler successHandler: @escaping (() -> ()), failureHandler: @escaping ((Error?) -> ())) {
        guard isLocalAuthentificationEnabled() else {
            failureHandler(nil)
            return
        }
        
        authenticationContext.evaluatePolicy(.deviceOwnerAuthentication,
                                             localizedReason: "Please authenticate to proceed",
                                             reply: { (success, error) -> Void in
                                                if (success) {
                                                    successHandler()
                                                } else {
                                                    if let error = error {
                                                        switch (error) {
                                                        case LAError.authenticationFailed, LAError.userCancel, LAError.userFallback, LAError.systemCancel, LAError.appCancel, LAError.invalidContext:
                                                            break
                                                        case LAError.passcodeNotSet, LAError.touchIDNotAvailable, LAError.touchIDNotEnrolled, LAError.touchIDLockout:
                                                            failureHandler(error)
                                                            break
                                                        default:
                                                            break
                                                        }
                                                    }
                                                }})
    }
}
