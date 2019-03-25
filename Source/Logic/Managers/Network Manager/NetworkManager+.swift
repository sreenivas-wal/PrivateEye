//
//  NetworkManager+.swift
//  MyMobileED
//
//  Created by Admin on 1/17/17.
//  Copyright © 2017 Company. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

// Authorization
private let signInEndpoint = "/drupalgap/drupalgap_user/login.json"
private let logOutEndpoint = "/drupalgap/drupalgap_user/logout.json"
private let signUpEndpoint = "/drupalgap/mmed/register.json"
private let requestVerificationEndpoint = "/drupalgap/mobile_number/request_verification_code.json"
private let mobileNumberVerificationEndpoint = "/drupalgap/mobile_number/verify_number.json"

// Doximity
private let doximityAccessTokenEndpoint = "/drupalgap/doximity/token.json"
private let doximityLoginEndpoint = "/drupalgap/doximity/login.json"
private let doximityRetrieveColleagues = "/drupalgap/doximity/colleagues.json"

// Hostnames
private let hostnamesEndpoint = "/drupalgap/views/hostnames.json"

// User
private let resetPasswordEndpoint = "/drupalgap/user/request_new_password.json"
private let editProfileEndpoint = "/drupalgap/user/"

// Invite
private let inviteUserEndpoint = "/drupalgap/invite.json"

// Invite multiple recipients
private let inviteMultipleUserEndpoint = "/drupalgap/mmed/invite.json"

// Photos
private let photosEndpoint = "/images.json"
private let myPhotosEndpoint = "/my-images.json"
private let profileInformationEndpoint = "/drupalgap/user/"
private let uploadPhotoEndpoint = "/drupalgap/file.json"
private let nodeJsonEndpoint = "/drupalgap/node.json"
private let nodeEndpoint = "/drupalgap/node/"
private let retriveFileEndpoint = "/drupalgap/file/"
private let userAutocompleteEndpoint = "/user/autocomplete/"
private let pushNotificationEndpoint = "/drupalgap/push_notifications.json"
private let deRegisterDeviceTokenEndPoint = "/drupalgap/push_notifications/"
private let searchUsersEndpoint = "/drupalgap/views/user/autocomplete.json"
private let folderEndpoint = "/drupalgap/folder"
private let shareEndpoint = "/drupalgap/mmed/share.json"
private let removeNodeEndPoint = "/drupalgap/mmed/remove-node-from-folder"

// Case Connection

private let caseConnectionEndpoint = "/drupalgap/mmed/case-status.json"
private let screenshotTakenEndpoint = "/drupalgap/mmed/screenshot-taken.json"
private let bluetoothConnectedEndpoint = "/drupalgap/mmed/bluetooth-status.json"

// Comments

private let fetchCommentsEndpoint = "/comments.json"
private let commentsEndpoint = "/drupalgap/comment.json"
private let newCommentsEndpoint = "/drupalgap/comment/countNew.json"
private let removeCommentsEndpoint = "/drupalgap/mmed/comments-delete.json"

// Groups

private let groupsEndpoint = "/groups.json"
private let removeMemberEndpoint = "/drupalgap/og/leave/"
private let groupMembersEndpoint = "/drupalgap/views/group/%@/members.json"
private let unshareEndpoint = "/drupalgap/mmed/unshare.json"

typealias SignInDataResult = (user: User, profile: Profile?)
typealias DoximityAccessTokenResult = (doximityUser: DoximityUser, user: User)
typealias DoximityLoginResult = (user: User, profile: Profile?)

// Notifications
private let notificationsHistoryEndpoint = "/drupalgap/views/message/push_notification.json"
private let notificationSettingsEndpoint = "/drupalgap/views/message/subscriptions.json"
private let notificationSettingsActionEndpoint = "/drupalgap/mmed/subscribe.json"

let defaults = UserDefaults.standard

extension NetworkManager {
    fileprivate func requestWithEndpoint(_ endpoint: String,
                                         method: HTTPMethod,
                                         params: [String : AnyObject]?,
                                         headers: [String : String]?,
                                         encoding: ParameterEncoding,
                                         mappingBlock: NetworkJSONMappingBlock?,
                                         successBlock: @escaping NetworkJSONSuccessBlock,
                                         failureBlock: @escaping NetworkJSONFailureBlock) -> NetworkRequest? {
        let url: URL? = URL(string: baseUrl() + endpoint)
        
        if let validURL = url {
            let request = manager.request(validURL, method: method, parameters: params, encoding: encoding, headers: headers)
            
            let urlRequest = request.request
            
            if let validURLRequest = urlRequest {
                return self.executeRequest(validURLRequest,
                                           mappingBlock: mappingBlock,
                                           successBlock: successBlock,
                                           failureBlock: failureBlock)
            }
        }
        else {
            failureBlock(HTTPJSONResponse(withJSON: JSON.null, code: -1, message: ""))
        }
        
        return nil
    }
    
    @discardableResult
    fileprivate func getRequestWithEndpoint(_ endpoint: String,
                                            params: [String : AnyObject]?,
                                            headers: [String : String]?,
                                            encoding: ParameterEncoding = URLEncoding.default,
                                            mappingBlock: NetworkJSONMappingBlock?,
                                            successBlock: @escaping NetworkJSONSuccessBlock,
                                            failureBlock: @escaping NetworkJSONFailureBlock) -> NetworkRequest? {
        return self.requestWithEndpoint(endpoint,
                                        method: .get,
                                        params: params,
                                        headers: headers,
                                        encoding: encoding,
                                        mappingBlock: mappingBlock,
                                        successBlock: successBlock,
                                        failureBlock: failureBlock)
    }
    
    @discardableResult
    fileprivate func postRequestWithEndpoint(_ endpoint: String,
                                             params: [String : AnyObject]?,
                                             headers: [String : String]?,
                                             encoding: ParameterEncoding = URLEncoding.default,
                                             mappingBlock: NetworkJSONMappingBlock?,
                                             successBlock: @escaping NetworkJSONSuccessBlock,
                                             failureBlock: @escaping NetworkJSONFailureBlock) -> NetworkRequest? {
        return self.requestWithEndpoint(endpoint,
                                        method: .post,
                                        params: params,
                                        headers: headers,
                                        encoding: encoding,
                                        mappingBlock: mappingBlock,
                                        successBlock: successBlock,
                                        failureBlock: failureBlock)
    }
    
    @discardableResult
    fileprivate func putRequestWithEndpoint(_ endpoint: String,
                                            params: [String : AnyObject]?,
                                            headers: [String : String]?,
                                            encoding: ParameterEncoding = URLEncoding.default,
                                            mappingBlock: NetworkJSONMappingBlock?,
                                            successBlock: @escaping NetworkJSONSuccessBlock,
                                            failureBlock: @escaping NetworkJSONFailureBlock) -> NetworkRequest? {
        return self.requestWithEndpoint(endpoint,
                                        method: .put,
                                        params: params,
                                        headers: headers,
                                        encoding: encoding,
                                        mappingBlock: mappingBlock,
                                        successBlock: successBlock,
                                        failureBlock: failureBlock)
    }
    
    @discardableResult
    fileprivate func deleteRequestWithEndpoint(_ endpoint: String,
                                               params: [String : AnyObject]?,
                                               headers: [String : String]?,
                                               encoding: ParameterEncoding = URLEncoding.default,
                                               mappingBlock: NetworkJSONMappingBlock?,
                                               successBlock: @escaping NetworkJSONSuccessBlock,
                                               failureBlock: @escaping NetworkJSONFailureBlock) -> NetworkRequest? {
        return self.requestWithEndpoint(endpoint,
                                        method: .delete,
                                        params: params,
                                        headers: headers,
                                        encoding: encoding,
                                        mappingBlock: mappingBlock,
                                        successBlock: successBlock,
                                        failureBlock: failureBlock)
    }
}

extension NetworkManager : AuthorizationNetworkProtocol {
    
    func requestAuthorization(withPhoneNumber phoneNumber: String,
                              successBlock: @escaping NetworkJSONSuccessBlock,
                              failureBlock: @escaping NetworkJSONFailureBlock) {
        
        self.clearAllCookie()
        
        var params = defaultParams()
        params["number"] = phoneNumber as AnyObject?
        params["country"] = "US" as AnyObject?
        
        _ = postRequestWithEndpoint(requestVerificationEndpoint, params: params,
                                    headers: nil,
                                    mappingBlock: ({ (response: URLResponse, json: JSON) -> (MappingResult) in
                                        if let verificationToken = json["verification_token"].string {
                                            return .success(verificationToken as AnyObject)
                                        }
                                        
                                        return .failure
                                    }),
                                    successBlock: { (response) -> (Void) in
                                        successBlock(response)
        }, failureBlock: { (response) -> (Void) in
            
            guard let errorMessage = response.json["form_errors"]["message"].string
                else {
                    failureBlock(response)
                    return
            }
            
            failureBlock(HTTPJSONResponse(withJSON: response.json, code: response.code, message: errorMessage))
        })
    }
    
    func verifyMobileNumber(with authorizationModel: AuthorizationModel,
                            code: String,
                            successBlock: @escaping NetworkJSONSuccessBlock,
                            failureBlock: @escaping NetworkJSONFailureBlock) {
        var params = defaultParams()
        params["number"] = authorizationModel.mobileNumber as AnyObject?
        params["country"] = "US" as AnyObject?
        params["code"] = code as AnyObject?
        params["verification_token"] = authorizationModel.verificationToken as AnyObject?
        params["email"] = authorizationModel.email as AnyObject?
        
        _ = postRequestWithEndpoint(mobileNumberVerificationEndpoint, params: params, headers: nil,
                                    mappingBlock: ({ (response: URLResponse, json: JSON) -> (MappingResult) in
                                        
                                        guard let userProfileRecognizer = UserProfileRecognizer(json: json) else { return .failure }
                                        return .success(userProfileRecognizer)
                                    }),
                                    successBlock: { (response) -> (Void) in
                                        successBlock(response)
        }, failureBlock: { (response) -> (Void) in
            failureBlock(response)
        })
    }
    
