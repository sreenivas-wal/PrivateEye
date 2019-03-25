//
//  ProfileViewController.swift
//  MyMobileED
//
//  Created by Admin on 1/25/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

class ProfileViewController: BaseViewController, ProfileTableViewCellDelegate, UITableViewDataSource, UITableViewDelegate {

    enum ProfileCellTitle: Int {
        case username
        case email
        case phone
        case company
        case organization
        case hostlink
        
        var title: String {
            switch self {
                case .username: return "Username"
                case .email: return "Email"
                case .phone: return "Phone"
                case .company: return "Company"
                case .organization: return "Organization"
                case .hostlink: return "Host Domain Name"
            }
        }
    }
    
    enum SettingsCellTitle: Int {
        case bluetooth
        case touchID
        case inviteUser
        case password
        case support
        case logout
        case notifications

        var title: String {
            switch self {
                case .bluetooth: return "Bluetooth Devices"
                case .touchID: return "Touch ID"
                case .inviteUser: return "Invite User"
                case .password: return "Change Password"
                case .support: return "Support"
                case .logout: return "Logout"
                case .notifications: return "Notifications"
            }
        }
    }
    
    private let sectionsCount = 2
    private let profileSection = 0
    private let settingsSection = 1
    private let profileCellsCount = 6
    private let settingsCellsCount = 7
    private let estimatedTableViewRowHeight: CGFloat = 60.0
    private let estimatedHeaderHeight: CGFloat = 60.0
    private var currentUser: Profile?
    private var authentificationHelper = AuthentificationHelper()
    
    @IBOutlet weak var tableView: UITableView!
    var router: PhotosRouterProtocol?
    var networkManager: (AuthorizationNetworkProtocol & InviteUsersProtocol & PushNotificationProtocol)?
    var userManager: SessionUserProtocol?
    var alertsManager: AlertsManagerProtocol?
    var contactsService: ContactsServiceProtocol?
    var photoCacheService: PhotoCacheServiceProtocol!
    var notificationManager: NotificationManager?
    var nm: NetworkManager?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        subscribeToNotifications()
        
        self.currentUser = userManager?.retriveProfile()
        
