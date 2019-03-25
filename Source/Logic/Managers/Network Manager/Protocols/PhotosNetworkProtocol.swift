//
//  PhotoUploadNetworkProtocol.swift
//  MyMobileED
//
//  Created by Admin on 1/19/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

typealias NetworkPhotoLoadSuccessBlock = (_ data: Data) -> (Void)
typealias NetworkPhotoLoadFailureBlock = (_ error: Error) -> (Void)

protocol PhotosNetworkProtocol: class {
    
    // MARK: - Folders
    
    func getFolderContents(withQuery paginationQuery: PhotosPaginationQuery,
                           successBlock: @escaping NetworkJSONSuccessBlock,
                           failureBlock: @escaping NetworkJSONFailureBlock) -> NetworkRequest?
    
    func createFolder(withTitle title: String,
                      forParentFolder parent: Folder?,
                      group: Group?,
                      successBlock: @escaping NetworkJSONSuccessBlock,
                      failureBlock: @escaping NetworkJSONFailureBlock)
    
    func deleteFolder(_ folder: Folder,
                      successBlock: @escaping NetworkJSONSuccessBlock,
                      failureBlock: @escaping NetworkJSONFailureBlock)
    
    func editFolder(_ folder: Folder,
                    successBlock: @escaping NetworkJSONSuccessBlock,
                    failureBlock: @escaping NetworkJSONFailureBlock)
    
    // MARK: - Photos
    
    func uploadPhotoToNewNode(_ photo: Photo,
                     successBlock: @escaping NetworkJSONSuccessBlock,
                     failureBlock: @escaping NetworkJSONFailureBlock)

    func uploadPhotoToExtistingNode(_ photo: Photo,
                              successBlock: @escaping NetworkJSONSuccessBlock,
                              failureBlock: @escaping NetworkJSONFailureBlock)
    
    func loadImage(fromURL url: URL,
                   successBlock: @escaping NetworkPhotoLoadSuccessBlock,
                   failureBlock: @escaping NetworkPhotoLoadFailureBlock)
    
    func retrieveImage(byNode nodeID: String,
                       successBlock: @escaping NetworkJSONSuccessBlock,
                       failureBlock: @escaping NetworkJSONFailureBlock) -> NetworkRequest?
    
    func editPhoto(fromPhoto photo: Photo,
                   successBlock: @escaping NetworkJSONSuccessBlock,
                   failureBlock: @escaping NetworkJSONFailureBlock)
    
    func deletePhoto(_ photo: Photo,
                     successBlock: @escaping NetworkJSONSuccessBlock,
                     failureBlock: @escaping NetworkJSONFailureBlock)

    
    @discardableResult
    func retrievePhoto(byNode nodeID: String,
                        successBlock: @escaping NetworkJSONSuccessBlock,
                        failureBlock: @escaping NetworkJSONFailureBlock) -> NetworkRequest?
    
    // MARK: - Users
    
    func usernameAutocomplete(withUsernames usernames: String,
                              successBlock: @escaping NetworkJSONSuccessBlock,
                              failureBlock: @escaping NetworkJSONFailureBlock) -> NetworkRequest?
    
    func searchUsers(withQuery paginationQuery: SearchUsersPaginationQuery,
                     successBlock: @escaping NetworkJSONSuccessBlock,
                     failureBlock: @escaping NetworkJSONFailureBlock) -> NetworkRequest?
    
    // MARK: - Sharing
    
    func sharePhotoToUser(_ photo: Photo,
                    forUsers users: [ShareUser],
                    successBlock: @escaping NetworkJSONSuccessBlock,
                    failureBlock: @escaping NetworkJSONFailureBlock)
    
    func sharePhotoToDoximityUser(_ photo: Photo,
                    forUsers users: [ShareUser],
                    successBlock: @escaping NetworkJSONSuccessBlock,
                    failureBlock: @escaping NetworkJSONFailureBlock)
    
    func sharePhoto(_ photo: Photo,
                    byEmails emails: [String],
                    successBlock: @escaping NetworkJSONSuccessBlock,
                    failureBlock: @escaping NetworkJSONFailureBlock)
    
