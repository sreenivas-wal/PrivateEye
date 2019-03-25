//
//  NotificationsRoutingProtocol.swift
//  MyMobileED
//
//  Created by Created by Admin on 14.06.18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation

enum NotificationsRoutingTransition {
    
    case push(animated: Bool)
    case present(animated: Bool)
}

protocol NotificationsRouterDelegate: class {
    
    // Notification History
    func notificationsRouter(_ router: NotificationsRoutingProtocol, didTapBackButton button: UIButton, onViewController: UIViewController)
    func notificationsRouter(_ router: NotificationsRoutingProtocol, didLoadCommentedPhoto photo: Photo, onViewController: UIViewController)
    func notificationsRouter(_ router: NotificationsRoutingProtocol, didLoadSharedPhoto photo: Photo, onViewController: UIViewController)
    func notificationsRouter(_ router: NotificationsRoutingProtocol, didSelectGroupEvent groupID: String,item: NotificationHistoryItem, onViewController: UIViewController)
    func notificationsRouter(_ router: NotificationsRoutingProtocol, didSelectFolderEvent folderID: String,folderTitle: String, onViewController: UIViewController)
    
    // Notification Settings
    func notificationsRouter(_ router: NotificationsRoutingProtocol, didTapNotificationHistoryButton button: UIButton, onViewController: UIViewController)
}

protocol NotificationsRoutingProtocol: class {
    
    weak var delegate: NotificationsRouterDelegate? { get set }
    
    func showNotificationSettings(from viewController: UIViewController,
                                           transition: NotificationsRoutingTransition,
                                           completion: VoidBlock?)
    
    func showNotificationsHistory(from viewController: UIViewController,
                                           transition: NotificationsRoutingTransition,
                                           completion: VoidBlock?)
    
    func hide(viewController: UIViewController, animated: Bool, completion: VoidBlock?)
}

protocol NotificationsPrivateRoutingProtocol: class {
    
    func showNotificationSettingsViewController(from viewController: UIViewController,
                                                     withTransition: NotificationsRoutingTransition,
                                                         completion: VoidBlock?)
    
    func showNotificationHistoryViewController(from viewController: UIViewController,
                                                    withTransition: NotificationsRoutingTransition,
                                                        completion: VoidBlock?)
}