    func signIn(with login: String,
                password: String,
                successBlock: @escaping NetworkJSONSuccessBlock,
                failureBlock: @escaping NetworkJSONFailureBlock) {
        let headers = headerWithCookieAndToken()
        var params: [String : AnyObject] = defaultParams()
        params["username"] = login as AnyObject?
        params["password"] = password as AnyObject?
        
        _ = self.postRequestWithEndpoint(signInEndpoint,
                                         params: params as [String : AnyObject],
                                         headers: headers,
                                         mappingBlock: ({ (response: URLResponse, json: JSON) -> MappingResult in
                                            
                                            guard let requiredUser = User(json: json)
                                                else {
                                                    return .failure
                                            }
                                            
                                            let profile = Profile(json: json["user"])
                                            
                                            let result = SignInDataResult(user: requiredUser, profile: profile)
                                            
                                            return .success(result as AnyObject)
                                         }),
                                         successBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            successBlock(response)
                                         }),
                                         failureBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            failureBlock(response)
                                         }))
    }
    
    func signUp(with name:String, password: String, authorizationModel: AuthorizationModel, successBlock: @escaping NetworkJSONSuccessBlock, failureBlock: @escaping NetworkJSONFailureBlock) {
        var params: [String : AnyObject] = defaultParams()
        let header = headerWithCookieAndToken()
        params["name"] = name as AnyObject
        params["mail"] = authorizationModel.email as AnyObject
        params["field_phone"] = ["und": [
            ["mobile": "+1" + authorizationModel.mobileNumber!]]] as AnyObject?
        params["pass"] = password as AnyObject
        
        _ = self.postRequestWithEndpoint(signUpEndpoint, params: params, headers: header, mappingBlock: { (response: URLResponse, json: JSON) -> MappingResult in
            
            guard let requiredUser = User(json: json["login"])
                else {
                    return .failure
            }
            
            let profile = Profile(json: json["login"]["user"])
            let result = SignInDataResult(user: requiredUser, profile: profile)
            return .success(result as AnyObject)
        }, successBlock: { (response: HTTPJSONResponse) -> (Void) in
            successBlock(response)
            
        }, failureBlock: { (response: HTTPJSONResponse) -> (Void) in
            failureBlock(response)
            
        })
    }
    
    func logOut(successBlock: @escaping NetworkJSONSuccessBlock,
                failureBlock: @escaping NetworkJSONFailureBlock) {
        let header = headerWithCookieAndToken()
        let params = defaultParams()
        
        _ = self.postRequestWithEndpoint(logOutEndpoint, params: params, headers: header,
                                         mappingBlock: nil,
                                         successBlock: ({ (response: HTTPJSONResponse) -> (Void) in
//                                            self.userManager?.clearUserInfo()
//                                            defaults.removeObject(forKey: "DoximityUserAccessToken")
                                            successBlock(response)
                                         }), failureBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            failureBlock(response)
                                         }))
    }
    
    func getProfileInformation(successBlock: @escaping NetworkJSONSuccessBlock,
                               failureBlock: @escaping NetworkJSONFailureBlock) {
        let userInfo = userManager?.currentUser
        var header = defaultHeaderFields()
        var endpoint:String!
        if userInfo != nil {
            header["Cookie"] = userInfo!.sessionName!.appendingFormat("=%@", userInfo!.sessionID!)
            endpoint = profileInformationEndpoint.appendingFormat("%@.json", userInfo!.userID!)
        } else {
            let cookie = (defaults.value(forKey: "UserSessionName") as! String) + "=" + (defaults.value(forKey: "UserSessionID") as! String)
            let userId = defaults.value(forKey: "UserID") as! String
            header["Cookie"] = cookie
            endpoint = profileInformationEndpoint.appendingFormat("%@.json",userId )
        }
        
        let params = defaultParams()
        
        _ = self.getRequestWithEndpoint(endpoint, params: params, headers: header,
                                        mappingBlock: ({ (response: URLResponse, json: JSON) -> (MappingResult) in
                                            guard let profile = Profile(json: json) else { return .failure }
                                            return .success(profile)
                                        }),
                                        successBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            successBlock(response)
                                        }), failureBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            failureBlock(response)
                                        }))
    }
    
    func resetPassword(with email: String,
                       successBlock: @escaping NetworkJSONSuccessBlock,
                       failureBlock: @escaping NetworkJSONFailureBlock) {
        var params = defaultParams()
        params["name"] = email as AnyObject?
        
        _ = self.postRequestWithEndpoint(resetPasswordEndpoint, params: params, headers: nil, mappingBlock: nil,
                                         successBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            successBlock(response)
                                         }), failureBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            failureBlock(response)
                                         }))
    }
    
    func changeProfileInformation(_ profile: Profile,
                                  successBlock: @escaping NetworkJSONSuccessBlock,
                                  failureBlock: @escaping NetworkJSONFailureBlock) {
        let currentUser = self.userManager?.currentUser
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        
        if let username = profile.username {
            params["name"] = username as AnyObject?
        }
        
        if let phone = profile.phone {
            params["field_phone"] = ["und": [[
                "value": phone]]] as AnyObject?
        }
        
        let endpoint = editProfileEndpoint.appendingFormat("%@.json", currentUser!.userID!)
        _ = self.putRequestWithEndpoint(endpoint, params: params, headers: header, mappingBlock: nil,
                                        successBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            successBlock(response)
                                        }), failureBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            failureBlock(response)
                                        }))
    }
    
    func changePassword(_ password: String,
                        successBlock: @escaping NetworkJSONSuccessBlock,
                        failureBlock: @escaping NetworkJSONFailureBlock) {
        let currentUser = self.userManager?.currentUser
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        params["current_pass"] = self.userManager?.retrieveUserPassword() as AnyObject?
        params["pass"] = password as AnyObject?
        
        let endpoint = editProfileEndpoint.appendingFormat("%@.json", currentUser!.userID!)
        
        _ = self.putRequestWithEndpoint(endpoint, params: params, headers: header,
                                        mappingBlock: nil,
                                        successBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            self.userManager?.updateUserPassword(password)
                                            successBlock(response)
                                        }), failureBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            failureBlock(response)
                                        }))
    }
    
    func searchHostnames(withSearchFilter searchFilter: String,
                         successBlock: @escaping NetworkJSONSuccessBlock,
                         failureBlock: @escaping NetworkJSONFailureBlock) -> NetworkRequest? {
        let header = headerWithCookie()
        var params = defaultParams()
        params["title"] = searchFilter as AnyObject?
        
        let baseUrl = Hostname.defaultHostname().fullHostDomainLink()
        let url: URL? = URL(string: baseUrl + hostnamesEndpoint)
        
        let mappingBlock: ((URLResponse, JSON) -> MappingResult) = { (response:  URLResponse, json: JSON) -> MappingResult in
            if let listArray = json["nodes"].arrayObject {
                var items: [Hostname] = []
                
                for curObject in listArray {
                    if let subJSON = JSON(curObject)["node"].dictionary {
                        if let hostnames: Hostname = Hostname(json:JSON(subJSON)) { items.append(hostnames) }
                        else { return .failure }
                    }
                        
                    else { return .failure }
                }
                
                return .success(items as AnyObject)
            }
            
            return .failure
        }
        
        if let validURL = url {
            let request = manager.request(validURL, method: .get, parameters: params, encoding: URLEncoding.default, headers: header)
            let urlRequest = request.request
            
            if let validURLRequest = urlRequest {
                return self.executeRequest(validURLRequest,
                                           mappingBlock: mappingBlock,
                                           successBlock: successBlock,
                                           failureBlock: failureBlock)
            }
        }
        else {
            failureBlock(HTTPJSONResponse(withJSON: JSON.null, code: -1, message: ""))
        }
        
        return nil
    }
    
    func doximityAccessToken(withCode code: String,
                             phoneNumber: String?,
                             successBlock: @escaping NetworkJSONSuccessBlock,
                             failureBlock: @escaping NetworkJSONFailureBlock) {
        
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        params["code"] = code as AnyObject?
        params["phone"] = phoneNumber as AnyObject?
        
        _ = self.postRequestWithEndpoint(doximityAccessTokenEndpoint,
                                         params: params,
                                         headers: header,
                                         mappingBlock: { (response: URLResponse, json: JSON) -> MappingResult in
                                            
                                            return .success(json as AnyObject)
        },
                                         successBlock: { (response: HTTPJSONResponse) -> (Void) in
                                            successBlock(response)
        },
                                         failureBlock: { (response: HTTPJSONResponse) -> (Void) in
                                            failureBlock(response)
        })
    }
    func doximityLogin(withAccessToken accessToken: String, successBlock: @escaping NetworkJSONSuccessBlock, failureBlock: @escaping NetworkJSONFailureBlock) {
        
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        let storedPhoneNumber = defaults.string(forKey: "mobileNumber")
        let storedEmail = defaults.string(forKey: "email")
        params["access_token"] = accessToken as AnyObject
        params["phone"] = storedPhoneNumber as AnyObject
        params["email"] = storedEmail as AnyObject
        
        _ = self.postRequestWithEndpoint(doximityLoginEndpoint,
                                         params: params,
                                         headers: header,
                                         mappingBlock: { (response: URLResponse, json: JSON) -> MappingResult in
                                            
                                            guard let requiredUser = User(json: json) else { return .failure }
                                            let profile = Profile(json: json["user"])
                                            let result = DoximityLoginResult(user: requiredUser, profile: profile)
                                            return .success(result as AnyObject)
        },
                                         successBlock: ({ (response: HTTPJSONResponse) -> () in
                                            successBlock(response)
                                         }),
                                         failureBlock: { (response: HTTPJSONResponse) -> (Void) in
                                            guard let errorMessage = response.json["form_errors"]["doximity_user_verification"].string else {
                                                failureBlock(response)
                                                return
                                            }
                                            
                                            guard let code = response.json["form_errors"]["code"].int else {
                                                failureBlock(response)
                                                return
                                            }
                                            
                                            failureBlock(HTTPJSONResponse(withJSON: response.json, code: code, message: errorMessage))
        })
    }
}

extension NetworkManager : PhotosNetworkProtocol {
    
    func uploadPhotoToNewNode(_ photo: Photo,
                              successBlock: @escaping NetworkJSONSuccessBlock,
                              failureBlock: @escaping NetworkJSONFailureBlock) {
        uploadPhoto(photo, successBlock: { (response) -> (Void) in
            let uploadedImage = response.object as! UploadedImage
            self.attachPhotoToNewNode(withUploadedImage: uploadedImage, originalPhoto: photo, successBlock: successBlock, failureBlock: failureBlock)
        }) { (response: HTTPJSONResponse) -> (Void) in
            failureBlock(response)
        }
    }
    
