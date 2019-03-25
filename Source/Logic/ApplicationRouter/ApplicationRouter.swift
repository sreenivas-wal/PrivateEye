//
//  ApplicationRouter.swift
//  MyMobileED
//
//  Created by Admin on 1/13/17.
//
//

import UIKit

class ApplicationRouter: NSObject, ApplicationRouterProtocol,
                                   AuthorizationRouterDelegate,
                                   PhotosRouterDelegate,
                                   MenuRouterDelegate,
                                   ReachabilityManagerObserverProtocol {

    private let scenesAssembly: ScenesAssemblyProtocol
    private let servicesAssembly: ServicesAssemblyProtocol
    private var reachabilityManager: ReachabilityManager?
    
//    private override init() { }
    
    init(scenesAssembly: ScenesAssemblyProtocol, servicesAssembly: ServicesAssemblyProtocol) {
        
        self.scenesAssembly = scenesAssembly
        self.servicesAssembly = servicesAssembly
        self.reachabilityManager = servicesAssembly.reachabilityManager
        
        super.init()

        if let requiredManager = self.reachabilityManager {
            requiredManager.subscribeForReachabilityChanges(observer: self)
        }
    }
    
    deinit {
        
        if let requiredReachabilityManager = self.reachabilityManager {
            requiredReachabilityManager.unsubscribeFromReachabilityChanges(observer: self)
        }
    }

    // MARK: RouterAssemblyProtocol
    
    lazy var authorizationStoryRouter: AuthorizationRouterProtocol = {
        let authorizationRouter = AuthorizationRouter(scenesAssembly: self.scenesAssembly)
        authorizationRouter.delegate = self
        
        return authorizationRouter
    }()
    
    lazy var photosStoryRouter: PhotosRouterProtocol = {
        let photosRouter = PhotosRouter(scenesAssembly: self.scenesAssembly, menuNavigationDataSource: self.servicesAssembly.menuNavigationDataSource)
        let networkManager = self.servicesAssembly.networkManager as! (PhotosNetworkProtocol)?
        photosRouter.delegate = self
        photosRouter.parentRouter = self
        
        return photosRouter
    }()
    
    lazy var menuStoryRouter: MenuRouterProtocol = {
        let menuRouter = MenuRouter(scenesAssembly: self.scenesAssembly,
                                    photosRouter: self.photosStoryRouter,
                                    foldersNavigationDataSource: self.servicesAssembly.foldersNavigationDataSource)
        menuRouter.delegate = self
        
        return menuRouter
    }()
    
    // MARK: - ApplicationRouterProtocol
    func handleOpenUrl(_ url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) {
        authorizationStoryRouter.handleOpenUrl(url)
    }
    
    func visibleViewController(_ rootViewController: UIViewController?) -> UIViewController? {
        if rootViewController?.presentedViewController == nil {
            return rootViewController
        }
        
        if let presentedViewController = rootViewController?.presentedViewController {
            if presentedViewController.isKind(of: UINavigationController.self) {
                let navigationController = presentedViewController as! UINavigationController
                
                return self.visibleViewController(navigationController.viewControllers.last!)
            }
            
            return presentedViewController
        }
        
        return nil
    }

    // MARK: AuthorizationRouterDelegate
    
    func showPhotosStory(fromViewController viewController: UIViewController, withAnimation animated: Bool) {
        menuStoryRouter.showMenuViewController(fromViewController: viewController, withAnimation: true)
    }
    
    // MARK: PhotosRouterDelegate

    func showSignOutViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool) {
        authorizationStoryRouter.showLogInViewController(fromViewController: viewController, withAimation: animated)
    }

    func showBluetoothViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool) {
        
        guard FeatureFlags.smartCaseEnabled else { return }
        authorizationStoryRouter.showCaseSelectionViewController(fromViewController: viewController, withAnimation: animated)
    }
    
    func relogin(fromViewController viewController: UIViewController, withAnimation animated: Bool) {
        menuStoryRouter.showMenuViewController(fromViewController: viewController, withAnimation: animated)
    }
    
    func showDoximityAuthorization(with type: DoximityAuthorizationType,
                         from viewController: UIViewController,
                                    animated: Bool,
                                 resultBlock: @escaping DoximityAuthorizationResultBlock) {

        authorizationStoryRouter.showDoximityAuthorization(with: type, from: viewController, animated: animated, authorizationResultBlock: resultBlock)
    }

    // MARK: MenuRouterDelegate
    
    func signOutFromViewController(_ viewController: UIViewController, withAnimation animated: Bool) {
        authorizationStoryRouter.showLogInViewController(fromViewController: viewController, withAimation: animated)
    }
    
    // MARK: MenuNavigationRouterProtocol
    
    func openMenu(animated: Bool) {
        menuStoryRouter.openMenu(animated: animated)
    }
    
    func closeMenu(animated: Bool) {
        menuStoryRouter.closeMenu(animated: animated)
    }
    
    // MARK: - ReachabilityManagerObserverProtocol
    func reachabilityManagerDidReceiveNotReachableStatus(_ manager: ReachabilityManager) {
        
        let title = "Offline Mode"
        let message = "Due to a poor internet connection you may experience limited functionality while using PrivateEyeHC"
        DispatchQueue.main.async { self.showAlert(with: title, message: message) }
    }
    
    // MARK: - Private
    fileprivate func showAlert(with title: String, message: String) {
        
        guard let requiredVisibleViewController = self.visibleViewController(UIApplication.shared.keyWindow?.rootViewController)
        else { return }
        
        let alertController = UIAlertController(title: title,
                                              message: message,
                                       preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        requiredVisibleViewController.present(alertController, animated: false, completion: nil)
    }
}
