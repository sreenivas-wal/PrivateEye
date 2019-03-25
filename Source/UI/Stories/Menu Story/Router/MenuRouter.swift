//
//  MenuRouter.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 8/29/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

protocol MenuRouterDelegate: class {
    func signOutFromViewController(_ viewController: UIViewController, withAnimation animated: Bool)
}

class MenuRouter: BaseRouter, MenuRouterProtocol, SlideMenuControllerDelegate {

    private let slideMenuAnimationDuration: CGFloat = 0.2
//    private var scenesAssembly: ScenesAssemblyProtocol?
    private var foldersNavigationDataSource: FoldersNavigationDataSourceProtocol?
    
    var delegate: MenuRouterDelegate?
    var photosRouter: PhotosRouterProtocol?
    var slideViewController: MainUIViewController?
    var menuFoldersViewController: MenuFoldersViewController?
    var menuNavigationController: UINavigationController?
    var menuViewController: MenuViewController?
    
//    private override init() { }
    
    init(scenesAssembly: ScenesAssemblyProtocol?, photosRouter: PhotosRouterProtocol, foldersNavigationDataSource: FoldersNavigationDataSourceProtocol?) {
        super.init(scenesAssembly: scenesAssembly)
        
        self.scenesAssembly = scenesAssembly
        self.photosRouter = photosRouter
        self.foldersNavigationDataSource = foldersNavigationDataSource
    }
    
    // MARK: - MenuRouterProtocol
    
    func initialViewController(isAfterLogin: Bool) -> UIViewController {
        let photosInitialController = photosRouter?.initialViewController(withOwnershipFilter: .my)
        
        let menuVC = scenesAssembly?.instantiateMenuViewController(self)
        menuVC?.shouldShowCaseSelectionScreen = isAfterLogin

        let menuNavigationController = UINavigationController(rootViewController: menuVC!)
        menuNavigationController.isNavigationBarHidden = true
        
        let mainUI = scenesAssembly?.instantiateMainUIViewControllerWith(menuNavigationController, frontViewController: photosInitialController!)
        mainUI?.delegate = self
        
        slideViewController = mainUI
        menuViewController = menuVC
        
        self.menuNavigationController = menuNavigationController
        
        return mainUI!
    }
    
    func showInitialMenuViewController() {
        let vc = self.initialViewController(isAfterLogin: false)
        menuNavigationController?.viewControllers = [vc]
    }
    
    func showMenuViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool) {
        let vc = self.initialViewController(isAfterLogin: true)
        viewController.navigationController?.pushViewController(vc, animated: animated)
    }
    
    func showLogInViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool) {
        delegate?.signOutFromViewController(viewController, withAnimation: animated)
    }
    
    func showProfileViewControllerWithAnimation(_ animated: Bool) {
        let fromViewController = slideViewController?.mainViewController
        photosRouter?.showProfileViewController(fromViewController: fromViewController!, withAnimation: true)
    }
    
    func showMenuFolderViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool, forSelectedFolder folder: Folder?) {
        let vc = scenesAssembly?.instantiateMenuFoldersViewController(self)
        vc?.selectedFolder = folder
    
        menuNavigationController?.setViewControllers([menuViewController!, vc!], animated: animated)
        menuFoldersViewController = vc
    }
    
    func showPhotosViewController(withOwnershipFilter ownershipFilter: PhotosOwnership, forFoldersStack folders: [Folder]) {
        let photosInitialController = photosRouter?.initialViewController(withOwnershipFilter: ownershipFilter)
        foldersNavigationDataSource?.replace(withItems: folders)
        slideViewController?.changeMainViewController(photosInitialController!, close: true)
    }
    
    func showGroupsViewControllerWithAnimation(_ animated: Bool) {
        let groupsViewController = photosRouter?.groupsViewController()
        slideViewController?.changeMainViewController(groupsViewController!, close: true)
    }

    func showBluetoothViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool) {
        photosRouter?.showBluetoothViewController(fromViewController: viewController, withAnimation: animated)
    }

    func popMenuViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool) {
        let menuFolderVC = scenesAssembly?.instantiateMenuFoldersViewController(self)

        menuNavigationController?.setViewControllers([menuFolderVC!, viewController], animated: false)
        menuNavigationController?.popViewController(animated: animated)
    }
    
    func popToRootMenuViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool) {
        menuNavigationController?.setViewControllers([menuViewController!, viewController], animated: false)
        menuNavigationController?.popViewController(animated: animated)
    }

    // MARK: - SlideMenuControllerDelegate
    
    func leftWillOpen() {
        if menuViewController!.shouldShowInitialMenuController() {
            let foldersStack = foldersNavigationDataSource!.fetchAll()
            photosRouter?.menuNavigationDataSource?.replace(withItems: foldersStack)
            
            let menuFolderVC = scenesAssembly?.instantiateMenuFoldersViewController(self)
            menuNavigationController?.setViewControllers([menuViewController!, menuFolderVC!], animated: false)
        }
    }
    
    // MARK: - MenuNavigationRouterProtocol
    
    func replaceFoldersStack(_ stack: [Folder]) {
        menuViewController?.foldersNavigationDataSource?.replace(withItems: stack)
    }
    
    func openMenu(animated: Bool) {
        SlideMenuOptions.animationDuration = animated ? slideMenuAnimationDuration : 0
        slideViewController?.openLeft()
        SlideMenuOptions.animationDuration = slideMenuAnimationDuration
    }
    
    func closeMenu(animated: Bool) {
        SlideMenuOptions.animationDuration = animated ? slideMenuAnimationDuration : 0
        slideViewController?.closeLeft()
        SlideMenuOptions.animationDuration = slideMenuAnimationDuration
    }
}