    func sharePhoto(_ photo: Photo,
                    byTexts texts: [String],
                    successBlock: @escaping NetworkJSONSuccessBlock,
                    failureBlock: @escaping NetworkJSONFailureBlock)
    
    func sharePhoto(_ photo: Photo,
                    toGroup group: Group,
                    successBlock: @escaping NetworkJSONSuccessBlock,
                    failureBlock: @escaping NetworkJSONFailureBlock)
    
    func shareFolderToUser(_ folder: Folder,
                     forUsers users: [ShareUser],
                     successBlock: @escaping NetworkJSONSuccessBlock,
                     failureBlock: @escaping NetworkJSONFailureBlock)
    
    func shareFolderToDoximityUser(_ folder: Folder,
                     forUsers users: [ShareUser],
                     successBlock: @escaping NetworkJSONSuccessBlock,
                     failureBlock: @escaping NetworkJSONFailureBlock)
    
    func shareFolder(_ folder: Folder,
                     byEmails email: [String],
                     successBlock: @escaping NetworkJSONSuccessBlock,
                     failureBlock: @escaping NetworkJSONFailureBlock)
    
    func shareFolder(_ folder: Folder,
                     byTexts texts: [String],
                     successBlock: @escaping NetworkJSONSuccessBlock,
                     failureBlock: @escaping NetworkJSONFailureBlock)
    
    func shareFolder(_ folder: Folder,
                    toGroup group: Group,
                    successBlock: @escaping NetworkJSONSuccessBlock,
                    failureBlock: @escaping NetworkJSONFailureBlock)
    
    func shareGroupToUser(_ group: Group,
                    forUsers users: [ShareUser],
                    successBlock: @escaping NetworkJSONSuccessBlock,
                    failureBlock: @escaping NetworkJSONFailureBlock)
    
    func shareGroupToDoximityUser(_ group: Group,
                    forUsers users: [ShareUser],
                    successBlock: @escaping NetworkJSONSuccessBlock,
                    failureBlock: @escaping NetworkJSONFailureBlock)
    
    func shareGroup(_ group: Group,
                    byTexts texts: [String],
                    successBlock: @escaping NetworkJSONSuccessBlock,
                    failureBlock: @escaping NetworkJSONFailureBlock)
    
    func shareGroup(_ group: Group,
                    byEmails emails: [String],
                    successBlock: @escaping NetworkJSONSuccessBlock,
                    failureBlock: @escaping NetworkJSONFailureBlock)
    
    // MARK: - Groups
    
    func getGroups(withQuery paginationQuery: GroupsPaginationQuery,
                   successBlock: @escaping NetworkJSONSuccessBlock,
                   failureBlock: @escaping NetworkJSONFailureBlock) -> NetworkRequest?
    
    func createGroup(with title: String,
                     successBlock: @escaping NetworkJSONSuccessBlock,
                     failureBlock: @escaping NetworkJSONFailureBlock)
    
    func removeMember(_ member: GroupMember,
                      from group: Group,
                      successBlock: @escaping NetworkJSONSuccessBlock,
                      failureBlock: @escaping NetworkJSONFailureBlock)
    
    func removePotentialMember(_ recipient: Recipient,
                               from group: Group,
                               successBlock: @escaping NetworkJSONSuccessBlock,
                               failureBlock: @escaping NetworkJSONFailureBlock)
    
    func getGroupMembers(withPaginationQuery paginationQuery: GroupMembersPaginationQuery,
                         successBlock: @escaping NetworkJSONSuccessBlock,
                         failureBlock: @escaping NetworkJSONFailureBlock) -> NetworkRequest?
    
    func editGroup(_ group: Group,
                with title: String,
              successBlock: @escaping NetworkJSONSuccessBlock,
              failureBlock: @escaping NetworkJSONFailureBlock)

    func deleteGroup(_ group: Group,
                successBlock: @escaping NetworkJSONSuccessBlock,
                failureBlock: @escaping NetworkJSONFailureBlock)
    
    // MARK: - Doximity
    
    func retrieveDoximityUsers(withKeywords keywords: String,withResetValue reset: Bool,
                               successBlock: @escaping NetworkJSONSuccessBlock,
                               failureBlock: @escaping NetworkJSONFailureBlock)
}
