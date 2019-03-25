//
//  AppDelegate.swift
//  MyMobileED
//
//  Created by Admin on 17.08.15.
//  Copyright (c) 2015 Company. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var applicationRouter: ApplicationRouter?
    var applicationAssembly: ApplicationAssembly?
    let defaults = UserDefaults.standard
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        setupDependencies()
        return true
    }
    
    func setupDependencies() {
        self.applicationAssembly = ApplicationAssembly()
        self.applicationRouter = ApplicationRouter(scenesAssembly: applicationAssembly!.scenesAssembly, servicesAssembly: applicationAssembly!.servicesAssembly)
        self.applicationAssembly?.servicesAssembly.photosProvider?.deleteOldPhotos()
        let authRouter = applicationRouter?.authorizationStoryRouter
        let menuRouter = applicationRouter?.menuStoryRouter
        self.window?.rootViewController = applicationAssembly?.scenesAssembly.instantiateInitialViewController(authRouter!, menuRouter: menuRouter!)
        self.window?.makeKeyAndVisible()
        setupScreenshotNotification()
        if self.applicationAssembly?.servicesAssembly.userManager?.isCurrentUserAuthorized() == false {
            if let requiredPhotoCacheService = self.applicationAssembly?.servicesAssembly.photoCacheService {
                requiredPhotoCacheService.clearAllInformation(successBlock: {},
                                                              failureBlock: { _ in })
            }
            if let requiredCaseLogsCacheService = self.applicationAssembly?.servicesAssembly.caseLogsCacheService {
                requiredCaseLogsCacheService.clearAllCache()
            }
        }
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalNever)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        let presentVC = self.applicationRouter?.visibleViewController(self.window?.rootViewController)
        if let userStatus = (defaults.value(forKey: "UserRole")) as? String {
            if userStatus == "in_progress" || userStatus == "unverified" {
                let networkManager = NetworkManager()
                networkManager.getProfileInformation(successBlock: { (response) -> (Void) in
                    let UpdatedStatus = (response.json["field_verification"]["und"][0]["value"]).string
                    if userStatus != UpdatedStatus {
                        self.defaults.set(UpdatedStatus, forKey: "UserRole")
                        let userManager = self.applicationAssembly?.servicesAssembly.userManager as? SessionUserProtocol
                        userManager?.currentUser?.userRole = UpdatedStatus
                    }
                }) { (response) -> (Void) in
                    let alert = UIAlertController(title: "Error", message: response.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
                        
                    }))
                    presentVC?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    // MARK: - Push Notifications
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("User info = \(userInfo)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let notificationManager = applicationAssembly?.servicesAssembly.notificationManager
        defaults.set(deviceToken, forKey: "DeviceToken")
        defaults.synchronize()
        notificationManager?.subscribeToPushNotification(withDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        applicationRouter?.handleOpenUrl(url, options: options)
        
        return true
    }
    
    // MARK: - Private
    
    private func setupScreenshotNotification() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationUserDidTakeScreenshot, object: nil, queue: OperationQueue.main,
                                               using: { (notification) in
                                                
                                                self.showScreenshotAlert()
                                                self.logScreenshotAction()
        })
    }
    
    private func showScreenshotAlert() {
        
        let visibleViewController = self.applicationRouter?.visibleViewController(self.window?.rootViewController)
        let dispatchWork = DispatchWorkItem { visibleViewController?.dismiss(animated: true, completion: nil) }
        let alert = UIAlertController(title: "Screenshot logged",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
            dispatchWork.cancel()
        }))
        
        visibleViewController?.present(alert, animated: true, completion: nil)
        
        let timeForClose = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: timeForClose, execute: dispatchWork)
    }
    
    private func logScreenshotAction() {
        
        guard let requiredCaseLogsCoordinator = self.applicationAssembly?.servicesAssembly.caseLogsCoordinator else { return }
        
        let caseLog = CaseLog(with: CaseLog.Action.screenShot,
                              actionTimestamp: Date().timeIntervalSince1970.description,
                              geolocation: LocationService().currentLocationDescription())
        
        requiredCaseLogsCoordinator.upload(caselog: caseLog)
    }
}
