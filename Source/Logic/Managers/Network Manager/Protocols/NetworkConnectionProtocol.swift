//
//  NetworkConnectionProtocol.swift
//  MyMobileED
//
//  Created by Admin on 1/17/17.
//  Copyright © 2017 Company. All rights reserved.
//

import Foundation
import SwiftyJSON

enum MappingResult {
    case success(AnyObject)
    case failure
}

typealias NetworkJSONSuccessBlock = (_ successResponse: HTTPJSONResponse) -> (Void)
typealias NetworkJSONMappingBlock = (_ response: URLResponse, _ json: JSON) -> MappingResult
typealias NetworkJSONFailureBlock = (_ failureResponse: HTTPJSONResponse) -> (Void)

protocol NetworkConnectionProtocol: class {
    func executeRequest(_ request: URLRequest,
                        mappingBlock: NetworkJSONMappingBlock?,
                        successBlock: @escaping NetworkJSONSuccessBlock,
                        failureBlock: @escaping NetworkJSONFailureBlock) -> NetworkRequest
    func baseUrl() -> String
    func defaultHeaderFields() -> [String : String]
}
