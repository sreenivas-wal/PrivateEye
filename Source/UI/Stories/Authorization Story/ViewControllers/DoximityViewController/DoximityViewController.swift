//
//  DoximityViewController.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 1/30/18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit

class DoximityViewController: BaseViewController, WebViewControllerDelegate,VerificationInfoWebViewControllerDelegate,ProvideVerificationInfoDelegate {
    
    
    weak var router: AuthorizationPrivateRoutingProtocol?
    weak var photosRouter: PhotosRouterProtocol?
    var networkManager: AuthorizationNetworkProtocol?
    var alertsManager: AlertsManagerProtocol?
    var userManager: SessionUserProtocol!
    var authorizationModel: AuthorizationModel?
    var duringSignUp:Bool?
    fileprivate var currentWebViewController: WebViewController?
    fileprivate var currentVerificationWebViewController: VerificationInfoWebViewController?
    
    // MARK: -
    // MARK: Public
    func startDoximityLogin() {
        let webVC = WebViewController()
        webVC.delegate = self
        self.currentWebViewController = webVC
        let navigationController = UINavigationController(rootViewController: webVC)
        present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: -
    // MARK: WebViewControllerDelegate
    func webViewController(_ sender: WebViewController, didRedirectFromDoximityWithCode code: String) {
        self.loadDoximityUser(withCode: code)
    }
    
    func webViewController(_ sender: WebViewController, doneButtonTapped button: UIButton) {
        
    }
    
    func verificationInfoWebViewController(_ sender: VerificationInfoWebViewController, doneButtonTapped button: UIButton) {
        if duringSignUp! {
            router?.showVerificationInfoAlertViewController(fromViewController: self, withDelegate: self, withAnimation: true)
        } else {
            popNavigationController()
        }
    }
    
    func verificationInfoWebViewController(_ sender: VerificationInfoWebViewController, didRedirectFromVerificationFormWithmessage message: String) {
        if duringSignUp! {
            self.userManager.currentUser?.userRole = "in_progress"
            self.router?.showPhotosViewController(fromViewController: self, withAnimation: true)
        } else {
            self.userManager.currentUser?.userRole = "in_progress"
            popNavigationController()
        }
    }
    
    func provideVerificationForm() {
        let verificationWebVC = VerificationInfoWebViewController()
        verificationWebVC.alertManager = self.alertsManager
        verificationWebVC.delegate = self
        verificationWebVC.userManager = self.userManager as? UserManager
        self.currentVerificationWebViewController = verificationWebVC
        let nc = UINavigationController(rootViewController: verificationWebVC)
        present(nc, animated: true, completion: nil)
    }
    
    func provideVerificationInfoAlertController(_ sender: ProvideVerificationInfoAlertController) {
        provideVerificationForm()
    }
    
    
    func popNavigationController() {
        self.navigationController?.popViewController(animated: false)
    }
    
    
    // MARK: -
    // MARK: Private
    fileprivate func showDoximityVerificationAlertController() {
        
        guard let requiredWebViewController = self.currentWebViewController else { return }
        self.alertsManager?.showDoximityVerificationAlertController(
            forViewController: requiredWebViewController,
            withOkayCallback: { () -> () in
                
                self.dismiss(animated: true, completion: nil)
                self.router?.showLogInViewController(fromViewController: self, withAimation: true)
        })
    }
    
    fileprivate func loadDoximityUser(withCode code: String) {
        
        view.isUserInteractionEnabled = false
        networkManager?.doximityAccessToken(withCode: code,
                                            phoneNumber: nil,
                                            successBlock: { [weak self] (response) -> (Void) in
                                                
                                                DispatchQueue.main.async {
                                                    
                                                    guard let strongSelf = self else { return }
                                                    
                                                    strongSelf.view.isUserInteractionEnabled = true
                                                    guard let accessToken = (response.json["access_token"]).string else { return }
                                                    
                                                    strongSelf.loadProfile(with: accessToken)
                                                }
            },
                                            failureBlock: { [weak self] (response) -> (Void) in
                                                
                                                DispatchQueue.main.async {
                                                    
                                                    guard let strongSelf = self,
                                                        let requiredWebViewController = strongSelf.currentWebViewController
                                                        else { return }
                                                    
                                                    strongSelf.view.isUserInteractionEnabled = true
                                                    strongSelf.alertsManager?.showErrorAlert(forViewController: requiredWebViewController,
                                                                                             withMessage: response.message)
                                                }
        })
    }
    
    fileprivate func loadProfile(with accessToken: String) {
        
        view.isUserInteractionEnabled = false
        
        networkManager?.doximityLogin(withAccessToken: accessToken,
                                      successBlock: { [weak self] (response) -> () in
                                        
                                        DispatchQueue.main.async {
                                            
                                            guard let strongSelf = self,
                                                let requiredLoginResult = response.object as? DoximityLoginResult
                                                else { return }
                                            strongSelf.view.isUserInteractionEnabled = true
                                            
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
                                                
                                                strongSelf.dismiss(animated: true, completion: {
                                                    strongSelf.router?.showPhotosViewController(fromViewController: strongSelf, withAnimation: true)
                                                })
                                            } else {
                                                strongSelf.showDoximityVerificationAlertController()
                                            }
                                        }
            },
                                      failureBlock: { [weak self] (response) -> () in
                                        
                                        DispatchQueue.main.async {
                                            
                                            guard let strongSelf = self,
                                                let requiredWebViewController = strongSelf.currentWebViewController
                                                else { return }
                                            
                                            strongSelf.view.isUserInteractionEnabled = true
                                            if response.code == 406 {
                                                let message = (response.json[0]).string
                                                let errorMessage = (message?.html2Attributed)?.string
                                                strongSelf.alertsManager?.showErrorAlert(forViewController: requiredWebViewController,
                                                                                         withMessage: errorMessage!)
                                            } else {
                                                strongSelf.alertsManager?.showErrorAlert(forViewController: requiredWebViewController,
                                                                                         withMessage: response.message)
                                            }
                                        }
        })
    }
}
