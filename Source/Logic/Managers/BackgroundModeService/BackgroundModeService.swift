//
//  BackgroundModeService.swift
//  MyMobileED
//
//  Created by Created by Admin on 24.05.18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation

typealias BackgroundModeServiceRegisterTaskBlock = (_ name: String) -> ()

protocol BackgroundModeServiceProtocol: class {
    
    
    func registerBackgroundTask()
    func endBackgroundTask()
}

class BackgroundModeService: BackgroundModeServiceProtocol {

    fileprivate let taskname = "backgroundModeService.bgtask." + UUID().uuidString
    fileprivate var currentTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    func registerBackgroundTask() {
        
        print("registerBackgroundTask")

        let task = UIApplication.shared.beginBackgroundTask(withName: taskname,
                                                   expirationHandler: {
                                            
                                                       self.endBackgroundTask()
                                                   })
        self.currentTask = task
    }
    
    func endBackgroundTask() {
        
        print("endBackgroundTask")
        UIApplication.shared.endBackgroundTask(self.currentTask)
        self.currentTask = UIBackgroundTaskInvalid
    }
}
