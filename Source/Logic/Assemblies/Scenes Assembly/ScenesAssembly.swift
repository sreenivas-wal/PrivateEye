//
//  ScenesAssembly.swift
//  MyMobileED
//
//  Created by Admin on 1/13/17.
//
//

import UIKit
import SlideMenuControllerSwift

class ScenesAssembly: NSObject, ScenesAssemblyProtocol {
   
    let servicesAssembly: ServicesAssemblyProtocol

    private let slideMenuContentViewScale: CGFloat = 1.0
    private let slideMenuAnimationDuration: CGFloat = 0.2
    private let slideMenuLeftViewTralling: CGFloat = 65
    
    init(servicesAssembly: ServicesAssemblyProtocol) {
        
        self.servicesAssembly = servicesAssembly

        super.init()
    }
    
    // MARK: Initial
    
    func instantiateInitialViewController(_ authRouter: AuthorizationRouterProtocol, menuRouter: MenuRouterProtocol) -> UIViewController {

        if servicesAssembly.userManager?.isCurrentUserAuthorized() == true {
            let menuInitialVC = menuRouter.initialViewController(isAfterLogin: false)
            let mainUINavigationController = UINavigationController(rootViewController: menuInitialVC)
            mainUINavigationController.isNavigationBarHidden = true
            
            return mainUINavigationController
        } else {
            return authRouter.initialViewController()
        }
    }
    
    // MARK: Authorization controllers
    
    func instantiateLogInViewController(_ router: AuthorizationPrivateRoutingProtocol) -> LogInViewController {
        let logInVC = authorizationStoryboard().instantiateViewController(withIdentifier: "LogInViewController") as! LogInViewController
        logInVC.networkManager = servicesAssembly.networkManager as! AuthorizationNetworkProtocol?
        logInVC.router = router
        logInVC.validator = servicesAssembly.validator
        
        return logInVC
    }
    
    func instantiateCaseSelectionViewController(_ router: AuthorizationRouterProtocol) -> CaseSelectionViewController {
        let caseSelectionVC = authorizationStoryboard().instantiateViewController(withIdentifier: "CaseSelectionViewController") as! CaseSelectionViewController
        caseSelectionVC.bluetoothManager = servicesAssembly.bluetoothManager
        caseSelectionVC.router = router
        caseSelectionVC.networkCaseConnectionManager = servicesAssembly.networkManager as! CaseConnectionProtocol?
        caseSelectionVC.caseLogsCoordinator = servicesAssembly.caseLogsCoordinator
        
        return caseSelectionVC
    }
    
    func instantiateRecoverPasswordViewController(_ router: AuthorizationRouterProtocol) -> RecoverPasswordViewController {
        let recoverPasswordVC = authorizationStoryboard().instantiateViewController(withIdentifier: "RecoverPasswordViewController") as! RecoverPasswordViewController
        recoverPasswordVC.networkManager = servicesAssembly.networkManager as! AuthorizationNetworkProtocol?
        recoverPasswordVC.router = router
        
        return recoverPasswordVC
    }
    
    func instantiateHostnamesViewController(_ router: AuthorizationRouterProtocol) -> HostnamesViewController {
        let hostnamesVC = authorizationStoryboard().instantiateViewController(withIdentifier: "HostnamesViewController") as! HostnamesViewController
        hostnamesVC.networkManager = servicesAssembly.networkManager as! AuthorizationNetworkProtocol?
        hostnamesVC.router = router
        
        return hostnamesVC
    }
    
    func instantiateDoximityProfileLoginViewController(_ router: AuthorizationPrivateRoutingProtocol, viewModel: ProfileFreemiumViewModel) -> DoximityProfileLoginViewController {
        
        let doximityLoginVC = authorizationStoryboard().instantiateViewController(withIdentifier: "DoximityProfileLoginViewController") as! DoximityProfileLoginViewController
        doximityLoginVC.router = router
        doximityLoginVC.networkManager = servicesAssembly.networkManager as! AuthorizationNetworkProtocol?
        doximityLoginVC.viewModel = viewModel
        doximityLoginVC.userManager = servicesAssembly.userManager as! SessionUserProtocol?
        
        return doximityLoginVC
    }
    
    func instantiateProfileLoginViewController(_ router: AuthorizationPrivateRoutingProtocol, viewModel: ProfileEnterpriseViewModel) -> ProfileLoginViewController {
        
        let profileLoginVC = authorizationStoryboard().instantiateViewController(withIdentifier: "ProfileLoginViewController") as! ProfileLoginViewController
        profileLoginVC.router = router
        profileLoginVC.networkManager = servicesAssembly.networkManager as! AuthorizationNetworkProtocol?
        profileLoginVC.viewModel = viewModel
        profileLoginVC.userManager = servicesAssembly.userManager as! SessionUserProtocol?
        
        return profileLoginVC
    }
    
