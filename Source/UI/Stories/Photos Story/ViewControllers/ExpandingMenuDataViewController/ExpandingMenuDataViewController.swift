//
//  File.swift
//  MyMobileED
//
//  Created by Manisha Reddy Narayan on 08/11/18.
//  Copyright © 2018 Company. All rights reserved.
//
import UIKit

import ExpandingMenu
class ExpandingMenuDataViewController: BaseContentViewController,CameraViewControllerDelegate,PhotoLibraryViewControllerDelegate {
    
    fileprivate var currentUploadedPhotoNumber: Int = 0
    var photoUploadCoordinator: PhotoCoordinatorProtocol!
    fileprivate let dispatchGroup: DispatchGroup = DispatchGroup()
    var foldersNavigationDataSource: FoldersNavigationDataSourceProtocol?
    var photosDataSource: PhotosDataSourceProtocol?
    var cameraMenu: ExpandingMenuButton!
    fileprivate var photosInUploadQueue: [Photo] = []
    var ownership: PhotosOwnership = .my
    var loadingProgressView: UIProgressView?
    var headerButton: UIButton?
    
    
    func configureExpandingMenuForCamera(headerTitleButton: UIButton, progressView:UIProgressView) {
        self.loadingProgressView = progressView
        self.headerButton = headerTitleButton
        let menuButtonSize: CGSize = CGSize(width: 60.0, height: 60.0)
        let menuImageSize: CGSize = CGSize(width: 35.0, height: 35.0)
        
        let menuButton = ExpandingMenuButton(frame: CGRect(origin: CGPoint.zero, size: menuButtonSize),
                                             image: UIImage(named: "chooser-button-tab")!,
                                             rotatedImage: UIImage(named: "chooser-button-tab-highlighted")!)
        
//        let menuButton = ExpandingMenuButton(frame: CGRect(origin: CGPoint.zero, size: menuButtonSize), image: UIImage(named: "chooser-button-tab")!, rotatedImage: UIImage(named: "chooser-button-tab-highlighted")!)

        
        self.view.addSubview(menuButton)
        let btmPadding: CGFloat = 24.0
        let rightPadding: CGFloat = 24.0
        
        menuButton.center = CGPoint(x: self.view.frame.maxX - (rightPadding + menuButtonSize.width / 2),
                                    y: self.view.frame.maxY - (btmPadding + menuButtonSize.height / 2))
        
        let cameraItem = ExpandingMenuItem(size: menuButtonSize,
                                           title: "",
                                           image: UIImage(named: "chooser-moment-icon-camera")!,
                                           highlightedImage: UIImage(named: "chooser-moment-icon-camera-highlighted")!,
                                           backgroundImage: UIImage(named: "chooser-moment-button"),
                                           backgroundHighlightedImage: UIImage(named: "chooser-moment-button-highlighted"),
                                           itemTapped: { [weak self] () -> Void in
                                            
                                            guard let strongSelf = self else { return }
                                            strongSelf.makePhoto()
        })
        
        let photoLibraryBgImage = self.circleImage(with: menuImageSize, color: UIColor.gray)
        let photoLibraryItem = ExpandingMenuItem(size: menuButtonSize,
                                                 title: "",
                                                 image: UIImage(named: "upload")!,
                                                 highlightedImage: UIImage(named: "upload")!,
                                                 backgroundImage: photoLibraryBgImage,
                                                 backgroundHighlightedImage: photoLibraryBgImage,
                                                 itemTapped: { [weak self] () -> Void in
                                                    guard let strongSelf = self else { return }
                                                    strongSelf.router?.showPhotoLibraryViewController(with: strongSelf,
                                                                                                      inFolder: strongSelf.selectedFolder ,
                                                                                                      group: nil,
                                                                                                      fromViewController: strongSelf,
                                                                                                      animated: false)
        })
        menuButton.addMenuItems([cameraItem, photoLibraryItem])
        menuButton.bottomViewAlpha = 0.2
        menuButton.menuItemMargin = 0
        self.cameraMenu = menuButton
        self.cameraMenu.isHidden = self.isSharing
        UIApplication.shared.statusBarStyle = .lightContent
        UIApplication.shared.isStatusBarHidden = false
        
    }
    
