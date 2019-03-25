//
//  PhotoLibraryViewController.swift
//  MyMobileED
//
//  Created by Created by Admin on 31.05.18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation
import Photos

protocol PhotoLibraryViewControllerDelegate: class {
 
    func photoLibraryViewController(_ sender: PhotoLibraryViewController,
                            didTapSave photo: Photo,
                                 resultBlock: @escaping PhotoCoordinatorResultBlock) -> ()

    func photoLibraryViewController(_ sender: PhotoLibraryViewController, didFinishToUpload photo: Photo, toFolder folder: Folder?)
    func photoLibraryViewController(_ sender: PhotoLibraryViewController, didFailToUpload photo: Photo, toFolder folder: Folder?)
}

enum PhotoLibraryViewControllerLayout {
    
    case photoEmpty
    case photoSelected(photo: Photo)
}

class PhotoLibraryViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SelectFolderViewControllerDelegate {
    
    weak var delegate: PhotoLibraryViewControllerDelegate?
    weak var router: PhotosRouterProtocol?

    var selectedFolder: Folder?
    var group: Group?

    @IBOutlet var previewView: UIView!
    fileprivate var previewImageView: UIImageView!
    
    fileprivate var cameraPicker: UIImagePickerController!
    fileprivate var currentLayoutState: PhotoLibraryViewControllerLayout = .photoEmpty
    fileprivate var currentPhoto: Photo?
    fileprivate var crossButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupImagePicker()
        self.relayout(with: .photoEmpty)
    }
    
    // MARK: -
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            self.router?.hidePhotoLibraryViewController(self, animated: false, completion: nil)
            return
        }
        
        let fixedImageOrientation = self.fixedImageOrientation(selectedImage)
        let photo = Photo(image: fixedImageOrientation)
        photo.folderID = self.selectedFolder?.folderID
        photo.group = self.group
        self.currentPhoto = photo

        self.relayout(with: .photoSelected(photo: photo))
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: false, completion: nil)
        
        guard let requiredCurrentPhoto = self.currentPhoto else {

            self.router?.hidePhotoLibraryViewController(self, animated: true, completion: nil)
            return
        }
        
        self.relayout(with: .photoSelected(photo: requiredCurrentPhoto))
    }

    // MARK: -
    // MARK: SelectFolderViewControllerDelegate
    func selectFolderViewController(_ sender: SelectFolderViewController, didSelectFolder folder: Folder?) {
        
        self.setupEditViewButton(withFolder: folder)
        
        self.selectedFolder = folder
        self.currentPhoto?.folderID = folder?.folderID
        
        navigationController?.popToViewController(self, animated: true)
        UIApplication.shared.isStatusBarHidden = true
    }
    
    // MARK: -
    // MARK: Private
    fileprivate func setupImagePicker() {
        
        self.cameraPicker = UIImagePickerController()
        self.cameraPicker.allowsEditing = false
        self.cameraPicker.sourceType = .photoLibrary
        self.cameraPicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        self.cameraPicker.delegate = self
    }
    
    fileprivate func relayout(with layouState: PhotoLibraryViewControllerLayout) {
        if (previewImageView == nil) {
            previewImageView = UIImageView(frame: CGRect(x: 0, y: 70, width: self.view.bounds.size.width, height: previewView.frame.height - EditView.viewHeight() - 70))
            self.previewView.addSubview(previewImageView)
        }
        
        switch layouState {
        case .photoEmpty:
            self.crossButton.isHidden = true
            previewImageView.isHidden = true
            self.present(self.cameraPicker, animated: true, completion: nil)

        case .photoSelected(let photo):
            self.crossButton.isHidden = false
            
            previewImageView.isHidden = false
            previewImageView.image = photo.image
            previewImageView.contentMode = .scaleAspectFit
            self.showEditView()
        }
    }
    
    fileprivate func showEditView() {
        
        if let requiredPopupView = self.popUpView {
            requiredPopupView.removeFromSuperview()
            self.popUpView = nil
        }
        
        let editViewHeight: CGFloat = EditView.viewHeight()
        let yPosition = self.view.bounds.size.height - editViewHeight
        let editView = EditView(frame: CGRect(x: 0, y: yPosition, width: self.view.bounds.size.width, height: editViewHeight))
        editView.titleTextField.text = self.currentPhoto?.title
        editView.titleLabel.text = "ADD TITLE"

        editView.cancelButtonTapCallback = { [weak self, weak editView] in
            
            guard let strongSelf = self else { return }
            strongSelf.relayout(with: .photoEmpty)

            if let requiredEditView = editView {
                requiredEditView.hideView(fromView: strongSelf.view)
            }
        }
        
        editView.doneButtonTapCallback = { [weak self, weak editView] (newTitle: String) in
            
            guard let strongSelf = self,
                  let requiredCurrentPhoto = strongSelf.currentPhoto
            else { return }
            
            requiredCurrentPhoto.title = newTitle.count > 0 ? newTitle : strongSelf.currentPhoto?.timestamp

            if let requiredEditView = editView {
                requiredEditView.hideView(fromView: strongSelf.view)
            }
            
            strongSelf.upload(photo: requiredCurrentPhoto)
        }
        
        editView.selectFolderButtonTapCallback = { [weak self] in
            
            let isPhotoInGroup = self?.group != nil
            guard let strongSelf = self,
                  let requiredCurrentPhoto = strongSelf.currentPhoto,
                      isPhotoInGroup == false
            else { return }
            
            strongSelf.router?.showSelectFolderViewController(fromViewController: strongSelf,
                                                                   withAnimation: true,
                                                                       forFolder: nil,
                                                                  uploadingPhoto: requiredCurrentPhoto,
                                                                        delegate: strongSelf)
        }
        
        self.popUpView = editView
        editView.show(fromView: self.view)
        setupEditViewButton(withFolder: selectedFolder)
    }

    fileprivate func setupEditViewButton(withFolder folder: Folder?) {
        
        if let requiredEditView = self.popUpView as? EditView {
            
            let isPhotoInGroup = self.group != nil
            var folderTitle = "MY PHOTOS"
            
            if let requiredFolderTitle = folder?.title?.uppercased() {
                folderTitle = requiredFolderTitle
            }
            else if isPhotoInGroup,
                 let groupTitle = self.group?.title {
                folderTitle = groupTitle.uppercased()
            }
            
            requiredEditView.selectFolderButton.setTitle(folderTitle, for: .normal)
        }
    }

    fileprivate func upload(photo: Photo) {
        
        guard let requiredDelegate = self.delegate else { return }
        self.router?.hidePhotoLibraryViewController(self, animated: true, completion: nil)
        
        requiredDelegate.photoLibraryViewController(self,
                                                    didTapSave: photo,
                                                   resultBlock: { result in
                                                    
                                                       switch result {
                                                       case .uploaded(let photo):
                                                        
                                                           guard let requiredUpdatedPhoto = photo else { break }
                                                           requiredDelegate.photoLibraryViewController(self,
                                                                                                       didFinishToUpload: requiredUpdatedPhoto,
                                                                                                                toFolder: self.selectedFolder)
                                                       case .cached(_): break
                                                       case .failed(let reason):
                                                           print(reason)
                                                           requiredDelegate.photoLibraryViewController(self,
                                                                                                       didFailToUpload: photo,
                                                                                                              toFolder: self.selectedFolder)
                                                       }
                                                   })
    }
    
    @objc fileprivate func handleCrossTap(_ sender: UIButton) {
        
        self.router?.hidePhotoLibraryViewController(self, animated: false, completion: nil)
    }

    fileprivate func setupUI() {
        self.view.backgroundColor = UIColor.black
        crossButton = UIButton(type: UIButtonType.custom)
        crossButton.setImage(UIImage(named: "camera-close"), for: UIControlState())
        crossButton.addTarget(self, action: #selector(PhotoLibraryViewController.handleCrossTap(_:)), for: .touchUpInside)
        crossButton.translatesAutoresizingMaskIntoConstraints = false
        crossButton.imageEdgeInsets = UIEdgeInsetsMake(24.0, 24.0, 24.0, 24.0)
        crossButton.imageView?.contentMode = .scaleAspectFit
        
        self.view.addSubview(crossButton)
        view.addConstraint(NSLayoutConstraint(item: crossButton, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: crossButton, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: crossButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 68))
        view.addConstraint(NSLayoutConstraint(item: crossButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,multiplier: 1, constant: 68))
        
    }

    fileprivate func fixedImageOrientation(_ image: UIImage) -> UIImage {
        
        let originalImage : UIImage! = image
        let newSize = image.size
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        originalImage.draw(in: CGRect(x: 0, y: 0, width: originalImage.size.width, height: originalImage.size.height))
        let uploadPic = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return uploadPic!
    }
}