    func instantiateVerifyAccountViewController(_ router: AuthorizationPrivateRoutingProtocol) -> VerifyAccountViewController {
        let doximityVC = authorizationStoryboard().instantiateViewController(withIdentifier: "VerifyAccountViewController") as! VerifyAccountViewController
        doximityVC.router = router
        doximityVC.networkManager = servicesAssembly.networkManager as! AuthorizationNetworkProtocol?
        doximityVC.alertsManager = servicesAssembly.alertsManager
        doximityVC.userManager = servicesAssembly.userManager as! SessionUserProtocol
        doximityVC.duringSignUp = true
        return doximityVC
    }
    
    func instantiatePEVerifVC(_ router: Any) -> PEVerifVC {
        let doximityVC = authorizationStoryboard().instantiateViewController(withIdentifier: "PEVerifVC") as! PEVerifVC
        doximityVC.networkManager = servicesAssembly.networkManager as! AuthorizationNetworkProtocol?
        doximityVC.alertsManager = servicesAssembly.alertsManager
        doximityVC.userManager = servicesAssembly.userManager as! SessionUserProtocol
        doximityVC.duringSignUp = false
        return doximityVC
    }
    
    func instantiateLinkDoximityViewController(_ router: AuthorizationPrivateRoutingProtocol,
                                          linkViewModel: LinkDoximityControllerViewModel) -> LinkDoximityViewController {
        
        let linkDoximityVC = authorizationStoryboard().instantiateViewController(withIdentifier: "LinkDoximityViewController") as! LinkDoximityViewController
        linkDoximityVC.router = router
        linkDoximityVC.networkManager = servicesAssembly.networkManager as! AuthorizationNetworkProtocol?
        linkDoximityVC.alertsManager = servicesAssembly.alertsManager
        linkDoximityVC.userManager = servicesAssembly.userManager as! SessionUserProtocol
        linkDoximityVC.viewModel = linkViewModel
        
        return linkDoximityVC
    }
    
    func instantiateMobileVerificationViewController(_ router: AuthorizationPrivateRoutingProtocol) -> MobileVerificationViewController {
        let mobileVerificationVC = authorizationStoryboard().instantiateViewController(withIdentifier: "MobileVerificationViewController") as! MobileVerificationViewController
        mobileVerificationVC.router = router
        mobileVerificationVC.networkManager = servicesAssembly.networkManager as! AuthorizationNetworkProtocol?
        
        return mobileVerificationVC
    }
    
    func instantiateProfileNotFoundAlertController(_ router: AuthorizationPrivateRoutingProtocol) -> ProfileNotFoundAlertController {
        let profileNotFoundVC = authorizationStoryboard().instantiateViewController(withIdentifier: "ProfileNotFoundAlertController") as! ProfileNotFoundAlertController
        profileNotFoundVC.router = router
        
        return profileNotFoundVC
    }
    func instantiateVerificationInfoAlertController(_ router: AuthorizationPrivateRoutingProtocol) -> ProvideVerificationInfoAlertController {
        let VerificationInfoAlertController = authorizationStoryboard().instantiateViewController(withIdentifier: "ProvideVerificationInfoAlertController") as! ProvideVerificationInfoAlertController
        return VerificationInfoAlertController
    }

    
    
    func instantiateDoximityAuthorizationViewController(_ router: AuthorizationPrivateRoutingProtocol) -> DoximityAuthorizationViewController {
        
        let doximityAuthorizationVC = DoximityAuthorizationViewController()
        doximityAuthorizationVC.router = router
        doximityAuthorizationVC.alertsManager = servicesAssembly.alertsManager
        doximityAuthorizationVC.networkManager = servicesAssembly.networkManager as! AuthorizationNetworkProtocol?
        doximityAuthorizationVC.userManager = servicesAssembly.userManager as! SessionUserProtocol
        
        return doximityAuthorizationVC
    }
    
    func instantiateSignupPEViewController(_ router: AuthorizationPrivateRoutingProtocol) -> SignUpPEViewController {
        let SignUpVC = authorizationStoryboard().instantiateViewController(withIdentifier: "SignUpPEViewController") as! SignUpPEViewController
        SignUpVC.networkManager = servicesAssembly.networkManager as! AuthorizationNetworkProtocol?
        SignUpVC.router = router
        SignUpVC.userManager = servicesAssembly.userManager as? SessionUserProtocol
        SignUpVC.validator = servicesAssembly.validator
        return SignUpVC
    }

