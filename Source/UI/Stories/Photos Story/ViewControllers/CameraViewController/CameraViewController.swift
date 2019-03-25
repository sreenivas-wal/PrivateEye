//
//  CameraViewController.swift
//  MyMobileED
//
//  Created by Admin on 1/23/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import AVFoundation
import MBProgressHUD

protocol CameraViewControllerDelegate: class {
    func cameraViewController(_ sender: CameraViewController, didAddPhotoToFolder folder: Folder?)
    func cameraViewControllerUnsecureConnection(_ sender: CameraViewController)
    func cameraViewControllerDidConnectionError()
    
    func cameraViewController(_ sender: CameraViewController,
                      didTapSave photo: Photo,
                           resultBlock: @escaping PhotoCoordinatorResultBlock) -> ()
}

class CameraViewController: BaseViewController, SelectFolderViewControllerDelegate, FullScreenPhotoViewControllerDelegate {

    private let previewPhotoTimeInterval: TimeInterval = 1.5
    
    private enum FlashState {
        case on
        case off
    }
    
    private enum Camera {
        case back
        case front
    }
    
    @IBOutlet weak var captureView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var makePhotoButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var swiftCameraButton: UIButton!
    @IBOutlet fileprivate weak var previewView: PreviewView!

    private var captureSession: AVCaptureSession?
    private var stillImageOutput: AVCaptureStillImageOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var backCamera: AVCaptureDevice?
    private var flashState: FlashState = .off
    
    private var cameraPositionState: Camera = .back
    private var deviceInput: AVCaptureDeviceInput?
    
    private var photoPreviewTimer: Timer?
    private var currentPhoto: Photo?
    private var updatedPhoto: Photo!
    
    weak var delegate: CameraViewControllerDelegate?
    var router: PhotosRouterProtocol?
    var selectedFolder: Folder?
    var group: Group?
    var alertsManager: AlertsManagerProtocol?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerNotification()

        previewView.onSelectShowPreview = { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.router?.showFullScreenViewControler(fromViewController: strongSelf,
                                                                withAnimation: false,
                                                                 currentPhoto: strongSelf.updatedPhoto,
                                                                      canEdit: true,
                                                                           in: strongSelf.selectedFolder,
                                                                photoDelegate: strongSelf)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupCaptureSession()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideStatusBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        bluetoothManager?.sendSignalClose()
        super.viewWillDisappear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print(String(describing: self))
    }

    private func hideStatusBar() {
        UIApplication.shared.isStatusBarHidden = true

        if let validPreviewLayer = previewLayer {
            validPreviewLayer.frame = captureView.bounds
        }
    }
    
    // MARK: - Actions
    
    @IBAction func closeCameraButtonTapped(_ sender: Any) {
        UIApplication.shared.isStatusBarHidden = false
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonChangeCameraTapped(_ sender: Any) {
        var device: AVCaptureDevice = backCamera!
        
        captureSession?.removeInput(deviceInput)
        
        if cameraPositionState == .back {
            device = switchToFrontCamera()
        } else {
            device = switchToBackCamera()
        }

        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: device)
            deviceInput = input
        } catch let inputError as NSError {
            error = inputError
            input = nil
        }
        