    func uploadPhotoToExtistingNode(_ photo: Photo,
                                    successBlock: @escaping NetworkJSONSuccessBlock,
                                    failureBlock: @escaping NetworkJSONFailureBlock) {
        uploadPhoto(photo, successBlock: { (response) -> (Void) in
            let uploadedImage = response.object as! UploadedImage
            self.attachPhotoToExtistingNode(withUploadedImage: uploadedImage, originalPhoto: photo, successBlock: successBlock, failureBlock: failureBlock)
        }) { (response: HTTPJSONResponse) -> (Void) in
            failureBlock(response)
        }
    }
    
    private func uploadPhoto(_ photo: Photo,
                             successBlock: @escaping NetworkJSONSuccessBlock,
                             failureBlock: @escaping NetworkJSONFailureBlock) {
        
        let userInfo = userManager?.currentUser
        let header = headerWithCookieAndToken()
        
        let imageData = UIImageJPEGRepresentation(photo.image!, 0.5)
        let encodedImage = imageData?.base64EncodedString()
        
        var params = defaultParams()
        params["file"] = encodedImage as AnyObject?
        params["filename"] = "default.jpg" as AnyObject?
        params["filesize"] = imageData!.count as AnyObject?
        params["uid"] = userInfo!.userID as AnyObject?
        params["filepath"] = "private://images/default.jpg" as AnyObject?
        params["status"] = "0" as AnyObject?
        
        _ = self.postRequestWithEndpoint(uploadPhotoEndpoint, params: params, headers: header,
                                         mappingBlock: ({ (response: URLResponse, json: JSON) -> (MappingResult) in
                                            guard let uploadImage = UploadedImage(json: json) else { return .failure }
                                            return .success(uploadImage)
                                         }),
                                         successBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            successBlock(response)
                                         }),
                                         failureBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            failureBlock(response)
                                         }))
    }
    
    private func attachPhotoToExtistingNode(withUploadedImage uploadedImage: UploadedImage,
                                            originalPhoto photo: Photo,
                                            successBlock: @escaping NetworkJSONSuccessBlock,
                                            failureBlock: @escaping NetworkJSONFailureBlock) {
        
        guard let requiredNodeID = photo.nodeID else {
            failureBlock(HTTPJSONResponse(withJSON: JSON.null, code: -1, message: ""))
            return
        }
        
        let header = headerWithCookieAndToken()
        let endpoint = nodeEndpoint.appendingFormat("%@.json", requiredNodeID)
        var params = defaultParams()
        params["type"] = "image" as AnyObject?
        params["title"] = photo.title as AnyObject?
        params["field_image"] = ["und": [
            ["fid": uploadedImage.fid],
            ["display": "1"]]
            ] as AnyObject?
        
        if let folderID = photo.folderID {
            params["field_folder"] = ["und": [folderID]] as AnyObject?
        }
        
        _ = self.putRequestWithEndpoint(endpoint, params: params, headers: header, mappingBlock: nil,
                                        successBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            successBlock(response)
                                        }), failureBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            failureBlock(response)
                                        }))
    }
    
    private func attachPhotoToNewNode(withUploadedImage uploadedImage: UploadedImage,
                                      originalPhoto photo: Photo,
                                      successBlock: @escaping NetworkJSONSuccessBlock,
                                      failureBlock: @escaping NetworkJSONFailureBlock) {
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        params["type"] = "image" as AnyObject?
        params["title"] = photo.title as AnyObject?
        params["language"] = "und" as AnyObject?
        
        params["body"] = ["und" : [[
            "value": photo.note ?? ""]]
            ] as AnyObject?
        
        params["field_image"] = ["und": [
            ["fid": uploadedImage.fid],
            ["display": "1"],
            ["alt": photo.title],
            ["title": photo.title]
            ]
            ] as AnyObject?
        
        params["field_date"] = ["und": [[
            "value": [
                "date": DateHelper.stringDateFrom(Date())]
            ]]
            ] as AnyObject?
        
        if let folderID = photo.folderID {
            params["field_folder"] = ["und": [folderID]] as AnyObject?
        }
        
        if let location = locationService?.currentLocation() {
            params["field_location"] = ["und": [[
                "locpick": [
                    "user_latitude": location.latitude,
                    "user_longitude": location.longitude]
                ]]
                ] as AnyObject?
        }
        
        if let groupID = photo.group?.groupID {
            if photo.folderID != nil {
                params["og_group_ref"] = [groupID] as AnyObject//["und" : [groupID]] as AnyObject //[groupID] as AnyObject
            } else {
                params["og_group_ref"] = ["und" : [groupID]] as AnyObject
            }
        }
        
        _ = self.postRequestWithEndpoint(nodeJsonEndpoint, params: params, headers: header,
                                         mappingBlock: ({ (response: URLResponse, json: JSON) -> (MappingResult) in
                                            guard let fetchedNode = Node(json: json) else { return .failure }
                                            return .success(fetchedNode)
                                         }),
                                         successBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            successBlock(response)
                                         }),
                                         failureBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            failureBlock(response)
                                         }))
    }
    
    func getFolderContents(withQuery paginationQuery: PhotosPaginationQuery,
                           successBlock: @escaping NetworkJSONSuccessBlock,
                           failureBlock: @escaping NetworkJSONFailureBlock) -> NetworkRequest? {
        var endpoint = photosEndpoint
        let userInfo = userManager?.currentUser
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        
        if paginationQuery.dateFilter != .none {
            let calendar = NSCalendar.current
            
            if paginationQuery.dateFilter == .yesterday {
                let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
                params = self.params(betweenDates: yesterday, endDate: Date())
            } else {
                switch paginationQuery.dateFilter {
                case .week:
                    let week = calendar.date(byAdding: .weekOfYear, value: -1, to: Date())
                    params = self.params(filterDate: week!)
                    
                    break
                case .month:
                    let month = calendar.date(byAdding: .month, value: -1, to: Date())
                    params = self.params(filterDate: month!)
                    
                    break
                case .custom:
                    let start = paginationQuery.startDate
                    var end = paginationQuery.endDate
                    end = calendar.date(byAdding: .day, value: 1, to: end!)!
                    params = self.params(betweenDates: start!, endDate: end!)
                    
                    break
                default:
                    break
                }
            }
        }
        
        if paginationQuery.hasSearch, let usernames = paginationQuery.searchValueString, let title = paginationQuery.titleSearchValue {
            params["username"] = usernames as AnyObject?
            params["title"] = title as AnyObject?
            params["title_op"] = "word" as AnyObject?
            
            if paginationQuery.isSharedWithMe {
                params["uid_op"] = "!=" as AnyObject?
                params["uid[value]"] = userInfo?.userID as AnyObject?
                endpoint = myPhotosEndpoint
            }
        } else {
            if let folderID = paginationQuery.folderID {
                if paginationQuery.ownershipFilter == .allInFolder {
                    endpoint = endpoint.appendingFormat("/%@", folderID)
                } else {
                    params["field_folder_tid"] = folderID as AnyObject?
                }
            } else if paginationQuery.ownershipFilter == .my {
                if paginationQuery.isSharedWithMe {
                    params["field_folder_tid"] = "shared" as AnyObject?
                } else {
                    params["field_folder_tid"] = "my" as AnyObject?
                }
            } else if paginationQuery.ownershipFilter == .allInFolder {
                if paginationQuery.isSharedWithMe {
                    endpoint = myPhotosEndpoint
                    params["uid_op"] = "!=" as AnyObject?
                    params["uid[value]"] = userInfo?.userID as AnyObject?
                }
            }
        }
        
        switch paginationQuery.ownershipFilter {
        case .allInFolder, .my:
            if !paginationQuery.isSharedWithMe {
                params["uid_op"] = "=" as AnyObject?
                params["uid[value]"] = userInfo?.userID as AnyObject?
            }
            
            break
        case .all:
            break
        case .group(let group):
            if paginationQuery.folderID == nil {
                params["og_group_ref_target_id"] = group.groupID! as AnyObject?
            }
            
            break
        }
        
        params["page"] = paginationQuery.page as AnyObject?
        params["items_per_page"] = paginationQuery.ItemsOnPageDefault as AnyObject?
        
        return self.getRequestWithEndpoint(endpoint,
                                           params: params,
                                           headers: header,
                                           mappingBlock: ({ (response: URLResponse, json: JSON) -> (MappingResult) in
                                            
                                            let limit = json["view"]["pages"].intValue
                                            
                                            if let folder = Folder(json: json) {
                                                let photoLoadingResponse = PhotoLoadingPageResponse(limit: limit, folder: folder)
                                                
                                                return .success(photoLoadingResponse as AnyObject)
                                            }
                                            
                                            return .failure
                                           }),
                                           successBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            successBlock(response)
                                           }), failureBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            failureBlock(response)
                                           }))
    }
    
    func createFolder(withTitle title: String,
                      forParentFolder parent: Folder?,
                      group: Group?,
                      successBlock: @escaping NetworkJSONSuccessBlock,
                      failureBlock: @escaping NetworkJSONFailureBlock) {
        let header = headerWithCookieAndToken()
        let endpoint = folderEndpoint.appending(".json")
        var params = defaultParams()
        params["vid"] = "2" as AnyObject?
        params["name"] = title as AnyObject?
        params["weight"] = "0" as AnyObject?
        
        if let folderID = parent?.folderID {
            params["parent"] = [folderID] as AnyObject?
        }
        
        if let groupID = group?.groupID, parent == nil {
            params["og_group_ref"] = ["und" : [groupID]] as AnyObject // [groupID] as AnyObject
        }
        
        _ = self.postRequestWithEndpoint(endpoint, params: params, headers: header, mappingBlock: nil, successBlock: { (response: HTTPJSONResponse) -> (Void) in
            successBlock(response)
        }, failureBlock: { (response: HTTPJSONResponse) -> (Void) in
            guard let errorMessage = response.json["form_errors"]["name"].string else {
                failureBlock(response)
                
                return
            }
            
            failureBlock(HTTPJSONResponse(withJSON: response.json, code: response.code, message: errorMessage))
        })
    }
    
    func deleteFolder(_ folder: Folder,
                      successBlock: @escaping NetworkJSONSuccessBlock,
                      failureBlock: @escaping NetworkJSONFailureBlock) {
        let header = headerWithCookieAndToken()
        let endpoint = folderEndpoint.appendingFormat("/%@.json", folder.folderID!)
        
        _ = deleteRequestWithEndpoint(endpoint, params: nil, headers: header, mappingBlock: nil, successBlock: { (response: HTTPJSONResponse) -> (Void) in
            successBlock(response)
        }, failureBlock: { (response: HTTPJSONResponse) -> (Void) in
            failureBlock(response)
        })
    }
    
    func editFolder(_ folder: Folder,
                    successBlock: @escaping NetworkJSONSuccessBlock,
                    failureBlock: @escaping NetworkJSONFailureBlock) {
        let header = headerWithCookieAndToken()
        let endpoint = folderEndpoint.appendingFormat("/%@.json", folder.folderID!)
        var params = defaultParams()
        params["name"] = folder.title as AnyObject?
        
        _ = putRequestWithEndpoint(endpoint, params: params, headers: header, mappingBlock: nil, successBlock: { (response: HTTPJSONResponse) -> (Void) in
            successBlock(response)
        }, failureBlock: { (response: HTTPJSONResponse) -> (Void) in
            guard let errorMessage = response.json["form_errors"]["name"].string else {
                failureBlock(response)
                
                return
            }
            
            failureBlock(HTTPJSONResponse(withJSON: response.json, code: response.code, message: errorMessage))
        })
    }
    
    func usernameAutocomplete(withUsernames usernames: String,
                              successBlock: @escaping NetworkJSONSuccessBlock,
                              failureBlock: @escaping NetworkJSONFailureBlock) -> NetworkRequest? {
        let header = headerWithCookie()
        let names = usernames.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let endpoint = userAutocompleteEndpoint.appending(names!)
        
        return self.getRequestWithEndpoint(endpoint, params: nil, headers: header,
                                           mappingBlock: ({ (response: URLResponse, json: JSON) -> (MappingResult) in
                                            if let listDictionary = json.dictionary  {
                                                return .success(listDictionary as AnyObject)
                                            } else {
                                                if (json.array != nil) {
                                                    let emptyDict = Dictionary<String, Any>()
                                                    return .success(emptyDict as AnyObject)
                                                }
                                                
                                                return .failure }
                                           }),
                                           successBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            successBlock(response)
                                           }), failureBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            failureBlock(response)
                                           }))
    }
    
    func searchUsers(withQuery paginationQuery: SearchUsersPaginationQuery,
                     successBlock: @escaping NetworkJSONSuccessBlock,
                     failureBlock: @escaping NetworkJSONFailureBlock) -> NetworkRequest? {
        let header = headerWithCookieAndToken()
        var params = [String: AnyObject]()
        params["string"] = paginationQuery.keywords as AnyObject?
        params["page"] = paginationQuery.page as AnyObject?
        params["items_per_page"] = paginationQuery.ItemsOnPageDefault as AnyObject?
        
        if paginationQuery.excludeCurrentUser {
            params["uid_current"] = 0 as AnyObject?
        }
        
        return self.getRequestWithEndpoint(searchUsersEndpoint, params: params, headers: header,
                                           mappingBlock: ({ (response: URLResponse, json: JSON) -> (MappingResult) in
                                            let limit = json["view"]["pages"].int
                                            let users = json["users"]
                                            
                                            if let listUsers = users.dictionary {
                                                var users: [ShareUser] = []
                                                
                                                for curObject in listUsers {
                                                    if let username = curObject.value.string {
                                                        let user: ShareUser = ShareUser(userID: curObject.key, username: username)
                                                        users.append(user)
                                                    }
                                                }
                                                
                                                users = users.sorted {
                                                    $0.username!.localizedCaseInsensitiveCompare($1.username!) == ComparisonResult.orderedAscending }
                                                
                                                let usersLoadingResponse = ShareUserLoadingPageResponse(limit: limit, users: users)
                                                
                                                return .success(usersLoadingResponse as AnyObject)
                                            }
                                            
                                            return .failure
                                           }),
                                           successBlock: { (response: HTTPJSONResponse) -> (Void) in
                                            successBlock(response)
        }, failureBlock: { (response: HTTPJSONResponse) -> (Void) in
            failureBlock(response)
        })
    }
    
    private func params(betweenDates startDate: Date, endDate: Date) -> [String : AnyObject] {
        var params = defaultParams()
        let calendar = NSCalendar.current
        
        params["field_date_value_op"] = "between" as AnyObject?
        params["field_date_value[max][year]"] = calendar.component(.year, from: endDate) as AnyObject?
        params["field_date_value[max][month]"] = calendar.component(.month, from: endDate) as AnyObject?
        params["field_date_value[max][day]"] = calendar.component(.day, from: endDate) as AnyObject?
        params["field_date_value[max][hour]"] = "0" as AnyObject?
        params["field_date_value[max][minute]"] = "00" as AnyObject?
        
        params["field_date_value[min][year]"] = calendar.component(.year, from: startDate) as AnyObject?
        params["field_date_value[min][month]"] = calendar.component(.month, from: startDate) as AnyObject?
        params["field_date_value[min][day]"] = calendar.component(.day, from: startDate) as AnyObject?
        params["field_date_value[min][hour]"] = "0" as AnyObject?
        params["field_date_value[min][minute]"] = "00" as AnyObject?
        
        return params
    }
    
    private func params(filterDate date: Date) -> [String : AnyObject] {
        var params = defaultParams()
        let calendar = NSCalendar.current
        
        params["field_date_value_op"] = ">" as AnyObject?
        params["field_date_value[value][year]"] = calendar.component(.year, from: date) as AnyObject?
        params["field_date_value[value][month]"] = calendar.component(.month, from: date) as AnyObject?
        params["field_date_value[value][day]"] = calendar.component(.day, from: date) as AnyObject?
        params["field_date_value[value][hour]"] = "0" as AnyObject?
        params["field_date_value[value][minute]"] = "00" as AnyObject?
        
        return params
    }
    
    func loadImage(fromURL url: URL,
                   successBlock: @escaping NetworkPhotoLoadSuccessBlock,
                   failureBlock: @escaping NetworkPhotoLoadFailureBlock) {
        let userInfo = userManager?.currentUser
        let request = NSMutableURLRequest(url: url)
        request.setValue(userInfo!.token, forHTTPHeaderField: "X-CSRF-Token")
        let cookie = userInfo!.sessionName!.appendingFormat("=%@", userInfo!.sessionID!)
        request.setValue(cookie, forHTTPHeaderField: "cookie")
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            if error == nil {
                successBlock(data!)
            }
            else {
                failureBlock(error!)
            }
        })
        
        task.resume()
    }
    
    func retrieveImage(byNode nodeID: String,
                       successBlock: @escaping NetworkJSONSuccessBlock,
                       failureBlock: @escaping NetworkJSONFailureBlock) -> NetworkRequest? {
        let header = headerWithCookie()
        let endpoint = nodeEndpoint.appendingFormat("%@.json", nodeID)
        let params = defaultParams()
        
        return self.getRequestWithEndpoint(endpoint, params: params, headers: header,
                                           mappingBlock: nil,
                                           successBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            let fileID = response.json["field_image"]["und"][0]["fid"].string
                                            _ = self.retrieveFile(byFileID: fileID!,
                                                                  successBlock: successBlock,
                                                                  failureBlock: failureBlock)
                                           }),
                                           failureBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            failureBlock(response)
                                           }))
    }
    
    func retrieveFile(byFileID fileID: String,
                      successBlock: @escaping NetworkJSONSuccessBlock,
                      failureBlock: @escaping NetworkJSONFailureBlock) -> NetworkRequest? {
        let header = headerWithCookie()
        let endpoint = retriveFileEndpoint.appendingFormat("%@.json", fileID)
        let params = defaultParams()
        
        return self.getRequestWithEndpoint(endpoint, params: params, headers: header,
                                           mappingBlock: ({ (response: URLResponse, json: JSON) -> (MappingResult) in
                                            
                                            if let fileURL = json["file"].string {
                                                let decodedData = Data(base64Encoded: fileURL, options: NSData.Base64DecodingOptions(rawValue: 0))
                                                
                                                if let data = decodedData {
                                                    let decodedImage = UIImage(data: data)
                                                    return .success(decodedImage as AnyObject)
                                                }
                                            }
                                            
                                            return .failure
                                           }),
                                           successBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            successBlock(response)
                                           }),
                                           failureBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            failureBlock(response)
                                           }))
    }
    
    func editPhoto(fromPhoto photo: Photo,
                   successBlock: @escaping NetworkJSONSuccessBlock,
                   failureBlock: @escaping NetworkJSONFailureBlock) {
        
        guard let requiredNodeID = photo.nodeID else {
            failureBlock(HTTPJSONResponse(withJSON: JSON.null, code: -1, message: ""))
            return
        }
        
        let header = headerWithCookieAndToken()
        let endpoint = nodeEndpoint.appendingFormat("%@.json", requiredNodeID)
        var params = defaultParams()
        params["title"] = photo.title as AnyObject?
        params["body"] = ["und" : [[
            "value": photo.note ?? ""]]
            ] as AnyObject?
        
        if let folderID = photo.folderID {
            params["field_folder"] = ["und": [folderID]] as AnyObject?
        }
        
        _ = self.putRequestWithEndpoint(endpoint, params: params, headers: header, mappingBlock: nil,
                                        successBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            successBlock(response)
                                        }), failureBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            failureBlock(response)
                                        }))
    }
    
    func deletePhoto(_ photo: Photo,
                     successBlock: @escaping NetworkJSONSuccessBlock,
                     failureBlock: @escaping NetworkJSONFailureBlock) {
        let header = headerWithCookieAndToken()
        let endpoint = nodeEndpoint.appendingFormat("%@.json", photo.nodeID!)
        
        _ = self.deleteRequestWithEndpoint(endpoint, params: nil, headers: header,
                                           mappingBlock: nil,
                                           successBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            successBlock(response)
                                           }), failureBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            failureBlock(response)
                                           }))
    }
    
    func retrievePhoto(byNode nodeID: String,
                       successBlock: @escaping NetworkJSONSuccessBlock,
                       failureBlock: @escaping NetworkJSONFailureBlock) -> NetworkRequest? {
        
        let header = headerWithCookie()
        let endpoint = nodeEndpoint.appendingFormat("%@.json", nodeID)
        let params = defaultParams()
        
        return self.getRequestWithEndpoint(endpoint,
                                           params: params,
                                           headers: header,
                                           mappingBlock: { (response, json) in
                                            
                                            guard let nodeID = json["nid"].string,
                                                let uid = json["uid"].string
                                                else { return .failure }
                                            
                                            let photoTitle = json["title"].string
                                            let username = json["name"].string
                                            let timestamp = json["field_date"]["und"][0]["value"].string
                                            
                                            let photo = Photo(with: nil,
                                                              title: photoTitle,
                                                              timestamp: timestamp,
                                                              username: username,
                                                              link: nil,
                                                              note: nil,
                                                              nodeID: nodeID,
                                                              folderID: nil,
                                                              folderName: nil,
                                                              uid: uid,
                                                              group: nil,
                                                              isUpdated: false,
                                                              cacheIdenifier: nil)
                                            
                                            return .success(photo as AnyObject)
        },
                                           successBlock: successBlock,
                                           failureBlock: failureBlock)
    }
        
    // MARK: - Sharing
    
    private func shareToUserParams(_ users: [ShareUser]) -> [String : AnyObject] {
        var params: [String : AnyObject] = [String : AnyObject]()
        var recipientsIds: [[String : AnyObject]] = []
        users.forEach { (currentUser) in
            var recipientParams = [String : AnyObject]()
            recipientParams["recipient_id"] = currentUser.userID as AnyObject?
            recipientParams["recipient_type"] = "account" as AnyObject?
            
            recipientsIds.append(recipientParams)
        }
        params["recipient_id"] = recipientsIds as AnyObject?
        
        return params
    }
    
    private func shareToDoximityUserParams(_ users: [ShareUser]) -> [String : AnyObject] {
        var params: [String : AnyObject] = [String : AnyObject]()
        var recipientsIds: [[String : AnyObject]] = []
        users.forEach { (currentUser) in
            var recipientParams = [String : AnyObject]()
            recipientParams["recipient_id"] = currentUser.userID as AnyObject?
            recipientParams["recipient_type"] = "doximity_id" as AnyObject?
            
            recipientsIds.append(recipientParams)
        }
        params["recipient_id"] = recipientsIds as AnyObject?
        
        return params
    }
    
    private func shareByEmailsParams(_ emails: [String]) -> [String : AnyObject] {
        var params: [String : AnyObject] = [String : AnyObject]()
        var recipientsIds: [[String : AnyObject]] = []
        emails.forEach { (currentEmail) in
            var recipientParams = [String : AnyObject]()
            recipientParams["recipient_id"] = currentEmail as AnyObject?
            recipientParams["recipient_type"] = "email" as AnyObject?
            
            recipientsIds.append(recipientParams)
        }
        params["recipient_id"] = recipientsIds as AnyObject?
        
        return params
    }
    
    private func shareByTextsParams(_ texts: [String]) -> [String : AnyObject] {
        var params: [String : AnyObject] = [String : AnyObject]()
        var recipientsIds: [[String : AnyObject]] = []
        texts.forEach { (currentText) in
            var recipientParams = [String : AnyObject]()
            recipientParams["recipient_id"] = currentText.removedFormatString() as AnyObject?
            recipientParams["recipient_type"] = "phone" as AnyObject?
            
            recipientsIds.append(recipientParams)
        }
        params["recipient_id"] = recipientsIds as AnyObject?
        
        return params
    }
    
    private func sharePhoto(_ photo: Photo,
                            withAdditionalParams additionalParams: [String: AnyObject],
                            successBlock: @escaping NetworkJSONSuccessBlock,
                            failureBlock: @escaping NetworkJSONFailureBlock) {
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        params["entity"] = photo.nodeID as AnyObject?
        params["entity_type"] = "node" as AnyObject?
        params["recipient_type"] = "multiple" as AnyObject?
        additionalParams.forEach { params.updateValue($1, forKey: $0) }
        
        _ = self.postRequestWithEndpoint(shareEndpoint, params: params, headers: header, encoding: JSONEncoding.default, mappingBlock: nil, successBlock: { (response: HTTPJSONResponse) -> (Void) in
            successBlock(response)
        }, failureBlock: { (response: HTTPJSONResponse) -> (Void) in
            
            guard let requiredNoDoximityUserExistErrorCode = response.json.array?[0]["data"]["form_errors"]["code"].int,
                requiredNoDoximityUserExistErrorCode == noDoximityUserExistErrorCode,
                let requiredMessage = response.json.array?[0]["message"].string
                else {
                    failureBlock(response)
                    return
            }
            
            let updatedResponse = HTTPJSONResponse(withJSON: response.json,
                                                   code: requiredNoDoximityUserExistErrorCode,
                                                   message: requiredMessage)
            failureBlock(updatedResponse)
        })
    }
    
    func sharePhotoToUser(_ photo: Photo,
                          forUsers users: [ShareUser],
                          successBlock: @escaping NetworkJSONSuccessBlock,
                          failureBlock: @escaping NetworkJSONFailureBlock) {
        let params = shareToUserParams(users)
        sharePhoto(photo, withAdditionalParams: params, successBlock: successBlock, failureBlock: failureBlock)
    }
    
    func sharePhotoToDoximityUser(_ photo: Photo,
                                  forUsers users: [ShareUser],
                                  successBlock: @escaping NetworkJSONSuccessBlock,
                                  failureBlock: @escaping NetworkJSONFailureBlock) {
        let params = shareToDoximityUserParams(users)
        sharePhoto(photo, withAdditionalParams: params, successBlock: successBlock, failureBlock: failureBlock)
    }
    
    func sharePhoto(_ photo: Photo,
                    byEmails emails: [String],
                    successBlock: @escaping NetworkJSONSuccessBlock,
                    failureBlock: @escaping NetworkJSONFailureBlock) {
        let params = shareByEmailsParams(emails)
        sharePhoto(photo, withAdditionalParams: params, successBlock: successBlock, failureBlock: failureBlock)
    }
    
    func sharePhoto(_ photo: Photo,
                    byTexts texts: [String],
                    successBlock: @escaping NetworkJSONSuccessBlock,
                    failureBlock: @escaping NetworkJSONFailureBlock) {
        let params = shareByTextsParams(texts)
        sharePhoto(photo, withAdditionalParams: params, successBlock: successBlock, failureBlock: failureBlock)
    }
    
    func sharePhoto(_ photo: Photo,
                    toGroup group: Group,
                    successBlock: @escaping NetworkJSONSuccessBlock,
                    failureBlock: @escaping NetworkJSONFailureBlock) {
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        params["entity"] = photo.nodeID as AnyObject?
        params["entity_type"] = "node" as AnyObject?
        params["recipient_type"] = "group" as AnyObject?
        params["recipient_id"] = group.groupID as AnyObject?
        params["group_type"] = "node" as AnyObject?
        params["gid"] = group.groupID as AnyObject?
        
        _ = self.postRequestWithEndpoint(shareEndpoint, params: params, headers: header, encoding: JSONEncoding.default, mappingBlock: nil, successBlock: { (response: HTTPJSONResponse) -> (Void) in
            successBlock(response)
        }, failureBlock: { (response: HTTPJSONResponse) -> (Void) in
            failureBlock(response)
        })
    }
    
    private func shareFolder(_ folder: Folder,
                             withAdditionalParams additionalParams: [String : AnyObject],
                             successBlock: @escaping NetworkJSONSuccessBlock,
                             failureBlock: @escaping NetworkJSONFailureBlock) {
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        params["entity"] = folder.folderID as AnyObject?
        params["entity_type"] = "taxonomy_term" as AnyObject?
        params["recipient_type"] = "multiple" as AnyObject?
        additionalParams.forEach { params.updateValue($1, forKey: $0) }
        
        _ = self.postRequestWithEndpoint(shareEndpoint, params: params, headers: header, encoding: JSONEncoding.default, mappingBlock: nil, successBlock: { (response: HTTPJSONResponse) -> (Void) in
            successBlock(response)
        }, failureBlock: { (response: HTTPJSONResponse) -> (Void) in
            
            guard let requiredNoDoximityUserExistErrorCode = response.json.array?[0]["data"]["form_errors"]["code"].int,
                requiredNoDoximityUserExistErrorCode == noDoximityUserExistErrorCode,
                let requiredMessage = response.json.array?[0]["message"].string
                else {
                    failureBlock(response)
                    return
            }
            
            let updatedResponse = HTTPJSONResponse(withJSON: response.json,
                                                   code: requiredNoDoximityUserExistErrorCode,
                                                   message: requiredMessage)
            failureBlock(updatedResponse)
        })
    }
    
    func shareFolderToUser(_ folder: Folder,
                           forUsers users: [ShareUser],
                           successBlock: @escaping NetworkJSONSuccessBlock,
                           failureBlock: @escaping NetworkJSONFailureBlock) {
        let params = shareToUserParams(users)
        shareFolder(folder, withAdditionalParams: params, successBlock: successBlock, failureBlock: failureBlock)
    }
    
    func shareFolderToDoximityUser(_ folder: Folder,
                                   forUsers users: [ShareUser],
                                   successBlock: @escaping NetworkJSONSuccessBlock,
                                   failureBlock: @escaping NetworkJSONFailureBlock) {
        let params = shareToDoximityUserParams(users)
        shareFolder(folder, withAdditionalParams: params, successBlock: successBlock, failureBlock: failureBlock)
    }
    
    func shareFolder(_ folder: Folder,
                     byEmails emails: [String],
                     successBlock: @escaping NetworkJSONSuccessBlock,
                     failureBlock: @escaping NetworkJSONFailureBlock) {
        let params = shareByEmailsParams(emails)
        shareFolder(folder, withAdditionalParams: params, successBlock: successBlock, failureBlock: failureBlock)
    }
    
    func shareFolder(_ folder: Folder,
                     byTexts texts: [String],
                     successBlock: @escaping NetworkJSONSuccessBlock,
                     failureBlock: @escaping NetworkJSONFailureBlock) {
        let params = shareByTextsParams(texts)
        shareFolder(folder, withAdditionalParams: params, successBlock: successBlock, failureBlock: failureBlock)
    }
    
    func shareFolder(_ folder: Folder,
                     toGroup group: Group,
                     successBlock: @escaping NetworkJSONSuccessBlock,
                     failureBlock: @escaping NetworkJSONFailureBlock) {
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        params["entity"] = folder.folderID as AnyObject?
        params["entity_type"] = "taxonomy_term" as AnyObject?
        params["recipient_type"] = "group" as AnyObject?
        params["recipient_id"] = group.groupID as AnyObject?
        params["group_type"] = "node" as AnyObject?
        params["gid"] = group.groupID as AnyObject?
        
        _ = self.postRequestWithEndpoint(shareEndpoint, params: params, headers: header, encoding: JSONEncoding.default, mappingBlock: nil, successBlock: { (response: HTTPJSONResponse) -> (Void) in
            successBlock(response)
        }, failureBlock: { (response: HTTPJSONResponse) -> (Void) in
            failureBlock(response)
        })
    }
    
    private func shareGroup(_ group: Group,
                            withAdditionalParams additionalParams: [String : AnyObject],
                            successBlock: @escaping NetworkJSONSuccessBlock,
                            failureBlock: @escaping NetworkJSONFailureBlock) {
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        params["entity"] = group.groupID as AnyObject?
        params["entity_type"] = "node" as AnyObject?
        params["recipient_type"] = "multiple" as AnyObject?
        additionalParams.forEach { params.updateValue($1, forKey: $0) }
        
        _ = self.postRequestWithEndpoint(shareEndpoint, params: params, headers: header, encoding: JSONEncoding.default,
                                         mappingBlock: ({ (response: URLResponse, json: JSON) -> (MappingResult) in
                                            if let responseArray = json.array {
                                                var recipients: [Recipient] = []
                                                
                                                for currentItem in responseArray {
                                                    if let data = currentItem["data"].dictionary {
                                                        
                                                        guard let recipientID = data["recipient_id"]?.stringValue else { continue }
                                                        guard let recipientType = data["recipient_type"]?.stringValue else { continue }
                                                        guard let code = data["form_errors"]?["code"].intValue else { continue }
                                                        
                                                        let recipient = Recipient(recipientID: recipientID,
                                                                                  recipientType: recipientType,
                                                                                  code: code)
                                                        recipients.append(recipient)
                                                    }
                                                }
                                                
                                                let groupsLoadingResponse = GroupSharingResponse(isSuccess: (recipients.count == 0), recipient: recipients)
                                                
                                                return .success(groupsLoadingResponse as AnyObject)
                                            }
                                            
                                            return .failure
                                         }), successBlock: { (response: HTTPJSONResponse) -> (Void) in
                                            successBlock(response)
        }, failureBlock: { (response: HTTPJSONResponse) -> (Void) in
            
            guard let requiredNoDoximityUserExistErrorCode = response.json.array?[0]["data"]["form_errors"]["code"].int,
                requiredNoDoximityUserExistErrorCode == noDoximityUserExistErrorCode,
                let requiredMessage = response.json.array?[0]["message"].string
                else {
                    failureBlock(response)
                    return
            }
            
            let updatedResponse = HTTPJSONResponse(withJSON: response.json,
                                                   code: requiredNoDoximityUserExistErrorCode,
                                                   message: requiredMessage)
            failureBlock(updatedResponse)
        })
    }
    
    func shareGroupToUser(_ group: Group,
                          forUsers users: [ShareUser],
                          successBlock: @escaping NetworkJSONSuccessBlock,
                          failureBlock: @escaping NetworkJSONFailureBlock) {
        let params = shareToUserParams(users)
        shareGroup(group, withAdditionalParams: params, successBlock: successBlock, failureBlock: failureBlock)
    }
    
    func shareGroupToDoximityUser(_ group: Group,
                                  forUsers users: [ShareUser],
                                  successBlock: @escaping NetworkJSONSuccessBlock,
                                  failureBlock: @escaping NetworkJSONFailureBlock) {
        let params = shareToDoximityUserParams(users)
        shareGroup(group, withAdditionalParams: params, successBlock: successBlock, failureBlock: failureBlock)
    }
    
    func shareGroup(_ group: Group,
                    byTexts texts: [String],
                    successBlock: @escaping NetworkJSONSuccessBlock,
                    failureBlock: @escaping NetworkJSONFailureBlock) {
        let params = shareByTextsParams(texts)
        shareGroup(group, withAdditionalParams: params, successBlock: successBlock, failureBlock: failureBlock)
    }
    
    func shareGroup(_ group: Group,
                    byEmails emails: [String],
                    successBlock: @escaping NetworkJSONSuccessBlock,
                    failureBlock: @escaping NetworkJSONFailureBlock) {
        let params = shareByEmailsParams(emails)
        shareGroup(group, withAdditionalParams: params, successBlock: successBlock, failureBlock: failureBlock)
    }
    
    // MARK: - Groups
    
    func getGroups(withQuery paginationQuery: GroupsPaginationQuery,
                   successBlock: @escaping NetworkJSONSuccessBlock,
                   failureBlock: @escaping NetworkJSONFailureBlock) -> NetworkRequest? {
        let header = headerWithCookieAndToken()
        var params = [String: AnyObject]()
        params["page"] = paginationQuery.page as AnyObject?
        params["items_per_page"] = paginationQuery.ItemsOnPageDefault as AnyObject?
        params["title"] = paginationQuery.keywords as AnyObject?
        params["title_op"] = "word" as AnyObject?
        params["field_manually_added_value"] = 1 as AnyObject?
        
        return self.getRequestWithEndpoint(groupsEndpoint, params: params, headers: header,
                                           mappingBlock: ({ (response: URLResponse, json: JSON) -> (MappingResult) in
                                            let limit = json["view"]["pages"].intValue
                                            
                                            if let nodes = json["nodes"].array {
                                                var groups: [Group] = []
                                                
                                                for node in nodes {
                                                    if let group = Group(json: node["node"]) {
                                                        group.usersCount = node["members_count"].intValue
                                                        
                                                        groups.append(group)
                                                    }
                                                }
                                                
                                                let groupsLoadingResponse = GroupsLoadingPageResponse(limit: limit, groups: groups)
                                                
                                                return .success(groupsLoadingResponse as AnyObject)
                                            }
                                            
                                            return .failure
                                           }),
                                           successBlock: { (response: HTTPJSONResponse) -> (Void) in
                                            successBlock(response)
        }, failureBlock: { (response: HTTPJSONResponse) -> (Void) in
            failureBlock(response)
        })
    }
    
    func createGroup(with title: String,
                     successBlock: @escaping NetworkJSONSuccessBlock,
                     failureBlock: @escaping NetworkJSONFailureBlock) {
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        params["type"] = "group" as AnyObject?
        params["title"] = title as AnyObject?
        params["language"] = "und" as AnyObject?
        params["group_access"] = ["und": 1] as AnyObject?
        params["field_manually_added"] = ["und": 0] as AnyObject?
        
        _ = postRequestWithEndpoint(nodeJsonEndpoint, params: params, headers: header,
                                    mappingBlock: ({ (response: URLResponse, json: JSON) -> (MappingResult) in
                                        if let nid = json["nid"].string, let uri = json["uri"].string {
                                            let createGroupRespnose = CreateGroupResponse(nid: nid, uri: uri)
                                            return .success(createGroupRespnose as AnyObject)
                                        }
                                        
                                        return .failure
                                    }),
                                    successBlock: { (response) -> (Void) in
                                        successBlock(response)
        }, failureBlock: { (response) -> (Void) in
            failureBlock(response)
        })
    }
    
    func editGroup(_ group: Group,
                   with title: String,
                   successBlock: @escaping NetworkJSONSuccessBlock,
                   failureBlock: @escaping NetworkJSONFailureBlock) {
        
        guard let requiredGroupID = group.groupID else {
            failureBlock(HTTPJSONResponse(withJSON: JSON.null, code: -1, message: ""))
            return
            
        }
        
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        params["title"] = title as AnyObject
        
        let endpoint = nodeEndpoint.appendingFormat("%@.json", requiredGroupID)
        
        self.putRequestWithEndpoint(endpoint,
                                    params: params,
                                    headers: header,
                                    mappingBlock: nil,
                                    successBlock: { (response) -> (Void) in
                                        successBlock(response)
        },
                                    failureBlock: { (response) -> (Void) in
                                        failureBlock(response)
        })
        
    }
    
    func deleteGroup(_ group: Group,
                     successBlock: @escaping NetworkJSONSuccessBlock,
                     failureBlock: @escaping NetworkJSONFailureBlock) {
        
        guard let requiredGroupID = group.groupID else {
            failureBlock(HTTPJSONResponse(withJSON: JSON.null, code: -1, message: ""))
            return
        }
        
        let header = headerWithCookieAndToken()
        let endpoint = nodeEndpoint.appendingFormat("%@.json", requiredGroupID)
        
        self.deleteRequestWithEndpoint(endpoint,
                                       params: nil,
                                       headers: header,
                                       mappingBlock: nil,
                                       successBlock: { (response) -> (Void) in
                                        successBlock(response)
        },
                                       failureBlock: { (response) -> (Void) in
                                        failureBlock(response)
        })
    }
    
    func removeMember(_ member: GroupMember,
                      from group: Group,
                      successBlock: @escaping NetworkJSONSuccessBlock,
                      failureBlock: @escaping NetworkJSONFailureBlock) {
        let header = headerWithCookieAndToken()
        let params = String(format: "%@/%@.json", group.groupID!, member.uid!)
        let endpoint = removeMemberEndpoint.appending(params)
        
        _ = postRequestWithEndpoint(endpoint, params: nil, headers: header, mappingBlock: nil, successBlock: { (response) -> (Void) in
            successBlock(response)
        }, failureBlock: { (response) -> (Void) in
            failureBlock(response)
        })
    }
    
    func removePotentialMember(_ recipient: Recipient,
                               from group: Group,
                               successBlock: @escaping NetworkJSONSuccessBlock,
                               failureBlock: @escaping NetworkJSONFailureBlock) {
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        params["gid"] = group.groupID as AnyObject?
        params["group_type"] = "node" as AnyObject?
        params["recipient_type"] = recipient.recipientType as AnyObject?
        params["recipient_id"] = recipient.recipientID as AnyObject?
        
        _ = postRequestWithEndpoint(unshareEndpoint, params: params, headers: header, mappingBlock: nil, successBlock: { (response) -> (Void) in
            successBlock(response)
        }, failureBlock: { (response) -> (Void) in
            failureBlock(response)
        })
    }
    
    func getGroupMembers(withPaginationQuery paginationQuery: GroupMembersPaginationQuery,
                         successBlock: @escaping NetworkJSONSuccessBlock,
                         failureBlock: @escaping NetworkJSONFailureBlock) -> NetworkRequest? {
        let header = headerWithCookieAndToken()
        let endpoint = String(format: groupMembersEndpoint, paginationQuery.groupID!)
        var params = defaultParams()
        params["page"] = paginationQuery.page as AnyObject?
        params["items_per_page"] = paginationQuery.itemsOnPage as AnyObject?
        
        return self.getRequestWithEndpoint(endpoint, params: params, headers: header,
                                           mappingBlock: ({ (response: URLResponse, json: JSON) -> (MappingResult) in
                                            let limit = json["view"]["pages"].intValue
                                            
                                            if let nodes = json["users"].array {
                                                var members: [GroupMember] = []
                                                
                                                for node in nodes {
                                                    if let member = GroupMember(json: node["user"]) {
                                                        members.append(member)
                                                    }
                                                }
                                                
                                                var pendingMembers: [Recipient] = []
                                                
                                                for pendingUser in json["pending"] {
                                                    if let user = Recipient(json: pendingUser.1) {
                                                        pendingMembers.append(user)
                                                    }
                                                }
                                                
                                                let groupMembersLoadingResponse = GroupMembersLoadingPageResponse(limit: limit,
                                                                                                                  groupMembers: members,
                                                                                                                  pendingMembers: pendingMembers)
                                                
                                                return .success(groupMembersLoadingResponse as AnyObject)
                                            }
                                            
                                            return .failure
                                           }), successBlock: { (response) -> (Void) in
                                            successBlock(response)
        }, failureBlock: { (response) -> (Void) in
            failureBlock(response)
        })
    }
    
    // MARK: - Doximity
    
    func retrieveDoximityUsers(withKeywords keywords: String, withResetValue reset: Bool, successBlock: @escaping NetworkJSONSuccessBlock, failureBlock: @escaping NetworkJSONFailureBlock) {
        let header = headerWithCookieAndToken()
        let userInfo = userManager?.doximityUser
        var params = defaultParams()
        let accessToken = defaults.value(forKey: "DoximityUserAccessToken")
        params["access_token"] = accessToken as AnyObject?
        
        if keywords.isEmpty {
            params["get_all"] = true as AnyObject
        }
        else {
            params["searchterm"] = keywords as AnyObject?
        }
        params["reset"] = reset as AnyObject
        
        _ = postRequestWithEndpoint(doximityRetrieveColleagues, params: params,
                                    headers: header,
                                    mappingBlock: ({ (response: URLResponse, json: JSON) -> (MappingResult) in
                                        let limit = json["total_pages"].intValue
                                        
                                        if let listColleagues = json["items"].array {
                                            var colleagues: [DoximityColleague] = []
                                            
                                            for colleagueJSON in listColleagues {
                                                if let colleague = DoximityColleague(json: colleagueJSON) {
                                                    colleagues.append(colleague)
                                                }
                                            }
                                            
                                            let colleaguesResponse = DoximityColleaguesLoadingPageResponse(limit: limit, colleagues: colleagues)
                                            
                                            return .success(colleaguesResponse as AnyObject)
                                        }
                                        
                                        return .failure
                                    }), successBlock: { (response: HTTPJSONResponse) -> (Void) in
                                        successBlock(response)
        }, failureBlock: { (response: HTTPJSONResponse) -> (Void) in
            failureBlock(response)
        })
    }
}

