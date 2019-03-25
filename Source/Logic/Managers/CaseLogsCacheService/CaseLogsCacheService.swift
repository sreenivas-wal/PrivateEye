//
//  CaseLogsCacheService.swift
//  MyMobileED
//
//  Created by Created by Admin on 18.06.18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation

class CaseLogsCacheService: CaseLogsCacheServiceProtocol {
    
    typealias SuccessBlock = VoidBlock
    typealias FailureBlock = (_ reason: String) -> ()
    typealias CachedLogsCompletionBlock = (_ logs: [CaseLog]) -> ()
    
    fileprivate static let rootFolderName = "Case logs"
    fileprivate let caseStatusStorage: DataStorage<CaseLog>
    
    init() {
        
        let logsFolderPath = DataStorage<CaseLog>.pathToCachedItems(withItemsFolder: CaseLogsCacheService.rootFolderName)
        self.caseStatusStorage = DataStorage<CaseLog>(withContentPath: logsFolderPath ?? "")
    }
    
    func cachedLogs(with completion: @escaping CachedLogsCompletionBlock) {
        
        DispatchQueue.global(qos: .background).async {
            let logs = self.caseStatusStorage.restoreInformation()
            
            DispatchQueue.main.async {
                completion(logs)
            }
        }
    }
    
    func cache(caselog: CaseLog,
          successBlock: @escaping SuccessBlock,
          failureBlock: @escaping FailureBlock) {
        
        DispatchQueue.global(qos: .background).async {
            let success = self.caseStatusStorage.save(item: caselog, identifier: caselog.actionTimestamp)
            
            DispatchQueue.main.async {
                success ? successBlock() : failureBlock("CaseLogsCacheService | failed during to save caselog")
            }
        }
    }
    
    func remove(caselog: CaseLog,
           successBlock: @escaping SuccessBlock,
           failureBlock: @escaping FailureBlock) {
        
        DispatchQueue.global(qos: .background).async {
            let success = self.caseStatusStorage.removeItem(with: caselog.actionTimestamp)
            
            DispatchQueue.main.async {
                success ? successBlock() : failureBlock("CaseLogsCacheService | failed during to remove caselog")
            }
        }
    }
    
    func clearAllCache() {
        self.caseStatusStorage.clearStorage()
    }
}
