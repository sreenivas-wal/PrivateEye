//
//  BaseViewController.swift
//  MyMobileED
//
//  Created by Admin on 1/20/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, BluetoothManagerDelegate, HeaderBarDelegate {
    var iconClick = true
    var popUpView: PopUpView?
    var bluetoothManager: BluetoothManagerProtocol?
    var networkCaseConnectionManager: CaseConnectionProtocol?
    var caseLogsCoordinator: CaseLogsCoordinatorProtocol?

    @IBOutlet weak var headerBar: HeaderBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerBar?.delegate = self

        subscribeToKeyboardNotifications()
        headerBar?.nearToLeftButtonHide = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupBluetoothManagerDelegateIfNeeded()

        if let isConnected = bluetoothManager?.isConnected() {
            self.setupSecureIconState(isConnected: isConnected)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        var keyboardFrame: CGRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        if popUpView?.superview == self.view {
            let yPosition = self.view.bounds.size.height - popUpView!.height() - keyboardFrame.height
            
            popUpView?.frame = CGRect(x: 0, y: yPosition,
                                      width: popUpView!.frame.width,
                                      height: popUpView!.frame.height)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if popUpView?.superview == self.view {
            let yPosition = self.view.bounds.size.height - popUpView!.height()
            popUpView?.frame = CGRect(x: 0, y: yPosition,
                                      width: popUpView!.frame.width,
                                      height: popUpView!.frame.height)
        }
    }
    
    func presentAlert(withMessage message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showUnsecureConnectionView(withConnectionState state: ConnectionViewState, completionBlock block: @escaping (() -> ())) {
        popUpView?.removeFromSuperview()
        popUpView = nil
        
        var viewHeight: CGFloat = 0.0
        
        switch state {
        case .noCaseConnection:
            viewHeight = CaseConnectionView.noConnectionHeight()
            break
        case .unsecureConnection:
            viewHeight = CaseConnectionView.unsecureConnectionHeight()
            break
        }
        
        if popUpView == nil || (popUpView as? CaseConnectionView) == nil {
            let caseConnectionHeight: CGFloat = viewHeight
            let yPosition = self.view.bounds.height - caseConnectionHeight
            let caseConnectionView = CaseConnectionView(frame: CGRect(x: 0, y: yPosition, width: self.view.bounds.size.width, height: caseConnectionHeight))
            caseConnectionView.setupConnectionViewState(state: state)
            
            caseConnectionView.cancelButtonTapCallback = {
                self.popUpView?.hideView(fromView: self.view)
            }
            
            caseConnectionView.connectButtonTapCallback = {
                self.popUpView?.hideView(fromView: self.view)
                block()
            }
            
            self.popUpView = caseConnectionView
        }
        
        popUpView?.show(fromView: self.view)
        
        self.log(connectionState: state)
    }
    
    func sendCaseDisconnectedRequest() {
        self.networkCaseConnectionManager?.caseDisconnected({ (response) -> (Void) in
            print("Case disconnected response = \(response)")
        }, failureBlock: { (error) -> (Void) in
            print("Case disconnected error = \(error.message)")
        })
    }
        
    // MARK: -
    // MARK: BluetoothManagerDelegate
    func failureConnection() {
        self.setupSecureIconState(isConnected: false)
        
        self.networkCaseConnectionManager?.bluetoothDisconnected({ (response) -> (Void) in
            print("Bluetooth disconnected response = \(response)")
        }, failureBlock: { (error) -> (Void) in
            print("Bluetooth disconnected error = \(error.message)")
        })
    }
    
    func successConnection() {
        self.networkCaseConnectionManager?.bluetoothConnected({ (response) -> (Void) in
            print("Bluetooth connected response = \(response)")
        }, failureBlock: { (error) -> (Void) in
            print("Bluetooth connected error = \(error.message)")
        })
    }
    
    func unsecureConnection() {
        setupSecureIconState(isConnected: false)
        sendCaseDisconnectedRequest()
    }

    func showPurchaseCaseView() {
        popUpView?.removeFromSuperview()
        
        let purchaseViewHeight: CGFloat = PurchaseCaseView.viewHeight()
        let yPosition = self.view.bounds.size.height - purchaseViewHeight
        let purchaseView = PurchaseCaseView(frame: CGRect(x: 0, y: yPosition, width: self.view.bounds.size.width, height: purchaseViewHeight))
        purchaseView.okayButtonTapCallback = {
            purchaseView.hideView(fromView: self.view)
        }
        purchaseView.openURLTapCallback = { (url: URL) in
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
        }
        
        self.popUpView = purchaseView
        popUpView?.show(fromView: self.view)

    }
    
    func verifyNow(router: PhotosRouterProtocol){
        router.showPEVerificationViewController(fromViewController: self, navigationController: self.navigationController!, withAnimation: false)
    }
    
    func setupBluetoothManagerDelegateIfNeeded() {
        bluetoothManager?.delegate = self
    }

    // MARK: - Private
    private func setupSecureIconState(isConnected: Bool) {
        headerBar?.secureButtonUserInteractionEnabled = isConnected
        headerBar?.secureButtonImage = UIImage(named: (isConnected ? "lock" : "lockOpen"))
    }
    
    fileprivate func log(connectionState state: ConnectionViewState) {
        
        if let requiredCaseLogsCoordinator = self.caseLogsCoordinator {
            
            let action: CaseLog.Action
            switch state {
            case .noCaseConnection:     action = .caseNotConnected
            case .unsecureConnection:   action = .connectionUnsecure
            }
            
            let caseLog = CaseLog(with: action,
                       actionTimestamp: Date().timeIntervalSince1970.description,
                           geolocation: LocationService().currentLocationDescription())
            
            requiredCaseLogsCoordinator.upload(caselog: caseLog)
        }
    }
//    func removeDeviceToken(notificationManager: NotificationManager?,networkManager:NetworkManager?){
//        let deviceToken = UserDefaults.standard.data(forKey: "DeviceToken")
//        if deviceToken != nil {
//            let deviceTokenString = notificationManager?.convertDeviceTokenData(dataDeviceToken: deviceToken!)
//            if deviceTokenString != nil && (deviceTokenString?.count)! > 0{
//                networkManager?.deRegisterDeviceToken(deviceTokenString: deviceTokenString!, successBlock: { (response) -> (Void) in
//                    print("The token was successfully removed ")
//                }, failureBlock: { (error) -> (Void) in
//                    self.presentAlert(withMessage: error.message)
//                    print("\(error)")
//                })
//            }
//        }
//    }
    
    // MARK: HeaderBarDelegate
    
    func headerBar(_ header: HeaderBar, didTapSecureButton secure: UIButton) {
        showPurchaseCaseView()
    }    
}