extension NetworkManager : CaseConnectionProtocol {
    
    fileprivate enum ConnectionStatus: String {
        case on = "1"
        case off = "0"
    }
    
    func caseConnected(_ successBlock: @escaping NetworkJSONSuccessBlock,
                       failureBlock: @escaping NetworkJSONFailureBlock) {
        self.postCaseConnectionStatus(.on, successBlock: successBlock, failureBlock: failureBlock)
    }
    
    func caseDisconnected(_ successBlock: @escaping NetworkJSONSuccessBlock,
                          failureBlock: @escaping NetworkJSONFailureBlock) {
        self.postCaseConnectionStatus(.off, successBlock: successBlock, failureBlock: failureBlock)
    }
    
    fileprivate func postCaseConnectionStatus(_ connectionStatus: ConnectionStatus,
                                              successBlock: @escaping NetworkJSONSuccessBlock,
                                              failureBlock: @escaping NetworkJSONFailureBlock) {
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        params["status"] = connectionStatus.rawValue as AnyObject?
        
        _ = self.postRequestWithEndpoint(caseConnectionEndpoint, params: params, headers: header,
                                         mappingBlock: nil,
                                         successBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            successBlock(response)
                                         }), failureBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            failureBlock(response)
                                         }))
    }
    
    func screenshotWasTaken(_ successBlock: @escaping NetworkJSONSuccessBlock,
                            failureBlock: @escaping NetworkJSONFailureBlock) {
        let params = defaultParams()
        let header = headerWithCookieAndToken()
        
        _ = self.postRequestWithEndpoint(screenshotTakenEndpoint, params: params, headers: header,
                                         mappingBlock: nil,
                                         successBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            successBlock(response)
                                         }), failureBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            failureBlock(response)
                                         }))
    }
    
    func bluetoothConnected(_ successBlock: @escaping NetworkJSONSuccessBlock,
                            failureBlock: @escaping NetworkJSONFailureBlock) {
        self.postBluetoothConnectionStatus(.on, successBlock: successBlock, failureBlock: failureBlock)
    }
    
    func bluetoothDisconnected(_ successBlock: @escaping NetworkJSONSuccessBlock,
                               failureBlock: @escaping NetworkJSONFailureBlock) {
        self.postBluetoothConnectionStatus(.off, successBlock: successBlock, failureBlock: failureBlock)
    }
    
    fileprivate func postBluetoothConnectionStatus(_ connectionStatus: ConnectionStatus,
                                                   successBlock: @escaping NetworkJSONSuccessBlock,
                                                   failureBlock: @escaping NetworkJSONFailureBlock) {
        
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        params["status"] = connectionStatus.rawValue as AnyObject?
        
        _ = self.postRequestWithEndpoint(bluetoothConnectedEndpoint, params: params, headers: header,
                                         mappingBlock: nil,
                                         successBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            successBlock(response)
                                         }), failureBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            failureBlock(response)
                                         }))
    }
    
    // MARK: CaseConnectionProtocol ( Logging )
    func logBluetoothDisconnected(_ log: CaseLog,
                                  successBlock: @escaping NetworkJSONSuccessBlock,
                                  failureBlock: @escaping NetworkJSONFailureBlock) {
        
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        params["status"] = ConnectionStatus.off.rawValue as AnyObject?
        params["timestamp"] = log.actionTimestamp as AnyObject?
        
        if let requiredLoggedGeolocation = log.geolocation {
            params["geolocation"] = requiredLoggedGeolocation as AnyObject?
        }
        
        _ = self.postRequestWithEndpoint(bluetoothConnectedEndpoint, params: params, headers: header,
                                         mappingBlock: nil,
                                         successBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            successBlock(response)
                                         }), failureBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            failureBlock(response)
                                         }))
    }
    
    func logScreenshot(_ log: CaseLog,
                       successBlock: @escaping NetworkJSONSuccessBlock,
                       failureBlock: @escaping NetworkJSONFailureBlock) {
        
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        params["timestamp"] = log.actionTimestamp as AnyObject?
        
        if let requiredLoggedGeolocation = log.geolocation {
            params["geolocation"] = requiredLoggedGeolocation as AnyObject?
        }
        
        _ = self.postRequestWithEndpoint(screenshotTakenEndpoint, params: params, headers: header,
                                         mappingBlock: nil,
                                         successBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            successBlock(response)
                                         }), failureBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            failureBlock(response)
                                         }))
    }
    
    func logCaseDisconnected(_ log: CaseLog,
                             successBlock: @escaping NetworkJSONSuccessBlock,
                             failureBlock: @escaping NetworkJSONFailureBlock) {
        
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        params["status"] = ConnectionStatus.off.rawValue as AnyObject?
        params["timestamp"] = log.actionTimestamp as AnyObject?
        
        if let requiredLoggedGeolocation = log.geolocation {
            params["geolocation"] = requiredLoggedGeolocation as AnyObject?
        }
        
        _ = self.postRequestWithEndpoint(caseConnectionEndpoint, params: params, headers: header,
                                         mappingBlock: nil,
                                         successBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            successBlock(response)
                                         }), failureBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            failureBlock(response)
                                         }))
    }
}

