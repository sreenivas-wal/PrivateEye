//
//  CaseLogsCoordinatorProtocol.swift
//  MyMobileED
//
//  Created by Created by Admin on 18.06.18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation

protocol CaseLogsCoordinatorProtocol {
    
    func upload(caselog: CaseLog)
    func performCacheUploadIfNeeded()
}
