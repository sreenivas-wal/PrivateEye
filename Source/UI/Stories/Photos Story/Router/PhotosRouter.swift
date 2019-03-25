//
//  PhotosRouter.swift
//  MyMobileED
//
//  Created by Admin on 1/16/17.
//
//

import UIKit

protocol PhotosRouterDelegate: MenuNavigationRouterProtocol {
    
    func showSignOutViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool)
    func showBluetoothViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool)
    func relogin(fromViewController viewController: UIViewController, withAnimation animated: Bool)
    
    func showDoximityAuthorization(with type: DoximityAuthorizationType,
                         from viewController: UIViewController,
                                    animated: Bool,
                                 resultBlock: @escaping DoximityAuthorizationResultBlock)
}

class PhotosRouter: BaseRouter, PhotosRouterProtocol, MenuNavigationRouterProtocol, PhotoCoordinatorObserverProtocol, NotificationsRouterDelegate {
    
    var menuNavigationDataSource: FoldersNavigationDataSourceProtocol?
    
    weak var parentRouter: MenuNavigationRouterProtocol?
    var delegate: PhotosRouterDelegate?
    var photosNavigationController: UINavigationController?
    private var photoCoordinator: PhotoCoordinatorObserverSubscriptionProtocol?
    private weak var currentPhotosViewController: PhotosViewController?
    private let notificationsRouter: NotificationsRoutingProtocol
    
    init(scenesAssembly: ScenesAssemblyProtocol, menuNavigationDataSource: FoldersNavigationDataSourceProtocol?) {

        self.menuNavigationDataSource = menuNavigationDataSource
        
        self.photoCoordinator = scenesAssembly.servicesAssembly.photoCoordinator
        
        let notificationsAssembly = NotificationsAssembly(withServicesAssembly: scenesAssembly.servicesAssembly)
        let notificationsRouter = NotificationsRouter(with: notificationsAssembly)
        self.notificationsRouter = notificationsRouter

        super.init(scenesAssembly: scenesAssembly)
        
        notificationsRouter.delegate = self
        if let requiredPhotoCoordonator = self.photoCoordinator {
            requiredPhotoCoordonator.subscribeForPhotoCoordinatorChanges(observer: self)
        }
    }
    
    deinit {

        if let requiredPhotoCoordonator = self.photoCoordinator {
            requiredPhotoCoordonator.unsubscribeFromPhotoCoordinatorChanges(observer: self)
        }
    }
    
    // MARK: PhotosRouterProtocol
    
    func initialViewController(withOwnershipFilter ownership: PhotosOwnership) -> UIViewController {
        let photosVC = scenesAssembly?.instantiatePhotosViewController(self)
        photosVC?.ownership = ownership
        photosVC?.shouldShowConnectionAlert = true
        
        let photosNavigationController = UINavigationController(rootViewController: photosVC!)
        photosNavigationController.isNavigationBarHidden = true
        
        self.photosNavigationController = photosNavigationController
        
        // TODO: Fix it (need to solve memory leak with PhotosViewController )
        self.currentPhotosViewController = photosVC

        return photosNavigationController
    }
    
    func groupsViewController() -> UIViewController {
        let groupsVC = scenesAssembly?.instantiateGroupsViewController(self)
        let groupsNavigationController = UINavigationController(rootViewController: groupsVC!)
        groupsNavigationController.isNavigationBarHidden = true
        
        self.photosNavigationController = groupsNavigationController
        
        return groupsNavigationController
    }
    
