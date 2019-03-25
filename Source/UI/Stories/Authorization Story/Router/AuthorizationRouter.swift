//
//  AuthorizationRouter.swift
//  MyMobileED
//
//  Created by Admin on 1/16/17.
//
//

import UIKit

protocol AuthorizationRouterDelegate: class {
    func showPhotosStory(fromViewController viewController: UIViewController, withAnimation animated: Bool)
}

class AuthorizationRouter: BaseRouter, AuthorizationRouterProtocol, AuthorizationPrivateRoutingProtocol {
   
    var delegate: AuthorizationRouterDelegate?
    var loginViewController: LogInViewController?
    var authorizationNavigationController: UINavigationController!
    
    // MARK: -
    // MARK: AuthorizationRouterProtocol
    func initialViewController() -> UIViewController {
        let logInVC = scenesAssembly?.instantiateLogInViewController(self)
        let navigationController = UINavigationController(rootViewController: logInVC!)
        navigationController.isNavigationBarHidden = true
        
        loginViewController = logInVC
        authorizationNavigationController = navigationController
        
        return navigationController
    }
    
    func showLogInViewController(fromViewController viewController: UIViewController?, withAimation animated: Bool) {
        let vc = scenesAssembly?.instantiateLogInViewController(self)
        
        if let requiredAuthorizationNavigationController = authorizationNavigationController {
            requiredAuthorizationNavigationController.viewControllers = [vc!]
        }
        else {
            let navigationController = UINavigationController(rootViewController: vc!)
            navigationController.isNavigationBarHidden = true
            authorizationNavigationController = navigationController
            viewController?.present(navigationController, animated: animated, completion: nil)
        }
        
        loginViewController = vc
    }
    