    // MARK: Photos controllers
    
    func instantiatePhotosViewController(_ router: PhotosRouterProtocol) -> PhotosViewController {
        let photosVC = photosStoryboard().instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
        photosVC.router = router
        photosVC.bluetoothManager = servicesAssembly.bluetoothManager
        photosVC.networkManager = servicesAssembly.networkManager as! (PhotosNetworkProtocol & InviteUsersProtocol & AuthorizationNetworkProtocol)?
        photosVC.networkCaseConnectionManager = servicesAssembly.networkManager as! CaseConnectionProtocol?
        photosVC.photosProvider = servicesAssembly.photosProvider
        photosVC.notificationManager = servicesAssembly.notificationManager
        photosVC.notificationManager?.delegate = photosVC
        photosVC.userManager = servicesAssembly.userManager as! SessionUserProtocol?
        photosVC.foldersNavigationDataSource = servicesAssembly.foldersNavigationDataSource
        photosVC.alertsManager = servicesAssembly.alertsManager
        photosVC.contactsService = servicesAssembly.contactsService
        photosVC.photoUploadCoordinator = servicesAssembly.photoCoordinator
        photosVC.caseLogsCoordinator = servicesAssembly.caseLogsCoordinator

        return photosVC
    }
    
    func instantiateCameraViewController(_ router: PhotosRouterProtocol, delegate: CameraViewControllerDelegate) -> CameraViewController {
        let cameraVC = photosStoryboard().instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
        cameraVC.router = router
        cameraVC.bluetoothManager = servicesAssembly.bluetoothManager
        cameraVC.networkCaseConnectionManager = servicesAssembly.networkManager as! CaseConnectionProtocol?
        cameraVC.delegate = delegate
        cameraVC.alertsManager = servicesAssembly.alertsManager
        cameraVC.caseLogsCoordinator = servicesAssembly.caseLogsCoordinator

        return cameraVC
    }
    
    func instantiatePhotoLibraryViewController(_ router: PhotosRouterProtocol, delegate: PhotoLibraryViewControllerDelegate) -> PhotoLibraryViewController {
        let photoLibraryVC = photosStoryboard().instantiateViewController(withIdentifier: "PhotoLibraryViewController") as! PhotoLibraryViewController
        photoLibraryVC.delegate = delegate
        photoLibraryVC.router = router
        
        return photoLibraryVC
    }
    
    func instantiateProfileViewController(_ router: PhotosRouterProtocol) -> ProfileViewController {
        let profileVC = photosStoryboard().instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        profileVC.router = router
        profileVC.networkManager = servicesAssembly.networkManager as! (AuthorizationNetworkProtocol & InviteUsersProtocol & PushNotificationProtocol)?
        profileVC.networkCaseConnectionManager = servicesAssembly.networkManager as! CaseConnectionProtocol?
        profileVC.bluetoothManager = servicesAssembly.bluetoothManager
        profileVC.userManager = servicesAssembly.userManager as! SessionUserProtocol?
        profileVC.alertsManager = servicesAssembly.alertsManager
        profileVC.contactsService = servicesAssembly.contactsService
        profileVC.photoCacheService = servicesAssembly.photoCacheService
        profileVC.caseLogsCoordinator = servicesAssembly.caseLogsCoordinator
        profileVC.notificationManager = servicesAssembly.notificationManager as? NotificationManager
        profileVC.nm = servicesAssembly.networkManager as? NetworkManager
        return profileVC
    }
    
    func instantiateFullScreenPhotoViewController(_ router: PhotosRouterProtocol, photo: Photo) -> FullScreenPhotoViewController{
        let fullScreenPhotoVC = FullScreenPhotoViewController(referencedView: nil, image: UIImage(named: "black"))
        fullScreenPhotoVC?.router = router
        fullScreenPhotoVC?.currentPhoto = photo
        fullScreenPhotoVC?.photosProvider = servicesAssembly.photosProvider
        fullScreenPhotoVC?.networkManager = servicesAssembly.networkManager as! (PhotosNetworkProtocol & InviteUsersProtocol & CommentsNetworkProtocol)?
        fullScreenPhotoVC?.userManager = servicesAssembly.userManager as! SessionUserProtocol?
        fullScreenPhotoVC?.alertsManager = servicesAssembly.alertsManager
        fullScreenPhotoVC?.contactsService = servicesAssembly.contactsService
        fullScreenPhotoVC?.photoUploadCoordinator = servicesAssembly.photoCoordinator
        
        return fullScreenPhotoVC!
    }
    
