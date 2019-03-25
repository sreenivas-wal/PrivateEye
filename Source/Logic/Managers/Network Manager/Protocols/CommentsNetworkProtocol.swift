//
//  CommentsNetworkProtocol.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 10/18/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

protocol CommentsNetworkProtocol: class {
    func getComments(withQuery paginationQuery: CommentsPaginationQuery,
                     successBlock: @escaping NetworkJSONSuccessBlock,
                     failureBlock: @escaping NetworkJSONFailureBlock) -> NetworkRequest?
    
    func postComment(_ commentValue: String,
                     forNodeID nodeID: String?,
                     folderID: String?,
                     successBlock: @escaping NetworkJSONSuccessBlock,
                     failureBlock: @escaping NetworkJSONFailureBlock)
    
    func newCommentsCount(forNodeID nodeID: String?,
                          successBlock: @escaping NetworkJSONSuccessBlock,
                          failureBlock: @escaping NetworkJSONFailureBlock)
    
    func removeComments(_ comments: [Comment],
                        successBlock: @escaping NetworkJSONSuccessBlock,
                        failureBlock: @escaping NetworkJSONFailureBlock)
}
