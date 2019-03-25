//
//  CaseConnectionProtocol.swift
//  MyMobileED
//
//  Created by Admin on 2/8/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

protocol CaseConnectionProtocol: class {
    func caseConnected(_ successBlock: @escaping NetworkJSONSuccessBlock,
                       failureBlock: @escaping NetworkJSONFailureBlock)
    
    func caseDisconnected(_ successBlock: @escaping NetworkJSONSuccessBlock,
                            failureBlock: @escaping NetworkJSONFailureBlock)
    
    func screenshotWasTaken(_ successBlock: @escaping NetworkJSONSuccessBlock,
                            failureBlock: @escaping NetworkJSONFailureBlock)
    
    func bluetoothConnected(_ successBlock: @escaping NetworkJSONSuccessBlock,
                            failureBlock: @escaping NetworkJSONFailureBlock)
    
    func bluetoothDisconnected(_ successBlock: @escaping NetworkJSONSuccessBlock,
                               failureBlock: @escaping NetworkJSONFailureBlock)
    
    // Logging cached data with CaseLog
    func logBluetoothDisconnected(_ log: CaseLog,
                           successBlock: @escaping NetworkJSONSuccessBlock,
                           failureBlock: @escaping NetworkJSONFailureBlock)

    func logScreenshot(_ log: CaseLog,
                successBlock: @escaping NetworkJSONSuccessBlock,
                failureBlock: @escaping NetworkJSONFailureBlock)

    func logCaseDisconnected(_ log: CaseLog,
                      successBlock: @escaping NetworkJSONSuccessBlock,
                      failureBlock: @escaping NetworkJSONFailureBlock)
}
