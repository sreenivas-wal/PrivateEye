//
//  NetworkManager.swift
//  MyMobileED
//
//  Created by Admin on 1/13/17.
//
//

import Foundation
import Alamofire
import SwiftyJSON

class NetworkManager: NetworkConnectionProtocol{
 
    var manager: SessionManager!
    var userManager: SessionUserProtocol?
    var locationService: LocationServiceProtocol?
    var bluetoothManager: BluetoothManagerProtocol?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    init() {
        self.manager = SessionManager.default
        self.manager.startRequestsImmediately = false
    }
    
    // MARK: NetworkConnectionProtocol

    func baseUrl() -> String {
        let baseUrl = Hostname.defaultHostname().fullHostDomainLink()
        
        return userManager?.hostname?.fullHostDomainLink() ?? baseUrl
    }
    
    func defaultHeaderFields() -> [String : String] {
        return ["X-CSRF-Token" : ""]
    }
    
    func defaultParams() -> [String : AnyObject] {
        if let currentLocation = locationService?.currentLocation() {
            let location = String.init(format: "%f, %f", currentLocation.latitude, currentLocation.longitude) as AnyObject?
            return ["geolocation" : location!]
        }
        
        return [String : AnyObject]()
    }
    
    func headerWithCookie() -> [String : String] {
        let userInfo = userManager?.currentUser
        var header = defaultHeaderFields()
        
        if let sessionID = userInfo?.sessionID {
            header["cookie"] = userInfo!.sessionName!.appendingFormat("=%@", sessionID)
        }
        
        return header
    }
    
    func headerWithCookieAndToken() -> [String : String] {
        let userInfo = userManager?.currentUser
        var header = headerWithCookie()
        
        if let token = userInfo?.token {
            header["X-CSRF-Token"] = token
        }
        
        return header
    }
    
    func clearAllCookie() {
        
        guard let requiredURL = URL(string: self.baseUrl()) else { return }
        
        let storage = HTTPCookieStorage.shared
        if let cookies = storage.cookies(for: requiredURL) {
            for cookie in cookies {
                storage.deleteCookie(cookie)
            }
        }
    }
    
    func executeRequest(_ request: URLRequest,
                        mappingBlock: NetworkJSONMappingBlock?,
                        successBlock: @escaping NetworkJSONSuccessBlock,
                        failureBlock: @escaping NetworkJSONFailureBlock) -> NetworkRequest {
        let dataRequest: DataRequest = manager.request(request)
        let networkRequest = NetworkRequest()
        networkRequest.dataRequest = dataRequest
        
        dataRequest.resume()
        dataRequest.validate().response { (dataResponse: DefaultDataResponse) in
            let request: URLRequest? = dataResponse.request
            let response: HTTPURLResponse? = dataResponse.response
            let data: Data? = dataResponse.data
            let error: Error? = dataResponse.error
            
            
            if response?.statusCode == 401 {
                self.logOut(bluetoothManager: self.bluetoothManager!)
            }
            guard error == nil else {
                
                print("ERROR: Error object in response: \(error)")
                var errorCode = -1
                
                if let validErrorData = data {
                    let json = JSON(data: validErrorData)
                    
                    if let requiredServerSideCode = json["form_errors"]["code"].int {
                        errorCode = requiredServerSideCode
                    }
                    else {
                        errorCode = response?.statusCode ?? 0
                    }
                    
                    failureBlock(HTTPJSONResponse(withJSON: json, code: errorCode, message: (error?.localizedDescription)!))
                    
                    return
                }
                
                failureBlock(HTTPJSONResponse(withJSON: JSON.null, code: -1, message: (error?.localizedDescription)!))
                
                return
            }
            
            guard let validResponse = response else {
                print("ERROR: Response is not valid")
                failureBlock(HTTPJSONResponse(withJSON: JSON.null, code: -1, message: ""))
                return
            }
            
            let JSONSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let serializationResult = JSONSerializer.serializeResponse(request, response, data, error)
            
            switch serializationResult {
            case .success(let representation):
                let jsonRepresentation = JSON(representation)
                
                guard var mappedResponse: HTTPJSONResponse = HTTPJSONResponse(withJSON: jsonRepresentation, code: 0, message: "") else {
                    print("ERROR: Can't map HTTPJSONResponse object")
                    failureBlock(HTTPJSONResponse(withJSON: JSON.null, code: -1, message: ""))
                    return
                }
                
                if let validMappingBlock = mappingBlock {
                    let mappingResult: MappingResult = validMappingBlock(validResponse, mappedResponse.json)
                    
                    switch mappingResult {
                    case .failure:
                        print("Error: Can't map objecty")
                        failureBlock(mappedResponse)
                    case .success(let mappedObject):
                        mappedResponse.object = mappedObject
                        successBlock(mappedResponse)
                    }
                }
                else {
                    successBlock(mappedResponse)
                }
            case .failure:
                print("ERROR: Error in JSON serialization")
                if(response?.statusCode == 200){
                    successBlock(HTTPJSONResponse(withJSON: JSON.null, code: 200, message: ""))
                }
            }
        }
        
        return networkRequest
    }
    
    func logOut(bluetoothManager: BluetoothManagerProtocol) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let vc = appDelegate.window?.rootViewController?.childViewControllers.first!
        
        let sv = UIViewController.displaySpinner(onView: (vc?.view)!)
        
        let deviceToken = UserDefaults.standard.data(forKey: "DeviceToken")
        if deviceToken != nil {
            let deviceTokenString = self.convertDeviceTokenData(dataDeviceToken: deviceToken!)
            if deviceTokenString != nil && (deviceTokenString.count) > 0{
                self.deRegisterDeviceToken(deviceTokenString: deviceTokenString, successBlock: { (response) -> (Void) in
                    print("The token was successfully removed ")
                    self.logOut(successBlock: { (response) -> (Void) in
                        print(" successfully logged out ")
                        self.clearData(sv: sv, vc: vc!)
                    }, failureBlock: { (error) -> (Void) in
                        UIViewController.removeSpinner(spinner: sv)
                        vc?.view?.isUserInteractionEnabled = true
                        self.clearData(sv: sv, vc: vc!)
                        self.presentAlert(withMessage: error.message, vc: vc!)
                    })
                }, failureBlock: { (error) -> (Void) in
                    UIViewController.removeSpinner(spinner: sv)
                    self.clearData(sv: sv, vc: vc!)
                    self.presentAlert(withMessage: error.message, vc: vc!)
                    print("\(error)")
                })
            }
        }
        
    }
    
    func presentAlert(withMessage message: String,vc:UIViewController) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction)
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    func clearData(sv:UIView, vc:UIViewController) {
        self.bluetoothManager?.disconnectIfNeeded()
        DispatchQueue.main.async {
            self.userManager?.clearUserInfo()
            defaults.removeObject(forKey: "DoximityUserAccessToken")
            self.appDelegate.applicationRouter?.showSignOutViewController(fromViewController: vc, withAnimation: true)
            UIViewController.removeSpinner(spinner: sv)
        }
    }
    
    func convertDeviceTokenData(dataDeviceToken: Data) -> String {
        var token = ""
        
        for i in 0..<dataDeviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [(dataDeviceToken[i])])
        }
        
        print("Device token = \(token)")
        
        return token
    }
    
}
