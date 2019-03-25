//
//  AlertsManagerProtocol.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 9/26/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

protocol AlertsManagerProtocol: class {
    
    // MARK: - Common
    
    func showAlert(forViewController viewController: UIViewController, withTitle title: String, message: String)
    func showErrorAlert(forViewController viewController: UIViewController, withMessage message: String)
    func showAlertWithTextField(forViewController viewController: UIViewController,
                                with title: String,
                                message: String,
                                textFieldPlaceholder: String,
                                actionHandler: @escaping ((_ text: String) -> ()))
    
    // MARK: - Doximity
    
    func showDoximityVerificationAlertController(forViewController viewController: UIViewController, withOkayCallback okayCallback: @escaping () -> (Void))
    func showUnVerifiedAlertController(forViewController viewController: UIViewController, withOkayCallback okayCallback: @escaping () -> (Void),withOpenCallback openCallback: @escaping () -> (Void))
    func showInReviewAlertController(forViewController viewController: UIViewController, withOkayCallback okayCallback: @escaping () -> (Void))
    func showUnSavedChangesAlertController(forViewController viewController: UIViewController, withYesCallback yesCallback: @escaping () -> (Void),withNoCallback noCallback: @escaping () -> (Void))

    
    // MARK: - Groups
    
    func showAddMembersAlertController(forViewController viewController: UIViewController,
                                       withUserSelectionCallback userSelectionCallback: @escaping () -> (Void),
                                       doximitySelectionCallback: @escaping () -> (Void),
                                       emailSelectionCallback: @escaping () -> (Void),
                                       textSelectionCallback: @escaping () -> (Void))
    
    func showSuccessMembersAddedAlertController(forViewController viewController: UIViewController, withSuccessHandler successHandler: @escaping (() -> ()))
    func showSuccessSharedContentAlertController(forViewController viewController: UIViewController)
    
    // MARK: - Sharing
    
    func showShareAlertController(forViewController viewController: UIViewController,
                                  withShareToUserCallback shareToUserCallback: @escaping () -> (Void),
                                  shareToDoximityCallback: @escaping () -> (Void),
                                  shareByEmailCallback: @escaping () -> (Void),
                                  shareByTextCallback: @escaping () -> (Void),
                                  shareToGroupCallback: @escaping () -> (Void))

    func showSuccessSharedPhotoAlertController(forViewController viewController: UIViewController, isMultiple: Bool)
    func showSuccessSharedFolderAlertController(forViewController viewController: UIViewController, isMultiple: Bool)
    func showSuccessSharedByEmailAlertController(forViewController viewController: UIViewController, isMultiple: Bool)
    func showSuccessSharedByTextAlertController(forViewController viewController: UIViewController, isMultiple: Bool)

    // MARK: - Invites
    
    func showInviteAlertController(forViewController viewController: UIViewController,
                                   withMessage message: String,
                                   withDoximityInviteHandler doximityInviteHandler: @escaping (() -> (Void)),
                                   withEmailInviteHandler emailInviteHandler: @escaping (() -> (Void)),
                                   textInviteHandler: @escaping (() -> (Void)))
    
    func showInviteByEmailAlertController(forViewController viewController: UIViewController,
                                          textValue: String,
                                          withSuccessHandler successHandler: @escaping ((_ email: String) -> (Void)))
    
    func showInviteByTextAlertController(forViewController viewController: UIViewController,
                                         textValue: String,
                                         withSuccessHandler successHandler: @escaping ((_ text: String) -> (Void)))
    
    func showSuccessInviteAlertController(forViewController viewController: UIViewController)

    // MARK: - Photo

    func showConnectionAlertController(forViewController viewController: UIViewController,
                                       textValue: String,
                                       withHandler actionHandler: @escaping ((UIAlertAction) -> (Void)))    
}
