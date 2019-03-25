//
//  ScenesAssemblyProtocol.swift
//  MyMobileED
//
//  Created by Admin on 1/13/17.
//
//

import UIKit

protocol ScenesAssemblyProtocol: class {
    
    var servicesAssembly: ServicesAssemblyProtocol { get }
    
    func instantiateInitialViewController(_ authRouter: AuthorizationRouterProtocol, menuRouter: MenuRouterProtocol) -> UIViewController
    
    // Authorization
    func instantiateLogInViewController(_ router: AuthorizationPrivateRoutingProtocol) -> LogInViewController
    func instantiateCaseSelectionViewController(_ router: AuthorizationRouterProtocol) -> CaseSelectionViewController
    func instantiateRecoverPasswordViewController(_ router: AuthorizationRouterProtocol) -> RecoverPasswordViewController
    func instantiateHostnamesViewController(_ router: AuthorizationRouterProtocol) -> HostnamesViewController
    func instantiateDoximityProfileLoginViewController(_ router: AuthorizationPrivateRoutingProtocol, viewModel: ProfileFreemiumViewModel) -> DoximityProfileLoginViewController
    func instantiateProfileLoginViewController(_ router: AuthorizationPrivateRoutingProtocol, viewModel: ProfileEnterpriseViewModel) -> ProfileLoginViewController
    func instantiateVerifyAccountViewController(_ router: AuthorizationPrivateRoutingProtocol) -> VerifyAccountViewController
    func instantiatePEVerifVC(_ router: Any) -> PEVerifVC
    func instantiateLinkDoximityViewController(_ router: AuthorizationPrivateRoutingProtocol,
                                          linkViewModel: LinkDoximityControllerViewModel) -> LinkDoximityViewController

    func instantiateMobileVerificationViewController(_ router: AuthorizationPrivateRoutingProtocol) -> MobileVerificationViewController
    func instantiateProfileNotFoundAlertController(_ router: AuthorizationPrivateRoutingProtocol) -> ProfileNotFoundAlertController
    func instantiateVerificationInfoAlertController(_ router: AuthorizationPrivateRoutingProtocol) -> ProvideVerificationInfoAlertController
    func instantiateDoximityAuthorizationViewController(_ router: AuthorizationPrivateRoutingProtocol) -> DoximityAuthorizationViewController
    func instantiateSignupPEViewController(_ router: AuthorizationPrivateRoutingProtocol) -> SignUpPEViewController
    // Photos
    func instantiatePhotosViewController(_ router: PhotosRouterProtocol) -> PhotosViewController
    func instantiateProfileViewController(_ router: PhotosRouterProtocol) -> ProfileViewController
    func instantiateCameraViewController(_ router: PhotosRouterProtocol, delegate: CameraViewControllerDelegate) -> CameraViewController
    func instantiatePhotoLibraryViewController(_ router: PhotosRouterProtocol, delegate: PhotoLibraryViewControllerDelegate) -> PhotoLibraryViewController
    func instantiateShareViewController(_ router: PhotosRouterProtocol) -> ShareViewController
    func instantiateSelectFolderViewController(_ router: PhotosRouterProtocol) -> SelectFolderViewController
    func instantiateEditPhotoViewController(_ router: PhotosRouterProtocol, photo: Photo, in folder: Folder?) -> EditPhotoViewController
    func instantiateChangePasswordViewController(_ router: PhotosRouterProtocol) -> ChangePasswordViewController
    func instantiateFullScreenPhotoViewController(_ router: PhotosRouterProtocol, photo: Photo) -> FullScreenPhotoViewController
    func instantiateCommentsViewController(_ router: PhotosRouterProtocol, photo: Photo) -> CommentsViewController
    func instantiateContactsViewController(_ router: PhotosRouterProtocol) -> ContactsViewController
    func instantiateShareContactsAlertViewController(_ router: PhotosRouterProtocol) -> ShareContactsAlertViewController
    func instantiateShareUsersAlertViewController(_ router: PhotosRouterProtocol) -> ShareUsersAlertViewController
    func instantiateGroupsViewController(_ router: PhotosRouterProtocol) -> GroupsViewController
    func instantiateAddMemberAlertViewController(_ router: PhotosRouterProtocol) -> AddMemberAlertViewController
    
    // Menu
    func instantiateMainUIViewControllerWith(_ rearViewController: UIViewController, frontViewController: UIViewController) -> MainUIViewController
    func instantiateMenuViewController(_ router: MenuRouterProtocol) -> MenuViewController
    func instantiateMenuFoldersViewController(_ router: MenuRouterProtocol) -> MenuFoldersViewController
}
