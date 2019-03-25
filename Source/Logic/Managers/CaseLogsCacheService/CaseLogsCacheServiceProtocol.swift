//
//  CaseLogsCacheServiceProtocol.swift
//  MyMobileED
//
//  Created by Created by Admin on 18.06.18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation

protocol CaseLogsCacheServiceProtocol: class {
    
    func cachedLogs(with completion: @escaping CaseLogsCacheService.CachedLogsCompletionBlock)
    
    func cache(caselog: CaseLog,
          successBlock: @escaping CaseLogsCacheService.SuccessBlock,
          failureBlock: @escaping CaseLogsCacheService.FailureBlock)
    
    func remove(caselog: CaseLog,
           successBlock: @escaping CaseLogsCacheService.SuccessBlock,
           failureBlock: @escaping CaseLogsCacheService.FailureBlock)
    
    func clearAllCache()
}
