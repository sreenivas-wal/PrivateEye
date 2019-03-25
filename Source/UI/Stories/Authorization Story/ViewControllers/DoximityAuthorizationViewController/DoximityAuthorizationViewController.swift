//
//  DoximityAuthorizationViewController.swift
//  MyMobileED
//
//  Created by Created by Admin on 03.06.18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation

enum DoximityAuthorizationType {
    
    case doximityTokenUpdate
    case fullAuthorization
}

class DoximityAuthorizationViewController: UIViewController, WebViewControllerDelegate {
    
    typealias DoximityUserLoadingCompletionBlock = (_ result: DoximityUserLoadingResult) -> ()
    typealias DoximityProfileLoadingCompletionBlock = (_ result: DoximityProfileLoadingResult) -> ()
    
    enum DoximityUserLoadingResult {
        
        case success(withAccessToken: String)
        case failure(error: DoximityAuthorizationFailureResult)
    }
    
    enum DoximityProfileLoadingResult {
        
        case success
        case failure(error: DoximityAuthorizationFailureResult)
    }
    
    // MARK: -
    // MARK: Properties
    weak var router: AuthorizationRouterProtocol?
    var networkManager: AuthorizationNetworkProtocol?
    var userManager: SessionUserProtocol!
    var alertsManager: AlertsManagerProtocol?
    var doximityAuthorizationType: DoximityAuthorizationType!
    var authorizationResultBlock: DoximityAuthorizationResultBlock?
    
    fileprivate var currentWebViewController: WebViewController?
    