extension NetworkManager : PushNotificationProtocol {
    
    func registerDeviceToken(deviceTokenString: String,
                             successBlock: @escaping NetworkJSONSuccessBlock,
                             failureBlock: @escaping NetworkJSONFailureBlock) {
        var params = defaultParams()
        params["type"] = "ios" as AnyObject?
        params["token"] = deviceTokenString as AnyObject?
        
        let header = headerWithCookieAndToken()
        
        _ = self.postRequestWithEndpoint(pushNotificationEndpoint, params: params, headers: header,
                                         mappingBlock: nil,
                                         successBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            successBlock(response)
                                         }), failureBlock: ({ (response: HTTPJSONResponse) -> (Void) in
                                            failureBlock(response)
                                         }))
    }
    
    func deRegisterDeviceToken(deviceTokenString: String, successBlock: @escaping NetworkJSONSuccessBlock, failureBlock: @escaping NetworkJSONFailureBlock) {
        let endpoint = deRegisterDeviceTokenEndPoint.appendingFormat("%@.json",deviceTokenString)
        let header = headerWithCookieAndToken()
        _ = self.deleteRequestWithEndpoint(endpoint, params: nil, headers: header, mappingBlock: nil, successBlock: { (response: HTTPJSONResponse) -> (Void) in
            successBlock(response)
            
        }, failureBlock: { (arg0) -> (Void) in
            
            let (response) = arg0
            failureBlock(response)
            
        })
    }
}