        if error == nil && captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
        }
    }
    
    @IBAction func buttonFlashTapped(_ sender: Any) {
        if backCamera!.hasTorch && backCamera!.hasFlash {
            try? backCamera?.lockForConfiguration()
            
            if flashState == .off {
                backCamera?.flashMode = .on
                flashState = .on
                
                setupFlashButtonStateEnable()
            } else {
                backCamera?.flashMode = .off
                flashState = .off

                setupFlashButtonStateDisable()
            }
            
            backCamera!.unlockForConfiguration()
        }
    }

    @IBAction func makePhotoButtonTapped(_ sender: Any) {
        if let imageOutput = stillImageOutput {
            self.view.isUserInteractionEnabled = false
            
            if let videoConnection = imageOutput.connection(withMediaType: AVMediaTypeVideo) {
                videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
                
                stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { [unowned self] (sampleBuffer, error) in
                    if (sampleBuffer != nil) {
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                        let imageFixed = self.fixedImageOrientation(UIImage(data: imageData!)!)

                        self.showPreviewPhoto(withImage: imageFixed)
                        
                        let photo = Photo(image: imageFixed)
                        photo.folderID = self.selectedFolder?.folderID
                        self.currentPhoto = photo
                        
                        self.photoPreviewTimer = Timer.scheduledTimer(timeInterval: self.previewPhotoTimeInterval,
                                                                      target: self,
                                                                      selector: #selector(self.updatePreviewPhotoTimer),
                                                                      userInfo: nil,
                                                                      repeats: false)
                        
                        self.captureSession?.stopRunning()
                    }
                })
            }
        }
    }
    
    func updatePreviewPhotoTimer() {
        photoPreviewTimer?.invalidate()
        photoPreviewTimer = nil
        
        self.view.isUserInteractionEnabled = true
        self.showEditView()
        
        setupControlsVisibility(isHidden: false)
    }

    // MARK: - Private
    // MARK: Notifications
    
    private func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground(_:)), name: .UIApplicationDidEnterBackground, object: nil)
    }
    
    @objc private func didEnterBackground(_ notification: Notification) {
        bluetoothManager?.sendSignalClose()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Camera
    
    private func setupCaptureSession () {
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        let backCamera = switchToBackCamera()
        self.backCamera = backCamera
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
            deviceInput = input
        } catch let inputError as NSError {
            error = inputError
            input = nil
        }
        
        if error == nil && captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            
            if captureSession!.canAddOutput(stillImageOutput) {
                captureSession!.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                captureView.layer.addSublayer(previewLayer!)
                
                captureSession!.startRunning()
            }
        }
    }
    
    private func fixedImageOrientation(_ image: UIImage) -> UIImage {
        var transform: CGAffineTransform = CGAffineTransform.identity
        let ctx: CGContext = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height),
                                       bitsPerComponent: image.cgImage!.bitsPerComponent, bytesPerRow: 0,
                                       space: image.cgImage!.colorSpace!,
                                       bitmapInfo: image.cgImage!.bitmapInfo.rawValue)!
        
        transform = transform.translatedBy(x: 0, y: image.size.height);
        transform = transform.rotated(by: CGFloat(-Double.pi / 2));
        ctx.concatenate(transform)
        ctx.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
        
        return UIImage(cgImage: ctx.makeImage()!)
    }
    
    private func switchToFrontCamera() -> AVCaptureDevice {
        let frontCamera = (AVCaptureDevice.devices() as? [AVCaptureDevice])?
            .filter({ $0.hasMediaType(AVMediaTypeVideo) && $0.position == .front}).first
        
        flashButton.isEnabled = false
        cameraPositionState = .front
        flashState = .off
        setupFlashButtonStateDisable()
        
        return frontCamera!
    }
    
    private func switchToBackCamera() -> AVCaptureDevice {
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        flashButton.isEnabled = true
        cameraPositionState = .back
        
        try? backCamera?.lockForConfiguration()
        guard (backCamera?.hasFlash)! else {
            backCamera?.unlockForConfiguration()
            return backCamera!
        }

        backCamera?.flashMode = .off
        backCamera?.unlockForConfiguration()

        return backCamera!
    }
    
    private func setupFlashButtonStateEnable() {
        let flashImage = UIImage(named: "camera-light")
        flashButton.setImage(flashImage, for: .normal)
        flashButton.imageEdgeInsets = UIEdgeInsetsMake(14, 14, 22, 14)
    }
    
    private func setupFlashButtonStateDisable() {
        let disableFlashImage = UIImage(named: "disable-flash")
        flashButton.setImage(disableFlashImage, for: .normal)
        flashButton.imageEdgeInsets = UIEdgeInsetsMake(14, 10, 10, 10)
    }

    private func retakePhoto() {
        captureSession!.startRunning()
        imageView.isHidden = true
        imageView.image = nil
    }
    
    private func showEditView() {
        popUpView?.removeFromSuperview()
        
        let editViewHeight: CGFloat = EditView.viewHeight()
        let yPosition = self.view.bounds.size.height - editViewHeight
        let editView = EditView(frame: CGRect(x: 0, y: yPosition, width: self.view.bounds.size.width, height: editViewHeight))
        editView.titleTextField.text = self.currentPhoto?.title
        editView.cancelButtonTapCallback = { [unowned self] in
            editView.hideView(fromView: self.view)
            self.retakePhoto()
            self.currentPhoto?.title = ""
        }
        editView.doneButtonTapCallback = { [unowned self] (newTitle: String) in
            self.currentPhoto?.title = newTitle.count > 0 ? newTitle : self.currentPhoto?.timestamp
            self.uploadPhoto()
        }
        editView.titleLabel.text = "ADD TITLE"
        editView.selectFolderButtonTapCallback = {
            
            let isPhotoInGroup = self.group != nil
            guard isPhotoInGroup == false else { return }
            
            self.router?.showSelectFolderViewController(fromViewController: self,
                                                             withAnimation: true,
                                                                 forFolder: nil,
                                                            uploadingPhoto: self.currentPhoto!,
                                                                  delegate: self)
        }
        
        self.popUpView = editView
        editView.show(fromView: self.view)
        setupEditViewButton(withFolder: selectedFolder)
    }
    
    private func uploadPhoto() {

        guard let requiredDelegate = self.delegate,
              let requiredCurrenPhoto = self.currentPhoto
        else { return }
        
        self.currentPhoto?.group = group
        self.previewView.setupImage(currentPhoto?.image)
        self.popUpView?.hideView(fromView: self.view)
        self.retakePhoto()
        
        self.previewView.showProgressIndicator()
        
        requiredDelegate.cameraViewController(self,
                                             didTapSave: requiredCurrenPhoto,
                                            resultBlock: { [weak self] (result) in
            
                                                guard let strongSelf = self else { return }
                                                
                                                 switch result {
                                                 case .uploaded(let photo):
                                                    
                                                     guard let requiredUpdatedPhoto = photo else { break }
                                                     strongSelf.updatedPhoto = requiredUpdatedPhoto
                                                     strongSelf.hideStatusBar()
                                                     strongSelf.updatedPhoto = requiredUpdatedPhoto
                                                     strongSelf.previewView.hideProgressIndicator()

                                                     requiredDelegate.cameraViewController(strongSelf, didAddPhotoToFolder: strongSelf.selectedFolder)
                                                    
                                                 case .cached(let totalCount):
                                                     strongSelf.showCacheItemsAlert(count: totalCount)
                                                    
                                                 case .failed(let reason): print(reason)
                                                     strongSelf.delegate?.cameraViewControllerDidConnectionError()
                                                     strongSelf.previewView.hideProgressIndicator()
                                                 }
                                             })
    }
    
    private func showCacheItemsAlert(count: Int) {
    
        let message = "Your photos will be uploaded when network connection is restored. The number of photos to be uploaded is \(count)."
        let alertController = UIAlertController(title: nil,
                                              message: message,
                                       preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alertController, animated: true)
    }
    
    private func saveUpdateTimestamp() {
        let timestampString = DateHelper.stringDateFrom(Date())
        let defaults = UserDefaults.standard
        defaults.set(timestampString, forKey: "LastUpdateTimestamp")
    }
    
    private func showPreviewPhoto(withImage image: UIImage) {
        imageView.image = image
        imageView.isHidden = false
        
        setupControlsVisibility(isHidden: true)
    }
    
    private func setupControlsVisibility(isHidden: Bool) {
        flashButton.isHidden = isHidden
        makePhotoButton.isHidden = isHidden
        closeButton.isHidden = isHidden
        swiftCameraButton.isHidden = isHidden
    }

    private func setupEditViewButton(withFolder folder: Folder?) {
        
        if let editView = (popUpView as? EditView) {
            
            let isPhotoInGroup = self.group != nil
            var folderTitle = "MY PHOTOS"
            
            if let requiredFolderTitle = folder?.title?.uppercased() {
                folderTitle = requiredFolderTitle
            }
            else if isPhotoInGroup,
                let groupTitle = self.group?.title {
                folderTitle = groupTitle.uppercased()
            }

            editView.selectFolderButton.setTitle(folderTitle, for: .normal)
        }
    }

    // MARK: BluetoothManagerDelegate

    override func unsecureConnection() {
        delegate?.cameraViewControllerUnsecureConnection(self)
    }

    // MARK: - SelectFolderViewControllerDelegate
    
    func selectFolderViewController(_ sender: SelectFolderViewController, didSelectFolder folder: Folder?) {
        setupEditViewButton(withFolder: folder)
        
        selectedFolder = folder
        currentPhoto?.folderID = folder?.folderID
        
        navigationController?.popToViewController(self, animated: true)
        UIApplication.shared.isStatusBarHidden = true
    }


    func fullscreenPhotoViewController(_ sender: FullScreenPhotoViewController, didStartToUpload editedPhoto: Photo, to folder: Folder?) {}
    func fullscreenPhotoViewController(_ sender: FullScreenPhotoViewController, didFinishToUpload editedPhoto: Photo, to folder: Folder?) {}
    func fullscreenPhotoViewController(_ sender: FullScreenPhotoViewController, didFailToUpload editedPhoto: Photo, to folder: Folder?) {}

    func fullscreenPhotoViewController(_ sender: FullScreenPhotoViewController,
                    didTapSaveCopiedPhoto photo: Photo,
                                    resultBlock: @escaping PhotoCoordinatorResultBlock) -> () {}

}
