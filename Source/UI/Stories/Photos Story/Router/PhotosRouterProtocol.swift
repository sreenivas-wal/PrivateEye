//
//  PhotosRouterProtocol.swift
//  MyMobileED
//
//  Created by Admin on 1/16/17.
//
//

import UIKit

protocol PhotosRouterProtocol: MenuNavigationRouterProtocol {
    var menuNavigationDataSource: FoldersNavigationDataSourceProtocol? { get }
    
    func initialViewController(withOwnershipFilter ownership: PhotosOwnership) -> UIViewController
    func groupsViewController() -> UIViewController
    func showPEVerificationViewController(fromViewController viewController: UIViewController, navigationController: UINavigationController, withAnimation animated: Bool)
    func showPhotosViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool, with ownership: PhotosOwnership, isEnableContent: Bool)
    
    func showPhotosViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool)
    func showSharePhotosViewController(fromViewController viewController: UIViewController,
                                       withAnimation animated: Bool,
                                       with ownership: PhotosOwnership,
                                       sharingCompletionHandler: ((_ group: Group) -> ())?)
    
    func showProfileViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool)
    func showBluetoothViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool)
    func showCameraViewController(fromViewController viewController: UIViewController,
                                  withAnimation animated: Bool,
                                  inFolder folder: Folder?,
                                  group: Group?,
                                  delegate: CameraViewControllerDelegate)
    
    func showPhotoLibraryViewController(with delegate: PhotoLibraryViewControllerDelegate,
                                      inFolder folder: Folder?,
                                                group: Group?,
                                   fromViewController: UIViewController,
                                             animated: Bool)
    
    func hidePhotoLibraryViewController(_ viewConroller: PhotoLibraryViewController, animated: Bool, completion: VoidBlock?)
    
    func showChangePasswordViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool)
    
    func showFullScreenViewControler(fromViewController viewController: UIViewController,
                                                withAnimation animated: Bool,
                                                    currentPhoto photo: Photo,
                                                               canEdit: Bool,
                                                             in folder: Folder?,
                                                         photoDelegate: FullScreenPhotoViewControllerDelegate?)
    
    func hideFullScreenViewControler(_ viewController: FullScreenPhotoViewController, animated: Bool, comletion: VoidBlock? )
    
    func showLogInViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool)

    func showShareViewController(fromViewController viewController: UIViewController,
                                 withAnimation animated: Bool,
                                 shareCompletionHandler: @escaping ((_ users: [ShareUser], _ presentingController: UIViewController) -> (Void)),
                                 cancelSharingCompletionHandler: @escaping (() -> (Void)),
                                 doximityAuthorizationFailureBlock: ShareViewControllerAuthorizationFailureBlock?,
                                 forSharingDestination sharingDestination: SharingDestination)
 
    func showSelectFolderViewController(fromViewController viewController: UIViewController,
                                        withAnimation animated: Bool,
                                        forFolder folder: Folder?,
                                        uploadingPhoto photo: Photo,
                                        delegate: SelectFolderViewControllerDelegate)
    
    func showEditPhotoViewController(fromViewController viewController: UIViewController,
                                                withAnimation animated: Bool,
                                                        forPhoto photo: Photo,
                                                             in folder: Folder?,
                                                              delegate: EditPhotoViewControllerDelegate)
    
    func showCommentsViewController(fromViewController viewController: UIViewController,
                                    withAnimation animated: Bool,
                                    forPhoto photo: Photo)
    
    func showContactsViewController(fromViewController viewController: UIViewController,
                                    withAnimation animated: Bool,
                                    forDisplayingInfo displayingInfo: ContactsDisplayingInfo,
                                    selectionHandler: @escaping ((_ textValues: [String]) -> (Void)))
    
    func showShareContactsAlertViewController(fromViewController viewController: UIViewController,
                                                         withAnimation animated: Bool,
                                                                      viewModel: ShareContactsAlertViewControllerViewModel,
                                                                  shareCallback: @escaping ((_ textValues: [String], _ viewController: UIViewController) -> (Void)))
    
    func showShareUsersAlertViewController(fromViewController viewController: UIViewController,
                                              withAnimation animated: Bool,
                                              viewModel: UserDisplayingInformationViewModel,
                                              forSharingDestination sharingDestination: SharingDestination,
                                              users: [ShareUser],
                                              shareCallback: @escaping ((_ users: [ShareUser], _ viewController: UIViewController) -> (Void)))
    
    func showGroupsViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool)
    func showShareGroupsViewController(fromViewController viewController: UIViewController,
                                       withAnimation animated: Bool,
                                       sharingCompletionHandler: ((_ group: Group) -> ())?)
    
    func showAddMemberAlertViewController(fromViewController viewController: UIViewController,
                                          withAnimation animated: Bool,
                                          viewModel: AddMemberDisplayingInfoViewModel,
                                          withCompletionHandler completionHandler: @escaping () -> ())
    
    func relogin(fromViewController viewController: UIViewController, withAnimation animated: Bool)
    func popPhotosViewController(_ viewController: UIViewController, withAnimation animated: Bool)
    
    func showDoximityUpdateTokenAuthorization(from viewController: UIViewController, animated: Bool, resultBlock: @escaping DoximityAuthorizationResultBlock)
    func showDoximityFullAuthorization(from viewController: UIViewController, animated: Bool, resultBlock: @escaping DoximityAuthorizationResultBlock)
    
    
    // MARK: -
    // MARK: NotificationsRouting
    func showNotificationSettings(from viewController: UIViewController, animated: Bool)
    func showNotificationsHistory(from viewController: UIViewController, animated: Bool)

    func showPhotosViewController(from viewController: UIViewController,
                               withAnimation animated: Bool,
                                       with ownership: PhotosOwnership,
                                     folderDataSourse: FoldersNavigationDataSourceProtocol)
}