    func instantiateChangePasswordViewController(_ router: PhotosRouterProtocol) -> ChangePasswordViewController {
        let changePasswordVC = photosStoryboard().instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
        changePasswordVC.router = router
        changePasswordVC.networkManager = servicesAssembly.networkManager as! AuthorizationNetworkProtocol?
        changePasswordVC.bluetoothManager = servicesAssembly.bluetoothManager
        changePasswordVC.networkCaseConnectionManager = servicesAssembly.networkManager as! CaseConnectionProtocol?
        changePasswordVC.caseLogsCoordinator = servicesAssembly.caseLogsCoordinator

        return changePasswordVC
    }
    
    func instantiateShareViewController(_ router: PhotosRouterProtocol) -> ShareViewController {
        let shareVC = photosStoryboard().instantiateViewController(withIdentifier: "ShareViewController") as! ShareViewController
        shareVC.router = router
        shareVC.networkManager = servicesAssembly.networkManager as! PhotosNetworkProtocol?
        shareVC.bluetoothManager = servicesAssembly.bluetoothManager
        shareVC.caseLogsCoordinator = servicesAssembly.caseLogsCoordinator

        return shareVC
    }
    
    func instantiateSelectFolderViewController(_ router: PhotosRouterProtocol) -> SelectFolderViewController {
        let selectFolderVC = photosStoryboard().instantiateViewController(withIdentifier: "SelectFolderViewController") as! SelectFolderViewController
        selectFolderVC.networkManager = servicesAssembly.networkManager as! (PhotosNetworkProtocol & InviteUsersProtocol & AuthorizationNetworkProtocol)?
        selectFolderVC.router = router
        selectFolderVC.bluetoothManager = servicesAssembly.bluetoothManager
        selectFolderVC.caseLogsCoordinator = servicesAssembly.caseLogsCoordinator

        return selectFolderVC
    }
    
    func instantiateCommentsViewController(_ router: PhotosRouterProtocol, photo: Photo) -> CommentsViewController {
        let commentsVC = photosStoryboard().instantiateViewController(withIdentifier: "CommentsViewController") as! CommentsViewController
        commentsVC.router = router
        commentsVC.alertsManager = servicesAssembly.alertsManager as? AlertsManager
        commentsVC.networkManager = servicesAssembly.networkManager as! CommentsNetworkProtocol?
        commentsVC.userManager = servicesAssembly.userManager as! SessionUserProtocol?
        commentsVC.bluetoothManager = servicesAssembly.bluetoothManager
        commentsVC.currentPhoto = photo
        commentsVC.caseLogsCoordinator = servicesAssembly.caseLogsCoordinator

        return commentsVC
    }
    
    func instantiateContactsViewController(_ router: PhotosRouterProtocol) -> ContactsViewController {
        let contactsVC = photosStoryboard().instantiateViewController(withIdentifier: "ContactsViewController") as! ContactsViewController
        contactsVC.router = router
        contactsVC.contactsService = servicesAssembly.contactsService
        
        return contactsVC
    }
    
    func instantiateShareContactsAlertViewController(_ router: PhotosRouterProtocol) -> ShareContactsAlertViewController {
        let shareAlertVC = photosStoryboard().instantiateViewController(withIdentifier: "ShareContactsAlertViewController") as! ShareContactsAlertViewController
        shareAlertVC.router = router
        shareAlertVC.validator = servicesAssembly.validator
        shareAlertVC.contactsService = servicesAssembly.contactsService
        
        return shareAlertVC
    }
    
    func instantiateShareUsersAlertViewController(_ router: PhotosRouterProtocol) -> ShareUsersAlertViewController {
        let shareAlertVC = photosStoryboard().instantiateViewController(withIdentifier: "ShareUsersAlertViewController") as! ShareUsersAlertViewController
        shareAlertVC.router = router
        
        return shareAlertVC
    }
    
    func instantiateGroupsViewController(_ router: PhotosRouterProtocol) -> GroupsViewController {
        let groupsVC = photosStoryboard().instantiateViewController(withIdentifier: "GroupsViewController") as! GroupsViewController
        groupsVC.router = router
        groupsVC.networkManager = servicesAssembly.networkManager as! (AuthorizationNetworkProtocol & InviteUsersProtocol & PhotosNetworkProtocol)?
        groupsVC.alertsManager = servicesAssembly.alertsManager
        groupsVC.userManager = servicesAssembly.userManager as! SessionUserProtocol?
        groupsVC.bluetoothManager = servicesAssembly.bluetoothManager
        groupsVC.foldersNavigationDataSource = servicesAssembly.foldersNavigationDataSource
        groupsVC.caseLogsCoordinator = servicesAssembly.caseLogsCoordinator
        groupsVC.photoUploadCoordinator = servicesAssembly.photoCoordinator

        return groupsVC
    }
    