extension NetworkManager : InviteUsersProtocol {
    
    func inviteUsers(byPhones phones: [String],
                     successBlock: @escaping NetworkJSONSuccessBlock,
                     failureBlock: @escaping NetworkJSONFailureBlock) {
        
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        params["type"] = "invite_by_sms" as AnyObject?
        
        var recipients: [[String: String]] = []
        
        phones.forEach { (currentPhone) in
            
            let recipientObject = [
                "recipient_type" : "phone",
                "recipient_id": currentPhone
            ]
            recipients.append(recipientObject)
        }
        
        params["recipients"] = recipients as AnyObject?
        
        self.postRequestWithEndpoint(inviteMultipleUserEndpoint,
                                     params: params,
                                     headers: header,
                                     encoding: JSONEncoding.default,
                                     mappingBlock: nil,
                                     successBlock: { (response) -> () in
                                        successBlock(response)
        },
                                     failureBlock: { (response) -> () in
                                        
                                        guard let errorMessage = response.json["form_errors"]["field_phone"].string
                                            else {
                                                failureBlock(response)
                                                return
                                        }
                                        
                                        failureBlock(HTTPJSONResponse(withJSON: response.json, code: response.code, message: errorMessage))
        })
    }
    
    func inviteUsers(byEmails emails: [String],
                     successBlock: @escaping NetworkJSONSuccessBlock,
                     failureBlock: @escaping NetworkJSONFailureBlock) {
        
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        params["type"] = "invite_by_email" as AnyObject?
        
        var recipients: [[String: String]] = []
        
        emails.forEach { (currentEmail) in
            
            let recipientObject = [
                "recipient_type" : "email",
                "recipient_id": currentEmail
            ]
            recipients.append(recipientObject)
        }
        
        params["recipients"] = recipients as AnyObject?
        
        self.postRequestWithEndpoint(inviteMultipleUserEndpoint,
                                     params: params,
                                     headers: header,
                                     encoding: JSONEncoding.default,
                                     mappingBlock: nil,
                                     successBlock: { (response) -> () in
                                        successBlock(response)
        },
                                     failureBlock: { (response) -> () in
                                        
                                        guard let errorMessage = response.json["form_errors"]["field_phone"].string
                                            else {
                                                failureBlock(response)
                                                return
                                        }
                                        
                                        failureBlock(HTTPJSONResponse(withJSON: response.json, code: response.code, message: errorMessage))
        })
    }
    
