//
//  MenuRouterProtocol.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 8/29/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

protocol MenuRouterProtocol: MenuNavigationRouterProtocol {
    func initialViewController(isAfterLogin: Bool) -> UIViewController
    func showInitialMenuViewController()
    
    func showMenuViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool)
    func showLogInViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool)
    func showProfileViewControllerWithAnimation(_ animated: Bool)
    func showPhotosViewController(withOwnershipFilter ownershipFilter: PhotosOwnership, forFoldersStack folders: [Folder])
    func showMenuFolderViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool, forSelectedFolder folder: Folder?)
    func showGroupsViewControllerWithAnimation(_ animated: Bool)
    func showBluetoothViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool)
    func showPEVerificationViewController(fromViewController viewController: UIViewController, navigationController: UINavigationController, withAnimation animated: Bool)

    func popMenuViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool)
    func popToRootMenuViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool)
}

protocol MenuNavigationRouterProtocol: class {
    func openMenu(animated: Bool)
    func closeMenu(animated: Bool)
}