    func instantiateAddMemberAlertViewController(_ router: PhotosRouterProtocol) -> AddMemberAlertViewController {
        let addMembersVC = photosStoryboard().instantiateViewController(withIdentifier: "AddMemberAlertViewController") as! AddMemberAlertViewController
        addMembersVC.router = router
        
        return addMembersVC
    }
    
    // MARK: Menu controllers
    
    func instantiateMainUIViewControllerWith(_ leftMenuViewController: UIViewController, frontViewController: UIViewController) -> MainUIViewController {
        configureLeftMenuViewControllerOptions()
        
        let mainUI = MainUIViewController(mainViewController: frontViewController, leftMenuViewController: leftMenuViewController)
        
        return mainUI
    }
    
    func instantiateMenuViewController(_ router: MenuRouterProtocol) -> MenuViewController {
        let menuVC = menuStoryboard().instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menuVC.router = router
        menuVC.alertsManager = servicesAssembly.alertsManager
        menuVC.bluetoothManager = servicesAssembly.bluetoothManager
        menuVC.networkManager = servicesAssembly.networkManager as! (PhotosNetworkProtocol & AuthorizationNetworkProtocol & PushNotificationProtocol)?
        menuVC.userManager = servicesAssembly.userManager as! SessionUserProtocol?
        menuVC.foldersNavigationDataSource = servicesAssembly.foldersNavigationDataSource
        menuVC.menuNavigationDataSource = servicesAssembly.menuNavigationDataSource
        menuVC.caseLogsCoordinator = servicesAssembly.caseLogsCoordinator
        menuVC.notificationManager = servicesAssembly.notificationManager as? NotificationManager
        menuVC.nm = servicesAssembly.networkManager as? NetworkManager
        return menuVC
    }
    
    func instantiateMenuFoldersViewController(_ router: MenuRouterProtocol) -> MenuFoldersViewController {
        let menuFoldersVC = menuStoryboard().instantiateViewController(withIdentifier: "MenuFoldersViewController") as! MenuFoldersViewController
        menuFoldersVC.router = router
        menuFoldersVC.networkManager = servicesAssembly.networkManager as! (PhotosNetworkProtocol & AuthorizationNetworkProtocol & PushNotificationProtocol)?
        menuFoldersVC.bluetoothManager = servicesAssembly.bluetoothManager
        menuFoldersVC.foldersNavigationDataSource = servicesAssembly.foldersNavigationDataSource
        menuFoldersVC.menuNavigationDataSource = servicesAssembly.menuNavigationDataSource
        menuFoldersVC.notificationManager = servicesAssembly.notificationManager as? NotificationManager
        return menuFoldersVC
    }
    
    func instantiateEditPhotoViewController(_ router: PhotosRouterProtocol, photo: Photo, in folder: Folder?) -> EditPhotoViewController {
        let editPhotoVC = photosStoryboard().instantiateViewController(withIdentifier: "EditPhotoViewController") as! EditPhotoViewController
        editPhotoVC.router = router
        editPhotoVC.bluetoothManager = servicesAssembly.bluetoothManager
        editPhotoVC.photo = photo
        editPhotoVC.selectedFolderToSave = folder
        editPhotoVC.caseLogsCoordinator = servicesAssembly.caseLogsCoordinator

        return editPhotoVC
    }
    
    // MARK: Storyboards
    
    func authorizationStoryboard() -> UIStoryboard {
        let storyboard = UIStoryboard(name: "Authorization", bundle: nil)
        
        return storyboard
    }
    
    func photosStoryboard() -> UIStoryboard {
        let storyboard = UIStoryboard(name: "Photos", bundle: nil)
        
        return storyboard
    }
    
    func menuStoryboard() -> UIStoryboard {
        let storyboard = UIStoryboard(name: "Menu", bundle: nil)
        
        return storyboard
    }
    
    // MARK: Private
    
    private func configureLeftMenuViewControllerOptions() {
        SlideMenuOptions.hideStatusBar = false
        SlideMenuOptions.contentViewScale = slideMenuContentViewScale
        SlideMenuOptions.animationDuration = slideMenuAnimationDuration
        SlideMenuOptions.simultaneousGestureRecognizers = false
        
        if let window = UIApplication.shared.windows.first {
            let screenWidth = window.frame.width
            SlideMenuOptions.leftViewWidth = (screenWidth - slideMenuLeftViewTralling)
        }
    }
    
}