    func inviteUser(byEmail email: String,
                    successBlock: @escaping NetworkJSONSuccessBlock,
                    failureBlock: @escaping NetworkJSONFailureBlock) {
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        params["type"] = "invite_by_email" as AnyObject?
        params["field_invitation_email_address"] = ["und" : [[
            "value": email]]] as AnyObject?
        
        _ = self.postRequestWithEndpoint(inviteUserEndpoint, params: params, headers: header, mappingBlock: nil, successBlock: { (response: HTTPJSONResponse) -> (Void) in
            successBlock(response)
        }, failureBlock: { (response: HTTPJSONResponse) -> (Void) in
            guard let errorMessage = response.json["form_errors"]["field_invitation_email_address"].string else {
                failureBlock(response)
                
                return
            }
            
            failureBlock(HTTPJSONResponse(withJSON: response.json, code: response.code, message: errorMessage))
        })
    }
    
    func inviteUser(byText text: String,
                    successBlock: @escaping NetworkJSONSuccessBlock,
                    failureBlock: @escaping NetworkJSONFailureBlock) {
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        params["type"] = "invite_by_sms" as AnyObject?
        params["field_phone"] = ["und" : [[
            "value": text]]] as AnyObject?
        
        _ = self.postRequestWithEndpoint(inviteUserEndpoint, params: params, headers: header, mappingBlock: nil, successBlock: { (response: HTTPJSONResponse) -> (Void) in
            successBlock(response)
        }, failureBlock: { (response: HTTPJSONResponse) -> (Void) in
            guard let errorMessage = response.json["form_errors"]["field_phone"].string else {
                failureBlock(response)
                
                return
            }
            
            failureBlock(HTTPJSONResponse(withJSON: response.json, code: response.code, message: errorMessage))
        })
    }
    