    func makePhoto() {
        if bluetoothManager?.isConnected() == true {
            bluetoothManager?.sendSignalOpen()
            router?.showCameraViewController(fromViewController: self,
                                             withAnimation: true,
                                             inFolder: (selectedFolder),
                                             group: nil,
                                             delegate: self)
        }
        else {
            sendCaseDisconnectedRequest()
            
            showUnsecureConnectionView(withConnectionState: .unsecureConnection, completionBlock: { [unowned self] in
                self.router?.showBluetoothViewController(fromViewController: self, withAnimation: true)
            })
        }
    }
    
    func circleImage(with size: CGSize, color: UIColor?) -> UIImage {
        
        let rect = CGRect(origin: CGPoint.zero, size: size)
        let resultColor = color ?? UIColor.white
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let contextRef = UIGraphicsGetCurrentContext()
        contextRef?.setFillColor(resultColor.cgColor)
        contextRef?.fillEllipse(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    private func configureView() {
        //        setupMembersConstraintsConstant(0)
        configureHeaderBarWithFolder()
    }
    
    func cameraViewControllerUnsecureConnection(_ sender: CameraViewController) {
        popUpView = nil
        
        dismiss(animated: true, completion: { [unowned self] in
            //            self.tableViewBottomConstraint.constant = 0
            
            self.showUnsecureConnectionView(withConnectionState: .unsecureConnection, completionBlock: {
                self.router?.showBluetoothViewController(fromViewController: self, withAnimation: true)
            })
        })
    }
    
    func cameraViewController(_ sender: CameraViewController, didAddPhotoToFolder folder: Folder?) {
        selectedFolder = folder
        //        configureView()
        UIApplication.shared.statusBarStyle = .lightContent
        UIApplication.shared.isStatusBarHidden = false
        
        foldersNavigationDataSource?.needUpdateStack()
        photosDataSource?.reloadContent(forFolder: folder)
    }
    
    func cameraViewControllerDidConnectionError() {
        self.configureProgressView(with: .abort)
    }
    
    func cameraViewController(_ sender: CameraViewController,
                              didTapSave photo: Photo,
                              resultBlock: @escaping (PhotoCoordinatorResult) -> ()) {
        
        self.upload(new: photo, resultBlock: resultBlock)
    }
    
    private func configureProgressView(with state: PhotosViewController.ProgressViewState) {
        
        switch state {
        case .start:
            self.loadingProgressView?.isHidden = false
            self.loadingProgressView?.progress = 0.1 // minimum progress
            
        case .proceed(let currentNumber, let totalCount):
            print(Float(currentNumber) / Float(totalCount))
            loadingProgressView?.isHidden = false
            
            if currentNumber == totalCount {
                self.configureProgressView(with: .finished)
                return
            }
            
            let progress = Float(currentNumber) / Float(totalCount)
            loadingProgressView?.setProgress(progress, animated: true)
            
        case .finished:
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                self.loadingProgressView?.progress = 0
                self.loadingProgressView?.isHidden = true
            })
            self.loadingProgressView?.setProgress(1.0, animated: true)
            CATransaction.commit()
            
        case .abort:
            self.loadingProgressView?.progress = 0
            self.loadingProgressView?.isHidden = true
        }
    }
    