    func showPhotosViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool, with ownership: PhotosOwnership, isEnableContent: Bool) {
        let vc = scenesAssembly?.instantiatePhotosViewController(self)
        vc?.ownership = ownership
        vc?.isSharing = !isEnableContent
        
        photosNavigationController?.pushViewController(vc!, animated: animated)
        
        // TODO: Fix it (need to solve memory leak with PhotosViewController )
        self.currentPhotosViewController = vc
    }
    
    func showSharePhotosViewController(fromViewController viewController: UIViewController,
                                       withAnimation animated: Bool,
                                       with ownership: PhotosOwnership,
                                       sharingCompletionHandler: ((_ group: Group) -> ())?) {
        let vc = scenesAssembly?.instantiatePhotosViewController(self)
        vc?.ownership = ownership
        vc?.isSharing = true
        vc?.sharingCompletionHandler = sharingCompletionHandler
        
        viewController.navigationController?.pushViewController(vc!, animated: animated)
    }
    
    func showPhotosViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool) {
        let vc = scenesAssembly?.instantiatePhotosViewController(self)
        photosNavigationController?.setViewControllers([vc!], animated: animated)
    }
    
    func showCameraViewController(fromViewController viewController: UIViewController,
                                  withAnimation animated: Bool,
                                  inFolder folder: Folder?,
                                  group: Group?,
                                  delegate: CameraViewControllerDelegate) {
        let vc = scenesAssembly?.instantiateCameraViewController(self, delegate: delegate)
        vc?.selectedFolder = folder
        vc?.group = group
        
        let navigationController = UINavigationController(rootViewController: vc!)
        navigationController.navigationBar.isHidden = true
        
        viewController.present(navigationController, animated: animated, completion: nil)
    }

    func showPhotoLibraryViewController(with delegate: PhotoLibraryViewControllerDelegate,
                                      inFolder folder: Folder?,
                                                group: Group?,
                                   fromViewController: UIViewController,
                                             animated: Bool) {
        
        let photoLibraryVC = scenesAssembly?.instantiatePhotoLibraryViewController(self, delegate: delegate)
        photoLibraryVC?.group = group
        photoLibraryVC?.selectedFolder = folder
        
        let navigationController = UINavigationController(rootViewController: photoLibraryVC!)
        navigationController.navigationBar.isHidden = true
        
        fromViewController.present(navigationController, animated: animated, completion: nil)
    }
    
    func hidePhotoLibraryViewController(_ viewConroller: PhotoLibraryViewController, animated: Bool, completion: VoidBlock?) {
        if let requiredNVC = viewConroller.navigationController {
            requiredNVC.dismiss(animated: animated, completion: completion)
        }
        else {
            viewConroller.dismiss(animated: animated, completion: completion)
        }
    }
    
    func showProfileViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool) {
        let vc = scenesAssembly?.instantiateProfileViewController(self)
        
        viewController.navigationController?.pushViewController(vc!, animated: animated)
    }
    
    func showBluetoothViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool) {
        self.delegate?.showBluetoothViewController(fromViewController: viewController, withAnimation: animated)
    }

    func showShareViewController(fromViewController viewController: UIViewController,
                                 withAnimation animated: Bool,
                                 shareCompletionHandler: @escaping ((_ users: [ShareUser], _ presentingController: UIViewController) -> (Void)),
                         cancelSharingCompletionHandler: @escaping (() -> (Void)),
                      doximityAuthorizationFailureBlock: ShareViewControllerAuthorizationFailureBlock?,
               forSharingDestination sharingDestination: SharingDestination) {
        
        let vc = scenesAssembly?.instantiateShareViewController(self)
        vc?.shareCompletionHandler = shareCompletionHandler
        vc?.cancelSharingCompletionHandler = cancelSharingCompletionHandler
        vc?.sharingDestination = sharingDestination
        vc?.doximityAuthorizationFailureBlock = doximityAuthorizationFailureBlock
        
        viewController.navigationController?.pushViewController(vc!, animated: animated)
    }
    
    func showFullScreenViewControler(fromViewController viewController: UIViewController,
                                     withAnimation animated: Bool,
                                     currentPhoto photo: Photo,
                                     canEdit: Bool,
                                     in folder: Folder?,
                                     photoDelegate: FullScreenPhotoViewControllerDelegate?) {
        
        let vc = scenesAssembly?.instantiateFullScreenPhotoViewController(self, photo: photo)
        vc?.canEditPhoto = canEdit
        vc?.photoDelegate = photoDelegate
        vc?.selectedFolder = folder
        
        let navigationController = UINavigationController()
        navigationController.navigationBar.isHidden = true
        
        viewController.present(navigationController, animated: false, completion: {
            navigationController.setViewControllers([vc!], animated: animated)
        })
    }
    
    func hideFullScreenViewControler(_ viewController: FullScreenPhotoViewController, animated: Bool, comletion: VoidBlock? ) {
        
        if let requiredNavigationViewController = viewController.navigationController {
            requiredNavigationViewController.dismiss(animated: animated, completion: comletion)
        }
        else {
            viewController.dismiss(animated: animated, completion: comletion)
        }
    }
    
    func showSelectFolderViewController(fromViewController viewController: UIViewController,
                                        withAnimation animated: Bool,
                                        forFolder folder: Folder?,
                                        uploadingPhoto photo: Photo,
                                        delegate: SelectFolderViewControllerDelegate) {
        let vc = scenesAssembly?.instantiateSelectFolderViewController(self)
        vc?.selectedFolder = folder
        vc?.uploadingPhoto = photo
        vc?.delegate = delegate
        
        viewController.navigationController?.pushViewController(vc!, animated: animated)
    }
    
    func showChangePasswordViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool) {
        let vc = scenesAssembly?.instantiateChangePasswordViewController(self)
        
        viewController.present(vc!, animated: animated, completion: nil)
    }
    
    func showLogInViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool) {
        self.delegate?.showSignOutViewController(fromViewController: viewController, withAnimation: animated)
    }
    
    func showEditPhotoViewController(fromViewController viewController: UIViewController,
                                     withAnimation animated: Bool,
                                     forPhoto photo: Photo,
                                     in folder: Folder?,
                                     delegate: EditPhotoViewControllerDelegate) {
        
        let vc = scenesAssembly?.instantiateEditPhotoViewController(self, photo: photo, in: folder)
        vc?.delegate = delegate
        
        let navigationController = UINavigationController(rootViewController: vc!)
        navigationController.navigationBar.isHidden = true
        
        viewController.present(navigationController, animated: animated, completion: nil)
    }
    
    func popPhotosViewController(_ viewController: UIViewController, withAnimation animated: Bool) {
        let photosVC = scenesAssembly?.instantiatePhotosViewController(self)
        
        photosNavigationController?.setViewControllers([photosVC!, viewController], animated: animated)
        photosNavigationController?.popViewController(animated: animated)
    }

    func showCommentsViewController(fromViewController viewController: UIViewController,
                                     withAnimation animated: Bool,
                                    forPhoto photo: Photo) {
        let commentsVC = scenesAssembly?.instantiateCommentsViewController(self, photo: photo)
        
        viewController.navigationController?.pushViewController(commentsVC!, animated: animated)
    }
    
    func showContactsViewController(fromViewController viewController: UIViewController,
                                    withAnimation animated: Bool,
                                    forDisplayingInfo displayingInfo: ContactsDisplayingInfo,
                                    selectionHandler: @escaping ((_ textValues: [String]) -> (Void))) {
        let contactsVC = scenesAssembly?.instantiateContactsViewController(self)
        contactsVC?.displayingInfo = displayingInfo
        contactsVC?.selectionHandler = selectionHandler
        
        viewController.navigationController?.pushViewController(contactsVC!, animated: animated)
    }
    
    func showShareContactsAlertViewController(fromViewController viewController: UIViewController,
                                                         withAnimation animated: Bool,
                                                                      viewModel: ShareContactsAlertViewControllerViewModel,
                                                                  shareCallback: @escaping ((_ textValues: [String], _ viewController: UIViewController) -> (Void))) {
        let shareAlertVC = scenesAssembly?.instantiateShareContactsAlertViewController(self)
        shareAlertVC?.viewModel = viewModel
        shareAlertVC?.sharingHandler = shareCallback
        shareAlertVC?.userDisplayingInformationViewModel = viewModel.userDisplayingInformationViewModel
        
        let alertController = alertLikeController(forViewController: shareAlertVC!)
        viewController.present(alertController, animated: animated, completion: nil)
    }
    
    func showShareUsersAlertViewController(fromViewController viewController: UIViewController,
                                           withAnimation animated: Bool,
                                           viewModel: UserDisplayingInformationViewModel,
                                           forSharingDestination sharingDestination: SharingDestination,
                                           users: [ShareUser],
                                           shareCallback: @escaping ((_ users: [ShareUser], _ viewController: UIViewController) -> (Void))) {
        let shareAlertVC = scenesAssembly?.instantiateShareUsersAlertViewController(self)
        shareAlertVC?.sharingDestination = sharingDestination
        shareAlertVC?.sharingHandler = shareCallback
        shareAlertVC?.users = users
        shareAlertVC?.userDisplayingInformationViewModel = viewModel
        
        let alertController = alertLikeController(forViewController: shareAlertVC!)
        viewController.present(alertController, animated: animated, completion: nil)
    }
    
    func showGroupsViewController(fromViewController viewController: UIViewController, withAnimation animated: Bool) {
        let groupsVC = scenesAssembly?.instantiateGroupsViewController(self)
        
        photosNavigationController?.pushViewController(groupsVC!, animated: animated)
    }
    
    func showShareGroupsViewController(fromViewController viewController: UIViewController,
                                       withAnimation animated: Bool,
                                       sharingCompletionHandler: ((_ group: Group) -> ())?) {
        let groupsVC = scenesAssembly?.instantiateGroupsViewController(self)
        groupsVC?.isSharing = true
        groupsVC?.sharingCompletionHandler =  sharingCompletionHandler
        
        viewController.navigationController?.pushViewController(groupsVC!, animated: animated)
    }

    func showAddMemberAlertViewController(fromViewController viewController: UIViewController,
                                          withAnimation animated: Bool,
                                          viewModel: AddMemberDisplayingInfoViewModel,
                                          withCompletionHandler completionHandler: @escaping () -> ()) {
        let addMembersVC = scenesAssembly?.instantiateAddMemberAlertViewController(self)
        addMembersVC?.viewModel = viewModel
        addMembersVC?.completionHandler = completionHandler
        
        let alertController = alertLikeController(forViewController: addMembersVC!)
        viewController.present(alertController, animated: animated, completion: nil)
    }
    
    func relogin(fromViewController viewController: UIViewController, withAnimation animated: Bool) {
        delegate?.relogin(fromViewController: viewController, withAnimation: animated)
    }
    
    func showDoximityUpdateTokenAuthorization(from viewController: UIViewController, animated: Bool, resultBlock: @escaping DoximityAuthorizationResultBlock) {
        
        self.delegate?.showDoximityAuthorization(with: .doximityTokenUpdate,
                                                 from: viewController,
                                             animated: animated,
                                          resultBlock: resultBlock)
    }
    
    func showDoximityFullAuthorization(from viewController: UIViewController, animated: Bool, resultBlock: @escaping DoximityAuthorizationResultBlock) {
        
        self.delegate?.showDoximityAuthorization(with: .fullAuthorization,
                                                 from: viewController,
                                             animated: animated,
                                          resultBlock: resultBlock)
    }
    
    // Usage - notifications history navigation
    func showPhotosViewController(from viewController: UIViewController,
                               withAnimation animated: Bool,
                                       with ownership: PhotosOwnership,
                                     folderDataSourse: FoldersNavigationDataSourceProtocol) {
        
        let vc = scenesAssembly?.instantiatePhotosViewController(self)
        vc?.ownership = ownership
        vc?.isSharing = false
        vc?.foldersNavigationDataSource = folderDataSourse
        vc?.isOpenedFromNotificationsFeed = true
        
        viewController.navigationController?.pushViewController(vc!, animated: animated)
    }
    
    // MARK: -
    // MARK: NotificationsRouting
    func showNotificationSettings(from viewController: UIViewController, animated: Bool) {
        
        self.notificationsRouter.showNotificationSettings(from: viewController, transition: .push(animated: animated), completion: nil)
    }
    
    func showNotificationsHistory(from viewController: UIViewController, animated: Bool) {
        
        self.notificationsRouter.showNotificationsHistory(from: viewController, transition: .push(animated: animated), completion: nil)
    }
    
    // MARK: -
    // MARK: NotificationsRouterDelegate
    func notificationsRouter(_ router: NotificationsRoutingProtocol, didTapBackButton button: UIButton, onViewController: UIViewController) {
        
        router.hide(viewController: onViewController, animated: true, completion: nil)
    }
    
    func notificationsRouter(_ router: NotificationsRoutingProtocol, didSelectGroupEvent groupID: String,item: NotificationHistoryItem, onViewController: UIViewController) {

        let group = Group(groupID: groupID)
        group.title = item.groupTitle
        group.usersCount = item.memberCount!
        group.ownerId = item.groupId
        let photosOwnership = PhotosOwnership.group(group: group)
        let vc = scenesAssembly!.instantiatePhotosViewController(self)
        vc.foldersNavigationDataSource = FoldersNavigationDataSource()
        vc.ownership = photosOwnership
        vc.isSharing = false
        vc.isOpenedFromNotificationsFeed = true
        
        onViewController.navigationController?.pushViewController(vc, animated: true)
    }

    func notificationsRouter(_ router: NotificationsRoutingProtocol, didSelectFolderEvent folderID: String, folderTitle: String, onViewController: UIViewController) {

        let folder = Folder(folderID: folderID, title: folderTitle, isEditable: false, photosCount: 0, subfoldersCount: 0)
        let vc = scenesAssembly!.instantiatePhotosViewController(self)
        let foldersNavigationDataSource = FoldersNavigationDataSource()
        foldersNavigationDataSource.replace(withItems: [folder])

        vc.foldersNavigationDataSource = foldersNavigationDataSource
        vc.isSharing = false
        vc.isOpenedFromNotificationsFeed = true
        onViewController.navigationController?.pushViewController(vc, animated: true)
    }

    func notificationsRouter(_ router: NotificationsRoutingProtocol, didLoadCommentedPhoto photo: Photo, onViewController: UIViewController) {

        self.showCommentsViewController(fromViewController: onViewController, withAnimation: true, forPhoto: photo)
    }
    
    func notificationsRouter(_ router: NotificationsRoutingProtocol, didLoadSharedPhoto photo: Photo, onViewController: UIViewController) {
        
        self.showFullScreenViewControler(fromViewController: onViewController,
                                              withAnimation: true,
                                               currentPhoto: photo,
                                                    canEdit: false,
                                                         in: nil,
                                              photoDelegate: nil)
    }
    
    func notificationsRouter(_ router: NotificationsRoutingProtocol, didTapNotificationHistoryButton button: UIButton, onViewController: UIViewController) {

        self.showNotificationsHistory(from: onViewController, animated: true)
    }

    // MARK: - MenuNavigationRouterProtocol
    
    func openMenu(animated: Bool) {
        parentRouter?.openMenu(animated: animated)
    }
    
    func closeMenu(animated: Bool) {
        parentRouter?.closeMenu(animated: animated)
    }
    
    // MARK: - PhotoCoordinatorObserverProtocol
    func photoCoordinator(_ coordinator: PhotoCoordinatorProtocol, didCacheItems totalCount: Int) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {

            guard let requiredNavigationVC = self.photosNavigationController,
                      requiredNavigationVC.presentedViewController == nil
            else { return }
            
            let alertController = UIAlertController(title: nil,
                                                  message: "Your photos will be uploaded when network connection is restored. The number of photos to be uploaded is \(totalCount).",
                preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
                alertController.dismiss(animated: true, completion: nil)
            }))
            
            requiredNavigationVC.present(alertController, animated: true)
        }
    }
    
    func photoCoordinatorDidUploadCachedItems(_ coordinator: PhotoCoordinatorProtocol) {
        
        // WARN:
        // This is temp solution
        // For updating UI of current visible PhotosViewVontroller
        // We can't subscribe each instanse of PhotoVC to PhotoCoordinatorObserverProtocol
        // The reason why:
        // memory leak. all instanses keeps in memory. Therefore all of them will recieve message
        
        guard let requiredPhotosViewController = self.currentPhotosViewController else { return }
        requiredPhotosViewController.foldersNavigationDataSource?.needUpdateStack()
        requiredPhotosViewController.photosDataSource?.reloadContent(forFolder: requiredPhotosViewController.selectedFolder)
    }
}