    func showCaseSelectionViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool) {
        let viewControllerToShow = scenesAssembly?.instantiateCaseSelectionViewController(self)
        viewController.present(viewControllerToShow!, animated: animated, completion: nil)
    }
    
    func showDoximityAuthorization(with type: DoximityAuthorizationType,
                         from viewController: UIViewController,
                                    animated: Bool,
                    authorizationResultBlock: @escaping DoximityAuthorizationResultBlock) {
        
        let doximityAuthorizationVC = scenesAssembly!.instantiateDoximityAuthorizationViewController(self)
        doximityAuthorizationVC.authorizationResultBlock = authorizationResultBlock
        doximityAuthorizationVC.doximityAuthorizationType = type
        
        doximityAuthorizationVC.modalTransitionStyle = .crossDissolve
        doximityAuthorizationVC.modalPresentationStyle = .overCurrentContext
        viewController.present(doximityAuthorizationVC, animated: true, completion: nil)
    }

    func handleOpenUrl(_ url: URL) {
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }
    
    // MARK: -
    // MARK: AuthorizationPrivateRoutingProtocol
    func showPhotosViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool) {
        delegate?.showPhotosStory(fromViewController: viewController, withAnimation: animated)
    }
    
     func showVerificationInfoAlertViewController(fromViewController viewController: UIViewController, withDelegate delegate: UIViewController, withAnimation animated: Bool) {
        let ProvideVerificationInfoAlertController = scenesAssembly?.instantiateVerificationInfoAlertController(self)
        ProvideVerificationInfoAlertController?.delegate = delegate as? ProvideVerificationInfoDelegate
        let alertController = alertLikeController(forViewController: ProvideVerificationInfoAlertController!)
        viewController.present(alertController, animated: animated, completion: nil)
    }
    
    
    func showRecoverPasswordViewController(fromViewController viewController: UIViewController, withAimation animated: Bool) {
        let viewControllerToShow = scenesAssembly?.instantiateRecoverPasswordViewController(self)
        
        viewController.present(viewControllerToShow!, animated: animated, completion: nil)
    }
    
    func showHostnamesViewController(fromViewController viewController: UIViewController, withDelegate delegate: HostnamesViewControllerDelegate, withAnimation animated: Bool) {
        let hostnamesViewController = scenesAssembly?.instantiateHostnamesViewController(self)
        hostnamesViewController?.delegate = delegate
        
        viewController.present(hostnamesViewController!, animated: animated, completion: nil)
    }
    
    func showDoximityProfileLoginViewController(with viewModel: ProfileFreemiumViewModel,
                             fromViewController viewController: UIViewController,
                                        withAnimation animated: Bool) {
        
        let doximityViewController = scenesAssembly?.instantiateDoximityProfileLoginViewController(self, viewModel: viewModel)
        authorizationNavigationController.pushViewController(doximityViewController!, animated: animated)
    }
    
    func showProfileLoginViewController(with viewModel: ProfileEnterpriseViewModel,
                     fromViewController viewController: UIViewController,
                                withAnimation animated: Bool) {
        
        let profileLoginViewController = scenesAssembly?.instantiateProfileLoginViewController(self, viewModel: viewModel)
        
       authorizationNavigationController.pushViewController(profileLoginViewController!, animated: animated)
    }
    
    func showSignUpPEViewController(fromViewController viewController: UIViewController,forAuthorizationModel authorizationModel: AuthorizationModel, withAnimation animated: Bool) {
        let SignUpPEViewController = scenesAssembly?.instantiateSignupPEViewController(self)
        SignUpPEViewController?.authorizationModel = authorizationModel
        authorizationNavigationController.pushViewController(SignUpPEViewController!, animated: true)
    }
    
     func showVerifyAccountViewController(fromViewController viewController: UIViewController, forAuthorizationModel authorizationModel: AuthorizationModel, withAnimation animated: Bool) {
        let doximityVerificationViewController = scenesAssembly?.instantiateVerifyAccountViewController(self)
        doximityVerificationViewController?.authorizationModel = authorizationModel
        authorizationNavigationController.pushViewController(doximityVerificationViewController!, animated: animated)
    }
    
   

    func showLinkDoximityViewController(with viewModel: LinkDoximityControllerViewModel,
                     fromViewController viewController: UIViewController,
                                withAnimation animated: Bool) {
        
        let linkDoximityViewController = scenesAssembly?.instantiateLinkDoximityViewController(self, linkViewModel: viewModel)
        authorizationNavigationController.pushViewController(linkDoximityViewController!, animated: animated)
    }
    
    func popToRootViewController(withAnimation animated: Bool) {
        loginViewController?.navigationController?.popToRootViewController(animated: animated)
    }
    
    func dismissToLoginViewController(withAnimation animated: Bool) {
        loginViewController?.dismiss(animated: animated, completion: nil)
    }
    
    func showMobileVerificationViewController(fromViewController viewController: UIViewController,
                                              forAuthorizationModel authorizationModel: AuthorizationModel,
                                              withAnimation animated: Bool) {
        let mobileVerificationViewController = scenesAssembly?.instantiateMobileVerificationViewController(self)
        mobileVerificationViewController?.authorizationModel = authorizationModel
        
        let alertController = alertLikeController(forViewController: mobileVerificationViewController!)
        viewController.present(alertController, animated: animated, completion: nil)
    }
    func showProfileNotFoundAlertController(fromViewController viewController: UIViewController, forEmail: Bool, forEmailWithPhone: Bool, withAnimation animated: Bool) {
        let profileNotFoundAlertController = scenesAssembly?.instantiateProfileNotFoundAlertController(self)
        profileNotFoundAlertController?.forEmail = forEmail
        profileNotFoundAlertController?.forEmailWithNumber = forEmailWithPhone
        let alertController = alertLikeController(forViewController: profileNotFoundAlertController!)
        viewController.present(alertController, animated: animated, completion: nil)
    }
//    func showProfileNotFoundAlertController(fromViewController viewController: UIViewController, withAnimation animated: Bool) {
//        let profileNotFoundAlertController = scenesAssembly?.instantiateProfileNotFoundAlertController(self)
//
//        let alertController = alertLikeController(forViewController: profileNotFoundAlertController!)
//        viewController.present(alertController, animated: animated, completion: nil)
//    }
}