    // MARK: -
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            
            switch self.doximityAuthorizationType! {
            case .doximityTokenUpdate:
                self.showAuthorizationAlert()
            case .fullAuthorization:
                self.startDoximityLogin()
            }
        }
    }
    
    // MARK: -
    // MARK: WebViewControllerDelegate
    func webViewController(_ sender: WebViewController, didRedirectFromDoximityWithCode code: String) {
        
        switch self.doximityAuthorizationType! {
        case .doximityTokenUpdate:
            self.doDoximityTokenUpdate(withCode: code)
        case .fullAuthorization:
            self.doFullAuthorization(withCode: code)
        }
    }
    
    func webViewController(_ sender: WebViewController, doneButtonTapped button: UIButton) {
        self.finishAuthorization(with: .failure(error: .userCancelation))
    }
    
    // MARK: -
    // MARK: Private ( Start / Finish )
    fileprivate func startDoximityLogin() {
        let webVC = WebViewController()
        webVC.delegate = self
        self.currentWebViewController = webVC
        
        let navigationController = UINavigationController(rootViewController: webVC)
        present(navigationController, animated: true, completion: nil)
    }
    
    fileprivate func finishAuthorization(with result: DoximityAuthorizationResult) {
        
        guard let requiredAuthorizationResultBlock = authorizationResultBlock else {
            print("DoximityViewController | authorization cannot be finished -> DoximityAuthorizationResultBlock == nil ")
            return
        }
        
        requiredAuthorizationResultBlock(result)
        self.authorizationResultBlock = nil
        
        if let requiredWebViewController = self.currentWebViewController {
            
            requiredWebViewController.dismiss(animated: true, completion: nil)
            self.currentWebViewController = nil
        }
        
        self.dismiss(animated: false, completion: nil)
    }
    
    // MARK: -
    // MARK: Private ( Authorization Flow )
    fileprivate func doDoximityTokenUpdate(withCode code: String) {
        
        self.performDoximityUserLoading(with: code, completionBlock: { [weak self] (userLoadingResult) in
            
            guard let strongSelf = self else { return }
            
            switch userLoadingResult {
            case .success(let accessToken):
                strongSelf.performDoximityProfileLoading(with: accessToken,
                                                         completionBlock: { (profileLoadingResult) in
                                                            
                                                            switch profileLoadingResult {
                                                            case .success:
                                                                strongSelf.finishAuthorization(with: .success)
                                                            case.failure(let failureResult):
                                                                strongSelf.processAuthorizationFailure(with: failureResult)
                                                            }
                })
                
            case .failure(let failureResult):
                strongSelf.processAuthorizationFailure(with: failureResult)
            }
        })
    }
    
    fileprivate func doFullAuthorization(withCode code: String) {
        
        self.performDoximityUserLoading(with: code, completionBlock: { [weak self] (userLoadingResult) in
            
            guard let strongSelf = self else { return }
            
            switch userLoadingResult {
            case .success(let accessToken):
                strongSelf.performDoximityProfileLoading(with: accessToken,
                                                         completionBlock: { (profileLoadingResult) in
                                                            
                                                            switch profileLoadingResult {
                                                            case .success:
                                                                strongSelf.finishAuthorization(with: .success)
                                                            case.failure(let failureResult):
                                                                strongSelf.processAuthorizationFailure(with: failureResult)
                                                            }
                })
                
            case .failure(let failureResult):
                strongSelf.processAuthorizationFailure(with: failureResult)
            }
        })
    }
    
    fileprivate func processAuthorizationFailure(with result: DoximityAuthorizationFailureResult) {
        
        switch result {
        case .doximityNotVerified:
            self.showDoximityVerificationAlertController()
            
        case .userCancelation:
            self.finishAuthorization(with: .failure(error: .userCancelation))
            
        case .unauthorized(let reason):
            self.showErrorConnectionAlert(with: reason)
        }
    }
    
    // MARK: -
    // MARK: Private ( Loading )
    fileprivate func performDoximityUserLoading(with code: String, completionBlock: @escaping DoximityUserLoadingCompletionBlock) {
        
        view.isUserInteractionEnabled = false
        networkManager?.doximityAccessToken(withCode: code,
                                            phoneNumber: nil,
                                            successBlock: { [weak self] (response) -> (Void) in
                                                
                                                DispatchQueue.main.async {
                                                    guard let accessToken = (response.json["access_token"]).string else { return }
                                                    UserDefaults.standard.set(accessToken, forKey: "DoximityUserAccessToken")
                                                    guard let strongSelf = self else {
                                                        completionBlock(.failure(error: .unauthorized(reason: "DoximityAuthorizationViewController | dealocated")))
                                                        return
                                                    }
                                                    
                                                    strongSelf.view.isUserInteractionEnabled = true
                                                    completionBlock(.success(withAccessToken: accessToken))
                                                }
            },
                                            failureBlock: { [weak self] (response) -> (Void) in
                                                
                                                DispatchQueue.main.async {
                                                    
                                                    guard let strongSelf = self else {
                                                        completionBlock(.failure(error: .unauthorized(reason: "")))
                                                        return
                                                    }
                                                    
                                                    strongSelf.view.isUserInteractionEnabled = true
                                                    completionBlock(.failure(error: .unauthorized(reason: response.message)))
                                                }
        })
    }
    
    fileprivate func performDoximityProfileLoading(with accessToken: String,
                                                   completionBlock: @escaping DoximityProfileLoadingCompletionBlock) {
        
        view.isUserInteractionEnabled = false
        
        networkManager?.doximityLogin(withAccessToken: accessToken,
                                      successBlock: { [weak self] (response) -> () in
                                        
                                        DispatchQueue.main.async {
                                            
                                            guard let strongSelf = self else {
                                                completionBlock(.failure(error: .unauthorized(reason: "DoximityAuthorizationViewController | dealocated")))
                                                return
                                            }
                                            
                                            strongSelf.view.isUserInteractionEnabled = true
                                            
                                            guard let requiredLoginResult = response.object as? DoximityLoginResult
                                                else {
                                                    completionBlock(.failure(error: .unauthorized(reason: "DoximityAuthorizationViewController | DoximityLoginResult invalid")))
                                                    return
                                            }
                                            var isVerified = true
                                            
                                            if FeatureFlags.shouldCheckDoximityAccountAsVerified {
                                                isVerified = (response.json["verified"]).bool!
                                            }
                                            if isVerified {
                                                if let requiredDoximityTokenResult = response.object as? DoximityAccessTokenResult {
                                                    strongSelf.userManager.saveDoximityUserInfo(requiredDoximityTokenResult.doximityUser)
                                                }
                                                strongSelf.userManager.saveUserInfo(requiredLoginResult.user)
                                                if let requiredProfile = requiredLoginResult.profile {
                                                    strongSelf.userManager.saveProfile(requiredProfile)
                                                }
                                                
                                                completionBlock(.success)
                                            } else {
                                                completionBlock(.failure(error: .doximityNotVerified))
                                            }
                                        }
            },
                                      failureBlock: { [weak self] (response) -> () in
                                        
                                        DispatchQueue.main.async {
                                            guard let strongSelf = self,
                                                let requiredWebViewController = strongSelf.currentWebViewController
                                                else { return }
                                            
                                            if response.code == 406 {
                                                let message = (response.json[0]).string
                                                let errorMessage = (message?.html2Attributed)?.string
                                                strongSelf.alertsManager?.showErrorAlert(forViewController: requiredWebViewController,
                                                                                         withMessage: errorMessage!)
                                            } else {
                                                strongSelf.alertsManager?.showErrorAlert(forViewController: requiredWebViewController,
                                                                                         withMessage: response.message)
                                            }
                                            
                                            strongSelf.view.isUserInteractionEnabled = true
                                        }
        })
    }
    
    // MARK: -
    // MARK: Private ( Alert )
    fileprivate func showAuthorizationAlert() {
        
        let alertController = UIAlertController(title: "",
                                                message: "You have been logged out from Doximity. Please log in to proceed.",
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] (action) in
            
            guard let strongSelf = self else { return }
            alertController.dismiss(animated: false, completion: nil)
            strongSelf.startDoximityLogin()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { [weak self] (action) in
            
            guard let strongSelf = self else { return }
            alertController.dismiss(animated: false, completion: nil)
            strongSelf.finishAuthorization(with: .failure(error: .userCancelation))
        }))
        
        self.present(alertController, animated: false, completion: nil)
    }
    
    fileprivate func showDoximityVerificationAlertController() {
        
        guard let requiredWebViewController = self.currentWebViewController else { return }
        
        let doximityAlert = UIAlertController(title: "Verify your doximity account",
                                              message: "Please complete the doximity verification process before linking your account to PrivateEye.",
                                              preferredStyle: .alert)
        
        doximityAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { [weak self] (action) in
            
            guard let strongSelf = self else { return }
            strongSelf.finishAuthorization(with: .failure(error: .doximityNotVerified))
        }))
        
        requiredWebViewController.present(doximityAlert, animated: true, completion: nil)
    }
    
    fileprivate func showErrorConnectionAlert(with message: String) {
        
        guard let requiredWebViewController = self.currentWebViewController else { return }
        
        let errorAlert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] (action) in
            
            guard let strongSelf = self else { return }
            strongSelf.finishAuthorization(with: .failure(error: .unauthorized(reason: message)))
        }))
        
        requiredWebViewController.present(errorAlert, animated: true, completion: nil)
    }
}

