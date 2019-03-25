//
//  ApplicationRouterProtocol.swift
//  MyMobileED
//
//  Created by Admin on 1/13/17.
//
//

import UIKit

protocol ApplicationRouterProtocol: class {
    var authorizationStoryRouter: AuthorizationRouterProtocol { get set }
    
    func handleOpenUrl(_ url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
    func visibleViewController(_ rootViewController: UIViewController?) -> UIViewController?
}
