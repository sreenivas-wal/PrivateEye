//
//  AuthorizationRouterProtocol.swift
//  MyMobileED
//
//  Created by Admin on 1/16/17.
//
//

import UIKit

typealias DoximityAuthorizationResultBlock = (_ result: DoximityAuthorizationResult) -> ()

enum DoximityAuthorizationResult {
    
    case success
    case failure(error: DoximityAuthorizationFailureResult)
}

enum DoximityAuthorizationFailureResult {
    
    case userCancelation
    case doximityNotVerified
    case unauthorized(reason: String)
}

// MARK: -
// MARK: Public
protocol AuthorizationRouterProtocol: class {
    
    func initialViewController() -> UIViewController
    
    func showLogInViewController(fromViewController viewController: UIViewController?, withAimation animated: Bool)
    func showCaseSelectionViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool)
    func showDoximityAuthorization(with type: DoximityAuthorizationType,
                         from viewController: UIViewController,
                                    animated: Bool,
                    authorizationResultBlock: @escaping DoximityAuthorizationResultBlock)

    func handleOpenUrl(_ url: URL)
}

// MARK: -
// MARK: Private
protocol AuthorizationPrivateRoutingProtocol: AuthorizationRouterProtocol {
    
    func showPhotosViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool)
    func showRecoverPasswordViewController(fromViewController viewController: UIViewController, withAimation animated: Bool)
    func showHostnamesViewController(fromViewController viewController: UIViewController,
                                                 withDelegate delegate: HostnamesViewControllerDelegate,
                                                withAnimation animated: Bool)

    func showProfileLoginViewController(with viewModel: ProfileEnterpriseViewModel,
                     fromViewController viewController: UIViewController,
                                withAnimation animated: Bool)
    func showSignUpPEViewController(fromViewController viewController: UIViewController,forAuthorizationModel authorizationModel: AuthorizationModel, withAnimation animated: Bool)

    func showDoximityProfileLoginViewController(with viewModel: ProfileFreemiumViewModel,
                             fromViewController viewController: UIViewController,
                                        withAnimation animated: Bool)

    func showVerifyAccountViewController(fromViewController viewController: UIViewController,forAuthorizationModel authorizationModel: AuthorizationModel, withAnimation animated: Bool)
    
    func showLinkDoximityViewController(with viewModel: LinkDoximityControllerViewModel,
                     fromViewController viewController: UIViewController,
                                withAnimation animated: Bool)

    func showMobileVerificationViewController(fromViewController viewController: UIViewController,
                                       forAuthorizationModel authorizationModel: AuthorizationModel,
                                                         withAnimation animated: Bool)

    func showProfileNotFoundAlertController(fromViewController viewController: UIViewController,forEmail:Bool,forEmailWithPhone:Bool, withAnimation animated: Bool)
    
    func showVerificationInfoAlertViewController(fromViewController viewController: UIViewController,withDelegate delegate:UIViewController, withAnimation animated: Bool)
    
    func popToRootViewController(withAnimation animated: Bool)
    
    func dismissToLoginViewController(withAnimation animated: Bool)
}