    fileprivate func upload(new photo: Photo, resultBlock: @escaping (PhotoCoordinatorResult) -> ()) {
        
        if self.photosInUploadQueue.isEmpty {
            self.configureProgressView(with: .start)
        }
        
        self.photosInUploadQueue.append(photo)
        
        self.dispatchGroup.enter()
        self.photoUploadCoordinator.uploadNewPhoto(photo: photo,
                                                   completion: { (result) in
                                                    
                                                    DispatchQueue.main.async {
                                                        
                                                        switch result {
                                                        case .uploaded:
                                                            let timestampString = DateHelper.stringDateFrom(Date())
                                                            let defaults = UserDefaults.standard
                                                            defaults.set(timestampString, forKey: "LastUpdateTimestamp")
                                                            
                                                            self.currentUploadedPhotoNumber += 1
                                                            self.configureProgressView(with: .proceed(currentNumber: self.currentUploadedPhotoNumber,
                                                                                                      totalCount: self.photosInUploadQueue.count))
                                                            
                                                        case .cached: fallthrough
                                                        case .failed: self.configureProgressView(with: .abort)
                                                        }
                                                    }
                                                    
                                                    resultBlock(result)
                                                    self.dispatchGroup.leave()
        })
        
        dispatchGroup.notify(
            queue: .main, execute: {
                
                print("complete 👍")
                self.photosInUploadQueue.removeAll()
                self.currentUploadedPhotoNumber = 0
        })
    }
    private func configureHeaderBarWithFolder() {
        var parentFolderTitle = "MY PHOTOS"
        let rightButtonImage = UIImage(named: "profile-icon")
        
        if let folderTitle = selectedFolder?.title {
            parentFolderTitle = folderTitle
        }
        
        parentFolderTitle = "ALL PHOTOS"
        
        
        headerButton?.setTitle(parentFolderTitle, for: .normal)
        headerBar?.rightButtonImage = rightButtonImage
        
        self.configureViewNotification()
        UIApplication.shared.statusBarStyle = .lightContent
        UIApplication.shared.isStatusBarHidden = false
        
        if foldersNavigationDataSource!.fetchAll().count > 1 {
            headerBar?.leftButtonImage = UIImage(named: "back-arrow")
            headerBar?.leftButtonHide = false
        }
    }
    
    func photoLibraryViewController(_ sender: PhotoLibraryViewController,
                                    didTapSave photo: Photo,
                                    resultBlock: @escaping PhotoCoordinatorResultBlock) -> () {
        
        self.upload(new: photo, resultBlock: resultBlock)
    }
    
    func photoLibraryViewController(_ sender: PhotoLibraryViewController, didFinishToUpload photo: Photo, toFolder folder: Folder?) {
        
        self.foldersNavigationDataSource?.needUpdateStack()
        self.photosDataSource?.reloadContent(forFolder: folder)
        //        self.performNavigation(to: folder)
    }
    
    func photoLibraryViewController(_ sender: PhotoLibraryViewController, didFailToUpload photo: Photo, toFolder folder: Folder?) {
        
        self.configureProgressView(with: .abort)
    }
    
    private func configureViewNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive(_:)), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    private func performNavigation(to folder: Folder?) {
        guard let requiredFolder = folder
            else {
                self.foldersNavigationDataSource?.popToRoot()
                
                switch ownership {
                case .group(_): break
                case .all, .allInFolder, .my:
                    router?.popPhotosViewController(self, withAnimation: true)
                    photosDataSource?.changeOwnershipFilter(.my)
                }
                return
        }
        
        guard let requiredNavidationDataSourse = self.foldersNavigationDataSource,
            requiredFolder.folderID != self.selectedFolder?.folderID
            else { return }
        
        requiredNavidationDataSourse.popToRoot()
        
        requiredNavidationDataSourse.push(requiredFolder)
        self.router?.showPhotosViewController(fromViewController: self,
                                              withAnimation: true,
                                              with: self.ownership,
                                              isEnableContent: !self.isSharing)
    }
    
    @objc private func didBecomeActive(_ notification: Notification) {
        photosDataSource?.reloadContent(forFolder: selectedFolder)
    }
}