    func inviteUserInDoximity(){
        let user = self.userManager?.retriveProfile()!
        let userName = (((user!.username) != nil) && (user!.username?.count)! > 0) ? ((user!.username)! + " has ") : "You have "
        let message = userName + "invited you to join PrivateEye. Download the app to sign up and start sharing images: "
        let url = "https://itunes.apple.com/us/app/privateeyehc/id1305657833"
        let subject = "PrivateEye Invitation!"
        
        let encodedMessage = "&message=" + message.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let encodedURL = "url=" + url.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let encodedSubject = "&subject=" + subject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let params = encodedURL+encodedMessage+encodedSubject
        let urlString = "https://www.doximity.com/inbox/conversations/new_message?"+params
        if let link = URL(string: urlString) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(link)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(link)
            }
        }
    }
}

extension NetworkManager: CommentsNetworkProtocol {
    func getComments(withQuery paginationQuery: CommentsPaginationQuery,
                     successBlock: @escaping NetworkJSONSuccessBlock,
                     failureBlock: @escaping NetworkJSONFailureBlock) -> NetworkRequest? {
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        params["nid"] = paginationQuery.nodeID as AnyObject?
        params["sort_order"] = "DESC" as AnyObject?
        params["sort_by"] = "created" as AnyObject?
        
        params["page"] = paginationQuery.page as AnyObject?
        params["items_per_page"] = paginationQuery.ItemsOnPageDefault as AnyObject?
        
        return getRequestWithEndpoint(fetchCommentsEndpoint, params: params, headers: header, mappingBlock: { (response, json) -> MappingResult in
            guard let limit = json["view"]["pages"].int, let deleteOwnComments = json["view"]["permissions"]["delete own comments"].bool else { return .failure }
            
            if let listComments = json["comments"].arrayObject {
                var comments: [Comment] = []
                
                for item in listComments {
                    if let subJSON = JSON(item)["comment"].dictionary {
                        if let comment = Comment(json: JSON(subJSON)) {
                            comments.append(comment)
                        }
                    }
                }
                
                let commentLoadingResponse = CommentLoadingPageResponse(limit: limit, comments: comments, canDeleteComments: deleteOwnComments)
                
                return .success(commentLoadingResponse as AnyObject)
            }
            
            return .failure
        }, successBlock: { (response) -> (Void) in
            successBlock(response)
        }, failureBlock: { (response) -> (Void) in
            failureBlock(response)
        })
    }
    
    func postComment(_ commentValue: String,
                     forNodeID nodeID: String?,
                     folderID: String?,
                     successBlock: @escaping NetworkJSONSuccessBlock,
                     failureBlock: @escaping NetworkJSONFailureBlock) {
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        params["nid"] = nodeID as AnyObject?
        params["comment_body"] = ["und" : [["value": commentValue]],
                                  "field_folder": ["und": [folderID]]] as AnyObject?
        
        _ = postRequestWithEndpoint(commentsEndpoint, params: params, headers: header, mappingBlock: nil, successBlock: { (response) -> (Void) in
            successBlock(response)
        }) { (response) -> (Void) in
            failureBlock(response)
        }
    }
    
    func newCommentsCount(forNodeID nodeID: String?,
                          successBlock: @escaping NetworkJSONSuccessBlock,
                          failureBlock: @escaping NetworkJSONFailureBlock) {
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        params["nid"] = nodeID as AnyObject?
        
        _ = postRequestWithEndpoint(newCommentsEndpoint, params: params, headers: header, mappingBlock: { (response, json) -> MappingResult in
            if let count = json.array?.first?.string {
                return .success(Int(count) as AnyObject)
            }
            
            return .failure
        }, successBlock: { (response) -> (Void) in
            successBlock(response)
        }, failureBlock: { (response) -> (Void) in
            failureBlock(response)
        })
    }
    
    func removeComments(_ comments: [Comment],
                        successBlock: @escaping NetworkJSONSuccessBlock,
                        failureBlock: @escaping NetworkJSONFailureBlock) {
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        params["cids"] = comments.map({ (comment) -> String? in
            return comment.id
        }) as AnyObject?
        
        _ = postRequestWithEndpoint(removeCommentsEndpoint, params: params, headers: header, mappingBlock: nil, successBlock: { (response) -> (Void) in
            successBlock(response)
        }, failureBlock: { (response) -> (Void) in
            failureBlock(response)
        })
    }
}

extension NetworkManager: NotificationsNetworkProtocol {
    
    func getNotificationHistory(query: PaginationQuery,
                                successBlock: @escaping NetworkJSONSuccessBlock,
                                failureBlock: @escaping NetworkJSONFailureBlock) {
        
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        params["page"] = query.page as AnyObject?
        
        self.getRequestWithEndpoint(notificationsHistoryEndpoint,
                                    params: params,
                                    headers: header,
                                    mappingBlock: { (response, responseJSON) in
                                        
                                        guard let requiredMessagesArray = responseJSON["messages"].array else { return .failure }
                                        var messages: [NotificationHistoryItem] = []
                                        
                                        for json in requiredMessagesArray {
                                            
                                            if let item = NotificationHistoryItem(json: json["message"]) {
                                                messages.append(item)
                                            }
                                        }
                                        
                                        return .success(messages as AnyObject)
        },
                                    successBlock: { response in
                                        successBlock(response)
        },
                                    failureBlock: { response in
                                        
                                        failureBlock(response)
        })
    }
    
    func getNotificationSettings(query: PaginationQuery, successBlock: @escaping NetworkJSONSuccessBlock, failureBlock: @escaping NetworkJSONFailureBlock) {
        let header = headerWithCookieAndToken()
        self.getRequestWithEndpoint(notificationSettingsEndpoint, params: nil, headers: header, mappingBlock: { (response, responseJSON) -> MappingResult in
            print(responseJSON)
            guard let requiredMessagesArray = responseJSON["message_types"].array else { return .failure }
            var messages: [NotificationSettingsItemViewModel] = []
            
            for json in requiredMessagesArray {
                if let item = NotificationSettingsItemViewModel(json: json["message_type"]) {
                    messages.append(item)
                }
            }
            return .success(messages as AnyObject)
            
        }, successBlock: { response in
            successBlock(response)
        },
           failureBlock: { response in
            
            failureBlock(response)
        })
        
    }
    
    func postNotificationSettingType(with messageType: String, subscribed: Bool, successBlock: @escaping NetworkJSONSuccessBlock, failureBlock: @escaping NetworkJSONFailureBlock) {
        let header = headerWithCookieAndToken()
        var params = defaultParams()
        params["message_type"] = messageType as AnyObject
        params["action"] = subscribed ? "subscribe" as AnyObject : "unsubscribe" as AnyObject
        _ = postRequestWithEndpoint(notificationSettingsActionEndpoint, params: params, headers: header, mappingBlock: { (response: URLResponse, json: JSON) -> MappingResult in
            return .success(json as AnyObject)
            
        }, successBlock: ({ (response: HTTPJSONResponse) -> (Void) in
            successBlock(response)
        }),
           failureBlock: ({ (response: HTTPJSONResponse) -> (Void) in
            failureBlock(response)
           }))
    }
    
}
extension UIViewController {
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}
