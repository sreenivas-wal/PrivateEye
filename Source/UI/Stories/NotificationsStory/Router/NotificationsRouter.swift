//
//  NotificationsRouter.swift
//  MyMobileED
//
//  Created by Created by Admin on 14.06.18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation

class NotificationsRouter: NotificationsRoutingProtocol, NotificationsPrivateRoutingProtocol,
                           NotificationSettingsViewControllerDelegate,
                           NotificationHistoryListViewControllerDelegate {
    
    weak var delegate: NotificationsRouterDelegate?
    
    fileprivate let assembly: NotificationsAssemblyProtocol
    fileprivate let networkManager: PhotosNetworkProtocol
    
    init(with assembly: NotificationsAssemblyProtocol) {
        
        self.assembly = assembly
        self.networkManager = assembly.servicesAssembly.networkManager as! PhotosNetworkProtocol
    }
    
    // MARK: -
    // MARK: NotificationsRoutingProtocol
    func showNotificationSettings(from viewController: UIViewController,
                                           transition: NotificationsRoutingTransition,
                                           completion: VoidBlock?) {
        
        self.showNotificationSettingsViewController(from: viewController, withTransition: transition, completion: completion)
    }
    
    func hide(viewController: UIViewController, animated: Bool, completion: VoidBlock?) {
        
        if let settingsVC = viewController as? NotificationSettingsViewController {
            
            self.hide(viewController: settingsVC, transition: settingsVC.transition, completion: completion)
        }
        else if let historyVC = viewController as? NotificationHistoryListViewController {
            
            self.hide(viewController: historyVC, transition: historyVC.transition, completion: completion)
        }
    }
    
    func showNotificationsHistory(from viewController: UIViewController,
                                           transition: NotificationsRoutingTransition,
                                           completion: VoidBlock?) {
        
        self.showNotificationHistoryViewController(from: viewController, withTransition: transition, completion: completion)
    }
    
    // MARK: -
    // MARK: NotificationsPrivateRoutingProtocol
    func showNotificationSettingsViewController(from viewController: UIViewController,
                                                     withTransition: NotificationsRoutingTransition,
                                                         completion: VoidBlock?) {
        
        let settingsVC = self.assembly.assemblyNotificationSettingsViewController(with: withTransition)
        settingsVC.delegte = self
        self.show(viewControiller: settingsVC, fromViewController: viewController, transition: withTransition, completion: completion)
    }
    
    func showNotificationHistoryViewController(from viewController: UIViewController,
                                                    withTransition: NotificationsRoutingTransition,
                                                        completion: VoidBlock?) {
        
        let historyVC = self.assembly.assemblyNotificationHistoryListViewController(with: withTransition)
        historyVC.delegte = self
        self.show(viewControiller: historyVC, fromViewController: viewController, transition: withTransition, completion: completion)
    }
    
    // MARK: -
    // MARK: NotificationHistoryListViewControllerDelegate
    func notificationHistoryListViewController(_ viewController: NotificationHistoryListViewController, didTapLeftButton button: UIButton) {
        
        guard let requiredDelegate = self.delegate else { return }
        requiredDelegate.notificationsRouter(self, didTapBackButton: button, onViewController: viewController)
    }
    
    func notificationHistoryListViewController(_ viewController: NotificationHistoryListViewController, didSelectHistoryItem item: NotificationHistoryItem) {

        guard let ruquiredDelegate = self.delegate else { return }
        
        switch item.eventType {
        case .comments, .image: self.performPhotoLoading(event: item.eventType,
                                              onViewController: viewController)
        case .group(let id):
            ruquiredDelegate.notificationsRouter(self, didSelectGroupEvent: id,item: item, onViewController: viewController)
        case .folder(let id):
            ruquiredDelegate.notificationsRouter(self, didSelectFolderEvent: id, folderTitle: item.folderTitle!, onViewController: viewController)
        }
    }

    // MARK: -
    // MARK: NotificationSettingsViewControllerDelegate
    func notificationSettingsViewController(_ viewController: NotificationSettingsViewController, didTapLeftButton button: UIButton) {
       
        guard let requiredDelegate = self.delegate else { return }
        requiredDelegate.notificationsRouter(self, didTapBackButton: button, onViewController: viewController)
    }
    
    func notificationSettingsViewController(_ viewController: NotificationSettingsViewController, didTapNotificationHistoryButton button: UIButton) {
        
        guard let requiredDelegate = self.delegate else { return }
        requiredDelegate.notificationsRouter(self, didTapNotificationHistoryButton: button, onViewController: viewController)
    }

    // MARK: -
    // MARK: Private ( show / hide )
    fileprivate func show(viewControiller: UIViewController,
                       fromViewController: UIViewController,
                               transition: NotificationsRoutingTransition,
                               completion: VoidBlock?) {
        
        switch transition {
        case .present(let animated):
            fromViewController.present(viewControiller, animated: animated, completion: completion)
            
        case .push(let animated):
            let navigationController: UINavigationController
            
            if let requiredNavigationController = fromViewController as? UINavigationController {
                navigationController = requiredNavigationController
            }
            else if let requiredNavigationController = fromViewController.navigationController {
                navigationController = requiredNavigationController
            }
            else {
                print("NotificationsRouter | Unsuported Navigation")
                return
            }
            
            navigationController.pushViewController(viewControiller, animated: animated)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                if let requiredCompletion = completion {
                    requiredCompletion()
                }
            })
        }
    }
    
    fileprivate func hide(viewController: UIViewController,
                              transition: NotificationsRoutingTransition,
                              completion: VoidBlock?) {
     
        switch transition {
        case .present(let animated):
            viewController.dismiss(animated: animated, completion: completion)
        case .push(let animated):
            
            guard let requiredNavigationViewController = viewController.navigationController
            else {
                print("NotificationsRouter | Unsuported Navigation")
                return
            }
         
            requiredNavigationViewController.popViewController(animated: animated)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                if let requiredCompletion = completion {
                    requiredCompletion()
                }
            })
        }
    }
    
    // MARK: -
    // MARK: PhotosNetworkProtocol
    fileprivate func performPhotoLoading(event: NotificationHistoryItem.Event,
                              onViewController: NotificationHistoryListViewController) {

        guard let requiredDelegate = self.delegate else { return }
        
        let identifier: String
        switch event {
        case .image(let id):    identifier = id
        case .comments(let id): identifier = id
        default: return
        }
        
        onViewController.showLoading()
        
        self.networkManager.retrievePhoto(byNode: identifier,
                                    successBlock: { [weak self] response in

                                        guard let strongSelf = self else { return }
                                        onViewController.hideLoading()

                                        let photo = response.object as! Photo
                                        
                                        switch event {
                                        case .image:
                                            requiredDelegate.notificationsRouter(strongSelf, didLoadSharedPhoto: photo, onViewController: onViewController)
                                        case .comments:
                                            requiredDelegate.notificationsRouter(strongSelf, didLoadCommentedPhoto: photo, onViewController: onViewController)
                                        default: return
                                        }
                                    },
                                    failureBlock: { response in
                                        onViewController.hideLoading()
                                        onViewController.presentAlert(withMessage: response.message)
                                    })
    }
}
