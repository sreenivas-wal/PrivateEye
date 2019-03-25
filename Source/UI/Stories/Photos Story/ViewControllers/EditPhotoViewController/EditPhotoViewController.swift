//
//  EditPhotoViewControlelrViewController.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 8/21/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import AKImageCropperView

enum EditingState {
    case rotate
    case crop
    case none
}

protocol EditPhotoViewControllerDelegate: class {
    func editPhotoViewController(_ sender: EditPhotoViewController, didChangePhoto photo: Photo, inFolder: Folder?)
    func editPhotoViewControllerDidCancelEditing(_ sender: EditPhotoViewController)
}

class EditPhotoViewController: BaseViewController, SelectFolderViewControllerDelegate {
    
    @IBOutlet weak var applyEditingView: UIView!
    @IBOutlet weak var cropButton: UIButton!
    @IBOutlet weak var rotateButton: UIButton!
    @IBOutlet weak var imageCropperView: AKImageCropperView!
    
    weak var delegate: EditPhotoViewControllerDelegate?
    var router: PhotosRouterProtocol?

    var editingState: EditingState = .none
    var photo: Photo?
    var changedImage: UIImage?
    var selectedFolderToSave: Folder?

    private let photoDegreeRotation: CGFloat = 90
    
    override func viewDidLoad() {
        super.viewDidLoad()

        changedImage = photo?.image
        imageCropperView.image = photo?.image
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.isStatusBarHidden = true
    }
    
    // MARK: - Actions
    
    @IBAction func rotateButtonTapped(_ sender: Any) {
        cropButton.isEnabled = false
        applyEditingView.isHidden = false
        editingState = .rotate
        
        rotatePhoto()
    }
    
    @IBAction func cropButtonTapped(_ sender: Any) {
        rotateButton.isHidden = true
        cropButton.isHidden = true
        applyEditingView.isHidden = false
        imageCropperView.isUserInteractionEnabled = true
        imageCropperView.showOverlayView()
        
        editingState = .crop
    }
    
    @IBAction func buttonCancelTapped(_ sender: Any) {
        delegate?.editPhotoViewControllerDidCancelEditing(self)
    }
    
    @IBAction func buttonSaveTapped(_ sender: Any) {
        saveEditedPhoto()
    }
    
    @IBAction func discardEditingButtonTapped(_ sender: Any) {
        if editingState == .crop {
            imageCropperView.hideOverlayView()
        }
        
        changedImage = photo?.image
        imageCropperView.image = photo?.image
        editingState = .none
        
        setupDefaultStateForViews()
    }
    
    @IBAction func applyEditingButtonTapped(_ sender: Any) {
        if editingState == .crop {
            changedImage = imageCropperView.croppedImage
            imageCropperView.hideOverlayView()
        }
        
        imageCropperView.image = changedImage
        editingState = .none
        
        setupDefaultStateForViews()
        showEditView()
    }

    // MARK: - Private
    
    private func rotatePhoto() {
        changedImage = changedImage?.rotatedImage(byDegrees: photoDegreeRotation)
        imageCropperView.image = changedImage
    }
    
    private func setupDefaultStateForViews() {
        cropButton.isEnabled = true
        rotateButton.isEnabled = true
        applyEditingView.isHidden = true
        rotateButton.isHidden = false
        cropButton.isHidden = false
        imageCropperView.isUserInteractionEnabled = false
    }
    
    private func showEditView() {
        popUpView?.removeFromSuperview()
        
        let editViewHeight: CGFloat = EditView.viewHeight()
        let yPosition = self.view.bounds.size.height - editViewHeight
        let editView = EditView(frame: CGRect(x: 0, y: yPosition, width: self.view.bounds.size.width, height: editViewHeight))
        editView.titleTextField.text = self.photo?.title
        editView.cancelButtonTapCallback = { [unowned self] in
            editView.hideView(fromView: self.view)
        }
        editView.doneButtonTapCallback = { [unowned self] (newTitle: String) in
            self.photo?.title = newTitle.count > 0 ? newTitle : "Photo title"
            self.saveEditedPhoto()
        }
        editView.titleLabel.text = "EDIT TITLE"
        
        let folderTitle = photo?.folderName?.uppercased()
        editView.selectFolderButton.setTitle(folderTitle, for: .normal)
        editView.selectFolderButtonTapCallback = { [weak self] in
            
            guard let strongSelf = self else { return }
            strongSelf.router?.showSelectFolderViewController(fromViewController: strongSelf,
                                                                   withAnimation: true,
                                                                       forFolder: nil,
                                                                  uploadingPhoto: strongSelf.photo!,
                                                                        delegate: strongSelf)
        }
        
        self.popUpView = editView
        editView.show(fromView: self.view)
    }

    private func saveEditedPhoto() {
        
        guard let requiredDelagete = self.delegate,
              let requiredPhoto = self.photo
        else {
            return
        }
        
        requiredPhoto.image = changedImage
        requiredDelagete.editPhotoViewController(self, didChangePhoto: requiredPhoto, inFolder: self.selectedFolderToSave)
    }
    
    // MARK: - SelectFolderViewControllerDelegate
    
    func selectFolderViewController(_ sender: SelectFolderViewController, didSelectFolder folder: Folder?) {
        
        if let editView = (popUpView as? EditView) {
            
            let folderTitle = folder != nil ? folder!.title?.uppercased() : "MY PHOTOS"
            editView.selectFolderButton.setTitle(folderTitle, for: .normal)
        }
        
        let folderID = folder?.folderID == nil ? "my" : folder?.folderID
        photo?.folderID = folderID
        self.selectedFolderToSave = folder
        
        navigationController?.popToViewController(self, animated: true)
        UIApplication.shared.isStatusBarHidden = true
    }
}
