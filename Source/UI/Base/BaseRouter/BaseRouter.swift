//
//  BaseRouter.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 1/31/18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit

class BaseRouter: NSObject {

    var scenesAssembly: ScenesAssemblyProtocol?

    private override init() { }
    
    init(scenesAssembly: ScenesAssemblyProtocol?) {
        super.init()
        self.scenesAssembly = scenesAssembly
    }
    
    func alertLikeController(forViewController viewController: UIViewController) -> UIViewController {
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .overCurrentContext
        navigationController.navigationBar.isHidden = true
        return navigationController
    }
    
    func showPEVerificationViewController(fromViewController viewController: UIViewController, navigationController: UINavigationController, withAnimation animated: Bool) {
        let doximityVerificationViewController = scenesAssembly?.instantiatePEVerifVC(self)
        navigationController.pushViewController(doximityVerificationViewController!, animated: false)
    }
}