        networkManager?.getProfileInformation(successBlock: { (response) -> (Void) in
            self.currentUser = response.object as? Profile
            self.tableView.reloadData()
        }, failureBlock: { (error) -> (Void) in
            print("Error = \(error.message)")
        })
    }
    
    func didBecomeActive(_ notification: NSNotification) {
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .lightContent
    }

    // MARK: Overriden

    override func unsecureConnection() {
        super.unsecureConnection()

        showUnsecureConnectionView(withConnectionState: .unsecureConnection, completionBlock: { [unowned self] in
            self.router?.showBluetoothViewController(fromViewController: self, withAnimation: true)
        })
    }

    // MARK: Private
    
    private func setupTableView() {
        tableView.estimatedRowHeight = estimatedTableViewRowHeight
        tableView.register(UINib(nibName: "ProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfileTableViewCell")
        tableView.register(UINib(nibName: "ProfileHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfileHeaderTableViewCell")
    }
    
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive(_:)), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    private func proceedTouchIDAction() {
        if self.authentificationHelper.isLocalAuthentificationEnabled() {
            let url = URL.touchIDSettingsUrl()
            
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
        } else {
            let alert = UIAlertController.authentificationErrorAlertController()
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func proceedLogoutAction() {
        nm?.logOut(bluetoothManager: self.bluetoothManager!)
    }
    
    private func showInviteAlertController() {
        let inviteMessage = "Invite another user to join PrivateEyeHC by:"
        
        alertsManager?.showInviteAlertController(forViewController: self, withMessage: inviteMessage, withDoximityInviteHandler: { [unowned self] () -> (Void) in
            self.networkManager?.inviteUserInDoximity()
            }, withEmailInviteHandler: { [unowned self] () -> (Void) in
            
            let screenViewModel = ShareContactsAlertViewControllerViewModel(actionTitle: "OK",
                                                     userDisplayingInformationViewModel: UserDisplayingInformationViewModel.inviteMembersByEmailsViewModel(),
                                                                         displayingInfo: .emails)

            self.router?.showShareContactsAlertViewController(fromViewController: self,
                                                                   withAnimation: true,
                                                                       viewModel: screenViewModel,
                                                                   shareCallback: { (emails, viewController) -> () in
                                                                
                                                                        self.inviteUsers(byEmails: emails)
                                                                        viewController.dismiss(animated: true, completion: nil)
                                                                   })
        }, textInviteHandler: { [unowned self] () -> (Void) in

            let screenViewModel = ShareContactsAlertViewControllerViewModel(actionTitle: "OK",
                                                    userDisplayingInformationViewModel: UserDisplayingInformationViewModel.inviteMemberBySMSViewModel(),
                                                                        displayingInfo: .phones)

            self.router?.showShareContactsAlertViewController(fromViewController: self,
                                                                   withAnimation: true,
                                                                       viewModel: screenViewModel,
                                                                   shareCallback: { (phones, viewController) -> () in

                                                                       var clearPhones: [String] = []

                                                                       for phone in phones {
                                                                        
                                                                           let clearResult = phone.filter({
                                                                              String($0).rangeOfCharacter(from: CharacterSet(charactersIn: "0123456789")) != nil
                                                                           })
                                                                        
                                                                           clearPhones.append(String(clearResult))
                                                                       }
    
                                                                       self.inviteUsers(byPhones: clearPhones)
                                                                       viewController.dismiss(animated: true, completion: nil)
                                                                   })
        })
    }
    
    private func inviteUsers(byEmails emails: [String]) {
        networkManager?.inviteUsers(byEmails: emails,
                                successBlock: { (response) -> (Void) in
                                    DispatchQueue.main.async { self.alertsManager?.showSuccessInviteAlertController(forViewController: self) }
                                },
                                failureBlock: { (response) -> (Void) in
                                    DispatchQueue.main.async {
                                        
                                        let error: String = response.code == 406 ? "You have already invited this user(s)" : response.message
                                        self.presentAlert(withMessage: error)
                                    }
                                })
    }
    
    private func inviteUsers(byPhones phones: [String]) {
        
        networkManager?.inviteUsers(byPhones: phones,
                                    successBlock: { (response) -> () in
                                        DispatchQueue.main.async { self.alertsManager?.showSuccessInviteAlertController(forViewController: self)  }
                                    },
                                    failureBlock: { (response) -> () in
                                        DispatchQueue.main.async {
                                            let object = response.json.object as? [String]
                                            let errorMessage = object![0]
                                            let error: String = response.code == 406 ? errorMessage : response.message
                                            self.presentAlert(withMessage: error)
                                        }
                                    })
    }
    
    // MARK: UITableViewDelegate & UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == profileSection {
            return profileCellsCount
        } else {
            return settingsCellsCount
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell") as! ProfileTableViewCell
        cell.delegate = self
        
        let profileViewModel = ProfileViewModel()
        
        if indexPath.section == profileSection {
            let item: ProfileCellTitle = ProfileCellTitle(rawValue: row)!
            profileViewModel.title = item.title
            
            var textValue: String = ""
            var isEditable: Bool = false
            
            if let profile = currentUser {
                switch item {
                case .username:
                    if let username = profile.username {
                        textValue = username
                    }
                    
                    isEditable = true
                    
                    break
                case .email:
                    if let email = profile.email {
                        textValue = email
                    }

                    break
                case .phone:
                    if let phone = profile.phone {
                        textValue = phone
                    }

                    break
                case .company:
                    if let company = profile.company {
                        textValue = company
                    }

                    break
                case .organization:
                    if let organization = profile.organization {
                        textValue = organization
                    }

                    break
                case .hostlink:
                    if let hostDomainName = userManager?.hostname?.subdomainName() {
                        textValue = hostDomainName
                    }
                    
                    break
                }
            }
            
            profileViewModel.value = textValue
            profileViewModel.isEditable = isEditable
        } else {
            let item = SettingsCellTitle(rawValue: row)
            profileViewModel.title = item?.title
        }
        
        cell.configureProfileCell(with: profileViewModel)
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section

        if section == profileSection {
            let item: ProfileCellTitle = ProfileCellTitle(rawValue: indexPath.row)!
            
            switch item {
            case .username:
                let cell = tableView.cellForRow(at: indexPath) as! ProfileTableViewCell
                cell.valueTextField.becomeFirstResponder()
                
                break
            case .email, .phone, .company, .organization, .hostlink:
                break
            }
        } else if section == settingsSection {
            let item: SettingsCellTitle = SettingsCellTitle(rawValue: indexPath.row)!
            
            switch item {
            case .bluetooth:
                DispatchQueue.main.async {
                    self.router?.showBluetoothViewController(fromViewController: self, withAnimation: true)
                }
                
            case .touchID:
                DispatchQueue.main.async {
                    self.proceedTouchIDAction()
                }

            case .inviteUser:
                DispatchQueue.main.async {
                    self.showInviteAlertController()
                }
                
            case .password:
                DispatchQueue.main.async {
                    self.router?.showChangePasswordViewController(fromViewController: self, withAnimation: true)
                }
                
            case .support:
                let supportUrl = URL.supportUrl(fromHostLink: userManager!.hostname!.fullHostDomainLink())
                
                if UIApplication.shared.canOpenURL(supportUrl) {
                    UIApplication.shared.openURL(supportUrl)
                }
                
            case .logout:
                proceedLogoutAction()
                
            case .notifications:
                self.router?.showNotificationSettings(from: self, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderTableViewCell") as! ProfileHeaderTableViewCell
        
        switch section {
        case 0:
            header.headerTitleLabel.text = "PROFILE"
            break
        case 1:
            header.headerTitleLabel.text = "SETTINGS"
            break
        default:
            break
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return estimatedHeaderHeight
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    // MARK: ProfileTableViewCellDelegate
    
    func profileTableViewCell(_ cell: ProfileTableViewCell, didEndEditingField value: String) {
        let indexPath = tableView.indexPath(for: cell)
        
        if let index = indexPath?.row {
            let item: ProfileCellTitle = ProfileCellTitle(rawValue: index)!
            var newProfile: Profile?
            
            switch item {
            case .username:
                newProfile = Profile(username: value, phone: nil)!
                break
            case .email, .phone, .company, .organization, .hostlink:
                break
            }
            newProfile?.username = newProfile?.username?.replacingOccurrences(of: "\u{00a0}", with: " ")
            self.networkManager?.changeProfileInformation(newProfile!, successBlock: { (response) -> (Void) in
                if let profile = newProfile {
                    self.userManager?.saveProfile(profile)
                    let encodedProfle = NSKeyedArchiver.archivedData(withRootObject: profile)
                    UserDefaults.standard.set(encodedProfle, forKey: "Profile")
                }
            }, failureBlock: { (error) -> (Void) in
                print("Error = \(error.message)")
                let message = (((error.json["form_errors"]["name"]).string!).html2Attributed)?.string

                if error.code == 406 && (error.json["form_errors"]["name"]) != nil {
                    self.alertsManager?.showAlert(forViewController: self, withTitle: "Error", message: message!)
                } else {
                    self.alertsManager?.showAlert(forViewController: self, withTitle: "Error", message: error.message)
                }
            })
        }
    }

    // MARK: HeaderBarDelegate
    func headerBar(_ header: HeaderBar, didTapLeftButton left: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}

