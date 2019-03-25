//
//  FullScreenPhotoViewController.swift
//  MyMobileED
//
//  Created by Admin on 2/2/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import DTPhotoViewerController
import MBProgressHUD

protocol FullScreenPhotoViewControllerDelegate: class {
    
    func fullscreenPhotoViewController(_ sender: FullScreenPhotoViewController, didStartToUpload editedPhoto: Photo, to folder: Folder?)
    func fullscreenPhotoViewController(_ sender: FullScreenPhotoViewController, didFinishToUpload editedPhoto: Photo, to folder: Folder?)
    func fullscreenPhotoViewController(_ sender: FullScreenPhotoViewController, didFailToUpload editedPhoto: Photo, to folder: Folder?)
    
    func fullscreenPhotoViewController(_ sender: FullScreenPhotoViewController,
                    didTapSaveCopiedPhoto photo: Photo,
                                    resultBlock: @escaping PhotoCoordinatorResultBlock) -> ()
}

class FullScreenPhotoViewController: DTPhotoViewerController, EditPhotoViewControllerDelegate, SelectFolderViewControllerDelegate, EnterNoteViewDelegate {
    
    private let textViewMaxHeight: CGFloat = 81
    private let textViewLineHeight: CGFloat = 28
    
    private var closeButton: UIButton!
    private var photoTitleLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var activity: UIActivityIndicatorView!
    private var noteButton: UIButton!
    private var editButton: UIButton?
    private var shareButton: UIButton?
    private var photosRequest: NetworkRequest?
    private var popUpView: PopUpView?
    private var editedNote: String?
    private var copyButton: UIButton?
    private var keyboardHeight: CGFloat = 0
    private var copiedPhoto: Photo?
    private var selectedFolderToSaveCopiedPhoto: Folder?
    private var noteBadgeLabel: UILabel?

    weak var photoDelegate: FullScreenPhotoViewControllerDelegate?
    
    var selectedFolder: Folder?
    var canEditPhoto: Bool = true
    var currentPhoto: Photo?
    var router: PhotosRouterProtocol?
    var photosProvider: PhotosProviderProtocol?
    var networkManager: (PhotosNetworkProtocol & InviteUsersProtocol & CommentsNetworkProtocol)?
    var userManager: SessionUserProtocol?
    var alertsManager: AlertsManagerProtocol?
    var contactsService: ContactsServiceProtocol?
    var photoUploadCoordinator: PhotoCoordinatorProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createCloseButton()
        createTitleLabel()
        createDescriptionLabel()
        createActivity()
        createNoteButton()
        
        if canEditPhoto {
            createEditButton()
            createShareButton()
            createEditPhotoGestureRecognizers()
            createCopyButton()
        }
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.isStatusBarHidden = true
        
        if let image = imageView.image {
            let rotatedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .up)
            imageView.image = rotatedImage
        }

        if photosRequest != nil {
            photosRequest?.dataRequest?.cancel()
        }

        if currentPhoto!.image != nil {
            imageView.image = currentPhoto!.image
            activity.stopAnimating()
            photosRequest = nil
        } else {
            activity?.startAnimating()
            photosRequest = photosProvider?.retrieveImage(byNodeID: currentPhoto!.nodeID!, successBlock: { [weak self] (image) in
                
                guard let strongSelf = self else { return }
                
                DispatchQueue.main.async {
                    strongSelf.imageView.image = image
                    strongSelf.currentPhoto?.image = image
                    strongSelf.activity?.stopAnimating()
                    strongSelf.photosRequest = nil
                }
            }, failureBlock: {  [weak self] (error) -> (Void)  in

                guard let strongSelf = self else { return }

                DispatchQueue.main.async {
                    strongSelf.activity?.stopAnimating()
                    strongSelf.photosRequest = nil
                }
            })
        }
        
        configurePhotoContents()
        loadNewCommentsCount()
        
        setupSubviewsHiddenState(isHidden: false)
        activity.isHidden = true
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.createCloseButtonConstraint()
        self.createTitleLabelConstraint()
        self.createDescriptionLabelConstraint()
        self.createActivityConstraint()
        self.createNoteButtonConstraints()
        
        if self.canEditPhoto {
            self.createEditButtonConstraints()
            self.createShareButtonConstraints()
            self.createCopyButtonConstraints()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.isStatusBarHidden = false
        setupSubviewsHiddenState(isHidden: true)
        
        if photosRequest != nil {
            photosRequest?.dataRequest?.cancel()
        }
        
        super.viewWillDisappear(animated)
    }
    
    func buttonCloseTapped(_ sender: Any) {
        popUpView?.hideView(fromView: self.view)
        
        self.router?.hideFullScreenViewControler(self, animated: true, comletion: nil)
    }
    
    func noteButtonTapped(_ sender: UIButton) {
        canEditPhoto ? showEditNoteView() : showViewNoteView()
    }
    
    func editButtonTapped(_ sender: UIButton) {
        router?.showEditPhotoViewController(fromViewController: self,
                                                 withAnimation: false,
                                                      forPhoto: currentPhoto!,
                                                            in: self.selectedFolder,
                                                      delegate: self)
    }
    
    func copyButtonTapped(_ sender: UIButton) {
        
        self.showEditViewForCopiedPhoto()
    }
    
    func shareButtonTapped(_ sender: UIButton) {
        if userManager?.currentUser?.userRole == "unverified" {
            self.alertsManager?.showUnVerifiedAlertController(forViewController: self, withOkayCallback: { () -> (Void) in
                
            }, withOpenCallback: { () -> (Void) in
                    self.router?.showPEVerificationViewController(fromViewController: self, navigationController: self.navigationController!, withAnimation: false)
            })
        } else if userManager?.currentUser?.userRole == "in_progress" {
            self.alertsManager?.showInReviewAlertController(forViewController: self, withOkayCallback: { () -> (Void) in
               
            })
        } else {
            showShareAlertController()
        }
    }
    
    // MARK: - Private
    // MARK: Subviews & Constraints
    
    private func createActivity() {
        activity = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activity.color = BaseColors.darkBlue.color()
        activity.hidesWhenStopped = true
        activity.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(activity)
        activity.startAnimating()
    }
    
    private func createActivityConstraint() {
        view.addConstraint(NSLayoutConstraint(item: activity, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: activity, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    private func createCloseButton() {
        closeButton = UIButton(type: UIButtonType.custom)
        closeButton.setImage(UIImage(named: "camera-close"), for: UIControlState())
        closeButton.addTarget(self, action: #selector(buttonCloseTapped(_:)), for: UIControlEvents.touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.imageEdgeInsets = UIEdgeInsetsMake(24.0, 24.0, 24.0, 24.0)
        closeButton.imageView?.contentMode = .scaleAspectFit
        
        self.view.addSubview(closeButton)
    }
    
    private func createCloseButtonConstraint() {
        view.addConstraint(NSLayoutConstraint(item: closeButton, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: closeButton, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: closeButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 68))
        view.addConstraint(NSLayoutConstraint(item: closeButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,multiplier: 1, constant: 68))
    }
    
    private func createTitleLabel() {
        photoTitleLabel = UILabel()
        photoTitleLabel.textColor = UIColor.white
        photoTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        photoTitleLabel.font = UIFont(name: "Avenir-Heavy", size: 14)
        
        self.view.addSubview(photoTitleLabel)
    }
    
    private func createTitleLabelConstraint() {
        view.addConstraint(NSLayoutConstraint(item: photoTitleLabel, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 70))
        view.addConstraint(NSLayoutConstraint(item: photoTitleLabel, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 25))
    }
    
    private func createDescriptionLabel() {
        descriptionLabel = UILabel()
        descriptionLabel.textColor = UIColor.gray
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont(name: "Avenir-Book", size: 14)
        
        self.view.addSubview(descriptionLabel)
    }
    
    private func createDescriptionLabelConstraint() {
        view.addConstraint(NSLayoutConstraint(item: descriptionLabel, attribute: .bottom, relatedBy: .equal, toItem: self.bottomLayoutGuide, attribute: .top, multiplier: 1, constant: -20))
        view.addConstraint(NSLayoutConstraint(item: descriptionLabel, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 70))
        view.addConstraint(NSLayoutConstraint(item: descriptionLabel, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 25))
        view.addConstraint(NSLayoutConstraint(item: descriptionLabel, attribute: .top, relatedBy: .equal, toItem: photoTitleLabel, attribute: .bottom, multiplier: 1, constant: 2))
    }
    
    private func createNoteButton() {
        noteButton = UIButton(type: UIButtonType.custom)
        noteButton.addTarget(self, action: #selector(noteButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        noteButton.translatesAutoresizingMaskIntoConstraints = false
        noteButton.imageView?.contentMode = .scaleAspectFit
        
        configureDefaultNoteButton()
        
        self.view.addSubview(noteButton)
        
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 1
        label.backgroundColor = UIColor.red
        label.layer.cornerRadius = 7.5
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 8.0)
        label.textColor = UIColor.white
        label.isHidden = true
        
        self.view.addSubview(label)
        self.noteBadgeLabel = label
    }
    
    private func configureDefaultNoteButton() {
        noteButton.imageEdgeInsets = UIEdgeInsetsMake(13.0, 14.0, 15.0, 15.0)
        noteButton.setImage(UIImage(named: "view-note"), for: UIControlState())
        self.noteBadgeLabel?.isHidden = true
    }
    
    private func configureNoteButtonWithBadge(with count: Int) {
        
        if let requiredBadgeLabel = self.noteBadgeLabel {
            requiredBadgeLabel.isHidden = false
            requiredBadgeLabel.text = String(count)
        }
    }
    
    private func createNoteButtonConstraints() {
        let leftConstant: CGFloat = (canEditPhoto ? 45.0 : 12.0)
        
        view.addConstraint(NSLayoutConstraint(item: noteButton, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: noteButton, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: leftConstant))
        view.addConstraint(NSLayoutConstraint(item: noteButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 68))
        view.addConstraint(NSLayoutConstraint(item: noteButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,multiplier: 1, constant: 48))
        
        if let label = self.noteBadgeLabel {
         
            let badgeleftConstant = leftConstant + 24
            view.addConstraint(NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 36))
            view.addConstraint(NSLayoutConstraint(item: label, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: badgeleftConstant))
            view.addConstraint(NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 15 ))
            view.addConstraint(NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,multiplier: 1, constant: 15))
        }
    }
    
    private func createEditButton() {
        editButton = UIButton(type: UIButtonType.custom)
        editButton?.setImage(UIImage(named: "edit-icon"), for: UIControlState())
        editButton?.addTarget(self, action: #selector(editButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        editButton?.translatesAutoresizingMaskIntoConstraints = false
        editButton?.imageEdgeInsets = UIEdgeInsetsMake(22.0, 12.0, 22.0, 12.0)
        editButton?.imageView?.contentMode = .scaleAspectFit

        self.view.addSubview(editButton!)
    }
    
    private func createEditButtonConstraints() {
        view.addConstraint(NSLayoutConstraint(item: editButton!, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: editButton!, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 12))
        view.addConstraint(NSLayoutConstraint(item: editButton!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 68))
        view.addConstraint(NSLayoutConstraint(item: editButton!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,multiplier: 1, constant: 48))
    }
    
    private func createShareButton() {
        shareButton = UIButton(type: UIButtonType.custom)
        shareButton?.addTarget(self, action: #selector(shareButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        shareButton?.translatesAutoresizingMaskIntoConstraints = false
        shareButton?.imageEdgeInsets = UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0)
        shareButton?.imageView?.contentMode = .scaleAspectFit
        shareButton?.setImage(UIImage(named: "share-photo"), for: .normal)
        
        self.view.addSubview(shareButton!)
    }
    
    private func createShareButtonConstraints() {
        view.addConstraint(NSLayoutConstraint(item: shareButton!, attribute: .bottom, relatedBy: .equal, toItem: self.bottomLayoutGuide, attribute: .bottom, multiplier: 1, constant: -8))
        view.addConstraint(NSLayoutConstraint(item: shareButton!, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: shareButton!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 68))
        view.addConstraint(NSLayoutConstraint(item: shareButton!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,multiplier: 1, constant: 68))
    }
    
    private func createCopyButton() {
        
        guard self.canEditPhoto else { return }
        
        let copyButton = UIButton(type: UIButtonType.custom)
        copyButton.addTarget(self, action: #selector(copyButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        copyButton.imageView?.contentMode = .scaleAspectFit
        copyButton.setImage(UIImage(named: "icn_photo_copy"), for: UIControlState())
        copyButton.imageEdgeInsets = UIEdgeInsetsMake(0, -22.0, 0, 0)
        
        self.view.addSubview(copyButton)
        self.copyButton = copyButton
        
        self.createCopyButtonConstraints()
    }
    
    private func createCopyButtonConstraints() {
        
        guard let requiredCopyButton = self.copyButton,
              self.canEditPhoto
        else { return }

        requiredCopyButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: requiredCopyButton, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: requiredCopyButton, attribute: .left, relatedBy: .equal, toItem: self.noteButton, attribute: .right, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: requiredCopyButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 68))
        view.addConstraint(NSLayoutConstraint(item: requiredCopyButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,multiplier: 1, constant: 44))
    }
    
    // MARK: Notifications
    
    private func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        var keyboardFrame: CGRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        if popUpView?.superview == self.view {
            let yPosition = self.view.bounds.size.height - popUpView!.height() - keyboardFrame.height
            
            popUpView?.frame = CGRect(x: 0, y: yPosition,
                                      width: popUpView!.frame.width,
                                      height: popUpView!.frame.height)
            keyboardHeight = keyboardFrame.height
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        if popUpView?.superview == self.view {
            let yPosition = self.view.bounds.size.height - popUpView!.height()
            popUpView?.frame = CGRect(x: 0, y: yPosition,
                                      width: popUpView!.frame.width,
                                      height: popUpView!.frame.height)
            keyboardHeight = 0
        }
    }
    
    // MARK: Other
    
    private func createEditPhotoGestureRecognizers() {
        let photoGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.willEditPhoto))
        photoTitleLabel.addGestureRecognizer(photoGestureRecognizer)
        photoTitleLabel.isUserInteractionEnabled = true
        
        let descriptionGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.willEditPhoto))
        descriptionLabel.addGestureRecognizer(descriptionGestureRecognizer)
        descriptionLabel.isUserInteractionEnabled = true
    }
    
    @objc private func willEditPhoto() {
        showEditView()
    }
    
    private func configurePhotoContents() {
        if let title = currentPhoto?.title {
            photoTitleLabel.text = title
        }
        
        if let date = currentPhoto?.timestamp,
           let username = currentPhoto?.username,
           let requiredFormattedDate = DateHelper.dateFrom(string: date) {
            
            descriptionLabel.text = String(format:"By %@, %@", username, DateHelper.formatedStringDateWithDayName(fromDate: requiredFormattedDate))
        }
    }
    
    private func showViewNoteView() {
        popUpView?.removeFromSuperview()
        
        let viewNoteView = ViewNoteView(frame: CGRect.zero)
        viewNoteView.configure(with: currentPhoto?.note?.trimmingCharacters(in: .whitespacesAndNewlines))
        viewNoteView.closeButtonTapCallback = { [unowned self] in
            viewNoteView.hideView(fromView: self.view)
        }
        viewNoteView.viewCommentsTapCallback = { [unowned self] in
            self.configureDefaultNoteButton()
            self.router?.showCommentsViewController(fromViewController: self, withAnimation: true, forPhoto: self.currentPhoto!)
        }
        let height = viewNoteView.height()
        let frame = CGRect(x: 0, y: view.bounds.height - height, width: view.bounds.size.width, height: height)
        viewNoteView.setupFrame(frame)
        
        self.popUpView = viewNoteView
        
        viewNoteView.show(fromView: self.view)
    }
    
    private func showEditNoteView() {
        popUpView?.removeFromSuperview()

        let titleLabel = currentPhoto?.note == nil ? "ADD NOTE" : currentPhoto!.note!.count > 0 ? "NOTE" : "ADD NOTE"
        
        let noteViewHeight: CGFloat = EnterNoteView.viewHeight()
        let yPosition = view.bounds.size.height - noteViewHeight
        let enterNoteView = EnterNoteView(frame: CGRect(x: 0, y: yPosition, width: view.bounds.size.width, height: noteViewHeight))
        enterNoteView.configure(with: currentPhoto?.note?.trimmingCharacters(in: .whitespacesAndNewlines),
                               title: titleLabel)
        enterNoteView.backButtonTapCallback = { [unowned self, enterNoteView] in
            enterNoteView.hideView(fromView: self.view)
        }
        enterNoteView.continueButtonTapCallback = { [unowned self, enterNoteView] (photoNote: String) in
            enterNoteView.hideView(fromView: self.view)
            
            self.editedNote = photoNote
            self.showEditView()
        }
        enterNoteView.viewCommentsButtonTapCallback = { [unowned self] in
            self.configureDefaultNoteButton()
            self.router?.showCommentsViewController(fromViewController: self, withAnimation: true, forPhoto: self.currentPhoto!)
        }
        enterNoteView.delegate = self
        
        let height = enterNoteView.height()
        let frame = CGRect(x: 0, y: view.bounds.height - height, width: view.bounds.size.width, height: height)
        enterNoteView.setupFrame(frame)

        self.popUpView = enterNoteView
        enterNoteView.show(fromView: self.view)
    }
    
    private func showEditView() {
        popUpView?.removeFromSuperview()
        
        let editViewHeight: CGFloat = EditView.viewHeight()
        let yPosition = self.view.bounds.size.height - editViewHeight
        let editView = EditView(frame: CGRect(x: 0, y: yPosition, width: self.view.bounds.size.width, height: editViewHeight))
        editView.titleTextField.text = self.currentPhoto?.title
        editView.cancelButtonTapCallback = { [unowned self, editView] in
            editView.hideView(fromView: self.view)
        }
        editView.doneButtonTapCallback = { [unowned self] (newTitle: String) in
            self.currentPhoto?.title = newTitle.count > 0 ? newTitle : self.userManager?.currentUser?.sessionName
            self.currentPhoto?.note = self.editedNote
            
            self.uploadEditedPhoto()
        }
        editView.titleLabel.text = "EDIT TITLE"
        
        let folderTitle = currentPhoto?.folderName?.uppercased()
        editView.selectFolderButton.setTitle(folderTitle, for: .normal)
        editView.selectFolderButtonTapCallback = {
            self.router?.showSelectFolderViewController(fromViewController: self,
                                                        withAnimation: true,
                                                        forFolder: nil,
                                                        uploadingPhoto: self.currentPhoto!,
                                                        delegate: self)
        }
        
        self.popUpView = editView
        editView.show(fromView: self.view)
    }
    
    private func showEditViewForCopiedPhoto() {
        popUpView?.removeFromSuperview()
        
        guard let requiredCurrentPhotoImage = self.currentPhoto?.image else { return }
        
        let requiredCopiedPhoto = Photo(image: requiredCurrentPhotoImage)
        requiredCopiedPhoto.folderID = self.currentPhoto?.folderID
        requiredCopiedPhoto.title = self.currentPhoto?.title
        requiredCopiedPhoto.group = self.currentPhoto?.group
        requiredCopiedPhoto.folderName = self.currentPhoto?.folderName

        self.copiedPhoto = requiredCopiedPhoto
        self.selectedFolderToSaveCopiedPhoto = self.selectedFolder

        let editViewHeight: CGFloat = EditView.viewHeight()
        let yPosition = self.view.bounds.size.height - editViewHeight
        let editView = EditView(frame: CGRect(x: 0, y: yPosition, width: self.view.bounds.size.width, height: editViewHeight))
        editView.titleTextField.text = self.copiedPhoto?.title
        
        editView.cancelButtonTapCallback = { [unowned self, editView] in
            editView.hideView(fromView: self.view)
        }
        
        editView.doneButtonTapCallback = { [unowned self] (newTitle: String) in
            self.copiedPhoto?.title = newTitle.count > 0 ? newTitle : self.userManager?.currentUser?.sessionName
            self.upload(copiedPhoto: requiredCopiedPhoto)
        }
        
        editView.titleLabel.text = "EDIT TITLE"
        
        let folderTitle = self.copiedPhoto?.folderName?.uppercased()
        editView.selectFolderButton.setTitle(folderTitle, for: .normal)
        editView.selectFolderButtonTapCallback = {
            self.router?.showSelectFolderViewController(fromViewController: self,
                                                        withAnimation: true,
                                                        forFolder: nil,
                                                        uploadingPhoto: requiredCopiedPhoto,
                                                        delegate: self)
        }
        
        self.popUpView = editView
        editView.show(fromView: self.view)
    }
    
    private func uploadEditedPhoto() {
        
        guard let ruquiredCurrentPhoto = self.currentPhoto else { return }

        self.photoDelegate?.fullscreenPhotoViewController(self, didStartToUpload: ruquiredCurrentPhoto, to: self.selectedFolder)
        self.router?.hideFullScreenViewControler(self, animated: true, comletion: nil)

        self.photoUploadCoordinator.uploadEditedPhoto(ruquiredCurrentPhoto,
                                                 completion: { [weak self] (result) in
                                                    
                                                    guard let strongSelf = self else { return }
                                                    DispatchQueue.main.async {
                                                        
                                                        switch result {
                                                        case .uploaded(_):
                                                            strongSelf.photoDelegate?.fullscreenPhotoViewController(strongSelf,
                                                                                                                    didFinishToUpload: ruquiredCurrentPhoto,
                                                                                                                                   to: strongSelf.selectedFolder)
                                                            strongSelf.configurePhotoContents()
                                                            
                                                        case .cached(_):
                                                            strongSelf.configurePhotoContents()
                                                            strongSelf.photoDelegate?.fullscreenPhotoViewController(strongSelf,
                                                                                                                    didFailToUpload: ruquiredCurrentPhoto,
                                                                                                                                 to: strongSelf.selectedFolder)

                                                        case .failed(let reason):
                                                            print(reason)
                                                            strongSelf.photoDelegate?.fullscreenPhotoViewController(strongSelf,
                                                                                                                    didFailToUpload: ruquiredCurrentPhoto,
                                                                                                                                 to: strongSelf.selectedFolder)
                                                        }
                                                    }
        })
    }
    
    fileprivate func upload(copiedPhoto: Photo) {
        
        guard let requiredDelegate = self.photoDelegate else { return }
        self.router?.hideFullScreenViewControler(self, animated: true, comletion: nil)

        requiredDelegate.fullscreenPhotoViewController(self,
                                                       didTapSaveCopiedPhoto: copiedPhoto,
                                                                 resultBlock: { result in
                                                        
                                                                    switch result {
                                                                        
                                                                    case .uploaded(let photo):
                                                                        guard let requiredUpdatedPhoto = photo else { break }
                                                                        requiredDelegate.fullscreenPhotoViewController(self,
                                                                                                                       didFinishToUpload: requiredUpdatedPhoto,
                                                                                                                                      to: self.selectedFolderToSaveCopiedPhoto)
                                                                    case .cached(_): break
                                                                        
                                                                    case .failed(let reason):
                                                                        print(reason)
                                                                        requiredDelegate.fullscreenPhotoViewController(self,
                                                                                                                       didFailToUpload: copiedPhoto,
                                                                                                                                    to: self.selectedFolderToSaveCopiedPhoto)
                                                                    }
        })
    }

    private func setupSubviewsHiddenState(isHidden: Bool) {
        closeButton.isHidden = isHidden
        photoTitleLabel.isHidden = isHidden
        descriptionLabel.isHidden = isHidden
        activity.isHidden = isHidden
        shareButton?.isHidden = isHidden
        editButton?.isHidden = isHidden
        noteButton.isHidden = isHidden
    }
    
    private func showShareAlertController() {
        alertsManager?.showShareAlertController(forViewController: self, withShareToUserCallback: { [unowned self] () -> (Void) in
            self.shareToUser()
        }, shareToDoximityCallback: { [unowned self] () -> (Void) in
            self.shareToDoximity()
        }, shareByEmailCallback: { [unowned self] () -> (Void) in
            self.shareByEmail()
        }, shareByTextCallback: { [unowned self] () -> (Void) in
            self.shareByText()
        }, shareToGroupCallback: { [unowned self] () -> (Void) in
            self.router?.showShareGroupsViewController(fromViewController: self, withAnimation: true, sharingCompletionHandler: { [unowned self] (group) in
                self.networkManager?.sharePhoto(self.currentPhoto!, toGroup: group, successBlock: { [unowned self](response) -> (Void) in
                    DispatchQueue.main.async {
                        self.navigationController?.popToViewController(self, animated: true)
                        self.alertsManager?.showSuccessSharedContentAlertController(forViewController: self)
                    }
                }, failureBlock: { [unowned self] (error) -> (Void) in
//                    var message = error.object as? [String]
                    DispatchQueue.main.async {
//                        self.alertsManager?.showErrorAlert(forViewController: self, withMessage: message![0])
                        if error.code == 403 {
                            self.alertsManager?.showErrorAlert(forViewController: self, withMessage: "To share a photo in the group, you should be part of that group.")
                        }else {
                            self.alertsManager?.showErrorAlert(forViewController: self, withMessage: error.message)
                        }
                    }
                })
            })
        })
    }
    
    private func shareToUser() {
        let sharingCompletionHandler: (([ShareUser], UIViewController) -> (Void)) = { [unowned self] (users, presenting) -> (Void) in
            self.networkManager?.sharePhotoToUser(self.currentPhoto!, forUsers: users, successBlock: { [unowned self] (response) -> (Void) in
                self.router?.hideFullScreenViewControler(self, animated: true, comletion: nil)
                self.alertsManager?.showSuccessSharedPhotoAlertController(forViewController: self, isMultiple: users.count > 1)
            }, failureBlock: { (error) -> (Void) in
                DispatchQueue.main.async { self.alertsManager?.showErrorAlert(forViewController: presenting, withMessage: error.message) }
            }
        )}
        
        let alertSharingHandler: (([ShareUser], UIViewController) -> (Void)) = { [unowned self] (users, presenting) -> (Void) in
            self.navigationController?.popViewController(animated: true)
            self.router?.showShareUsersAlertViewController(fromViewController: self,
                                                           withAnimation: true,
                                                           viewModel: UserDisplayingInformationViewModel.shareToInstitutionViewModel(),
                                                           forSharingDestination: .user,
                                                           users: users,
                                                           shareCallback: sharingCompletionHandler)
        }
        
        router?.showShareViewController(fromViewController: self,
                                        withAnimation: true,
                                        shareCompletionHandler: alertSharingHandler,
                                        cancelSharingCompletionHandler: { () -> (Void) in
                                            self.navigationController?.popViewController(animated: true)
                                        },
                                        doximityAuthorizationFailureBlock: nil,
                                        forSharingDestination: .user)
    }
    
    private func shareToDoximity() {
        let doximityID = userManager?.currentUser?.doximityID ?? ""
        let hasDoximityAccount = !doximityID.isEmpty
    
        if hasDoximityAccount {
            let sharingCompletionHandler: (([ShareUser], UIViewController) -> (Void)) = { [unowned self] (users, presenting) -> (Void) in
                self.networkManager?.sharePhotoToDoximityUser(self.currentPhoto!, forUsers: users, successBlock: { [unowned self] (response) -> (Void) in
                    self.router?.hideFullScreenViewControler(self, animated: true, comletion: nil)
                    self.alertsManager?.showSuccessSharedPhotoAlertController(forViewController: self, isMultiple: users.count > 1)
                }, failureBlock: { [unowned self] (error) -> (Void) in
                    if error.code == noDoximityUserExistErrorCode {
                        DispatchQueue.main.async {
                            presenting.dismiss(animated: true, completion: {
                                self.showInviteAlert(forViewController: self)
                            })
                        }
                    } else {
                        DispatchQueue.main.async { self.alertsManager?.showErrorAlert(forViewController: presenting, withMessage: error.message) }
                    }
                })
            }
            
            let alertSharingHandler: (([ShareUser], UIViewController) -> (Void)) = { [unowned self] (users, presenting) -> (Void) in
                self.navigationController?.popViewController(animated: true)
                self.router?.showShareUsersAlertViewController(fromViewController: self,
                                                               withAnimation: true,
                                                               viewModel: UserDisplayingInformationViewModel.shareToDoximityViewModel(),
                                                               forSharingDestination: .doximity,
                                                               users: users,
                                                               shareCallback: sharingCompletionHandler)
            }
            
            router?.showShareViewController(fromViewController: self,
                                            withAnimation: true,
                                            shareCompletionHandler: alertSharingHandler,
                                            cancelSharingCompletionHandler: { () -> (Void) in
                                                self.navigationController?.popViewController(animated: true)
                                            },
                                            doximityAuthorizationFailureBlock: { [weak self] showShareViewController in
                                                
                                                guard let strongSelf = self else { return }
                                                
                                                DispatchQueue.main.async { strongSelf.navigationController?.popViewController(animated: true) }
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                                                    
                                                    strongSelf.router?.showDoximityUpdateTokenAuthorization(from: strongSelf, animated: true, resultBlock: { [weak self] (result) in
                                                        
                                                        guard let strongSelf = self else { return }
                                                        
                                                        switch result {
                                                        case .success: strongSelf.shareToDoximity()
                                                        default: break
                                                        }
                                                    })
                                                })
                                            },
                                            forSharingDestination: .doximity)
        } else {
            let doximitySignUpAlert = UIAlertController.signUpToDoximityAlertController(withLoginHandler: { [weak self] in
                
                guard let strongSelf = self else { return }
                strongSelf.router?.showDoximityFullAuthorization(from: strongSelf,
                                                             animated: true,
                                                          resultBlock: { (authorizationResult) in
         
                                                              switch authorizationResult {
                                                              case.success:
                                                                  strongSelf.router?.relogin(fromViewController: strongSelf, withAnimation: false)
                                                              case .failure(_): break
                                                              }
                                                          })
            })
            self.present(doximitySignUpAlert, animated: true, completion: nil)
        }
    }
    
    private func shareByEmail() {
        let screenViewModel = ShareContactsAlertViewControllerViewModel(actionTitle: "Share",
                                                 userDisplayingInformationViewModel: UserDisplayingInformationViewModel.shareByEmailsViewModel(),
                                                                     displayingInfo: .emails)

        router?.showShareContactsAlertViewController(fromViewController: self,
                                             withAnimation: true,
                                             viewModel: screenViewModel,
                                             shareCallback: { [unowned self] (textValues, viewController) -> (Void) in
                                                    self.shareByEmails(textValues, forViewController: viewController)
        })
    }
    
    private func shareByText() {
        let screenViewModel = ShareContactsAlertViewControllerViewModel(actionTitle: "Share",
                                                 userDisplayingInformationViewModel: UserDisplayingInformationViewModel.shareBySMSViewModel(),
                                                                     displayingInfo: .phones)

        router?.showShareContactsAlertViewController(fromViewController: self,
                                             withAnimation: true,
                                             viewModel: screenViewModel,
                                             shareCallback: { [unowned self] (textValues, viewController) -> (Void) in
                                                self.shareByTexts(textValues, forViewController: viewController)
        })
    }

    private func showInviteAlert(forViewController viewController: UIViewController) {
        let inviteMessage = "This Doximity user is not a member of PrivateEyeHC. Invite this user to join PrivateEyeHC by:"
        
        alertsManager?.showInviteAlertController(forViewController: viewController, withMessage: inviteMessage, withDoximityInviteHandler: { [unowned self] () -> (Void) in
            self.networkManager?.inviteUserInDoximity()
            }, withEmailInviteHandler: { [unowned self] () -> (Void) in
            let selectionHandler: (([String]) -> (Void)) = { [unowned self] (_ textValues: [String]) in
                let textValue = textValues.last ?? ""
                self.alertsManager?.showInviteByEmailAlertController(forViewController: self, textValue: textValue, withSuccessHandler: { [unowned self] (email) -> (Void) in
                    self.inviteUser(byEmail: email, forViewController: viewController)
                })
            }
            
            self.contactsService?.requestAccessToContacts({ [unowned self] (isSuccess) in
                if isSuccess {
                    DispatchQueue.main.async {
                        self.router?.showContactsViewController(fromViewController: self, withAnimation: true, forDisplayingInfo: .emails, selectionHandler: selectionHandler)
                    }
                } else {
                    selectionHandler([])
                }
            })
        }, textInviteHandler: { [unowned self] () -> (Void) in
            let selectionHandler: (([String]) -> (Void)) = { [unowned self] (_ textValues: [String]) in
                let textValue = textValues.last ?? ""
                self.alertsManager?.showInviteByTextAlertController(forViewController: viewController, textValue: textValue, withSuccessHandler: { [unowned self] (phone) -> (Void) in
                    self.inviteUser(byText: phone, forViewController: viewController)
                })
            }
            
            self.contactsService?.requestAccessToContacts({ [unowned self] (isSuccess) in
                if isSuccess {
                    DispatchQueue.main.async {
                        self.router?.showContactsViewController(fromViewController: viewController, withAnimation: true, forDisplayingInfo: .phones, selectionHandler: selectionHandler)
                    }
                } else {
                    selectionHandler([])
                }
            })
        })
    }
    
    private func inviteUser(byEmail email: String, forViewController viewController: UIViewController) {
        networkManager?.inviteUser(byEmail: email, successBlock: { [unowned self] (response) -> (Void) in
            DispatchQueue.main.async { self.alertsManager?.showSuccessInviteAlertController(forViewController: viewController) }
        }, failureBlock: { [unowned self] (error) -> (Void) in
            DispatchQueue.main.async { self.alertsManager?.showErrorAlert(forViewController: viewController, withMessage: error.message) }
        })
    }
    
    private func inviteUser(byText text: String, forViewController viewController: UIViewController) {
        networkManager?.inviteUser(byText: text, successBlock: { [unowned self] (response) -> (Void) in
            DispatchQueue.main.async { self.alertsManager?.showSuccessInviteAlertController(forViewController: viewController)  }
        }, failureBlock: { [unowned self] (error) -> (Void) in
            DispatchQueue.main.async { self.alertsManager?.showErrorAlert(forViewController: viewController, withMessage: error.message) }
        })
    }
    
    private func shareByEmails(_ emails: [String], forViewController viewController: UIViewController) {
        networkManager?.sharePhoto(self.currentPhoto!, byEmails: emails, successBlock: { [unowned self] (response) -> (Void) in
            DispatchQueue.main.async {
                viewController.dismiss(animated: true, completion: nil)
                self.alertsManager?.showSuccessSharedByEmailAlertController(forViewController: self, isMultiple: emails.count > 1)
            }
        }, failureBlock: { [unowned self] (error) -> (Void) in
            DispatchQueue.main.async { self.alertsManager?.showErrorAlert(forViewController: viewController, withMessage: error.message) }
        })
    }
    
    private func shareByTexts(_ texts: [String], forViewController viewController: UIViewController) {
        networkManager?.sharePhoto(self.currentPhoto!, byTexts: texts, successBlock: { [unowned self] (response) -> (Void) in
            DispatchQueue.main.async {
                viewController.dismiss(animated: true, completion: nil)
                self.alertsManager?.showSuccessSharedByTextAlertController(forViewController: self, isMultiple: texts.count > 1)
            }
        }, failureBlock: { [unowned self] (error) -> (Void) in
            DispatchQueue.main.async { self.alertsManager?.showErrorAlert(forViewController: viewController, withMessage: error.message) }
        })
    }
    
    private func loadNewCommentsCount() {
        networkManager?.newCommentsCount(forNodeID: currentPhoto?.nodeID, successBlock: { [unowned self] (response) -> (Void) in
            let count = response.object as! Int
            if count > 0 {
                DispatchQueue.main.async {
                    self.configureNoteButtonWithBadge(with: count)
                    self.view.layoutIfNeeded()
                }
            }
            else {
                DispatchQueue.main.async {

                    self.configureDefaultNoteButton()
                    self.view.layoutIfNeeded()
                }
            }
        }, failureBlock: { (error) -> (Void) in
            print("Error = \(error)")
        })
    }
    
    private func calculateEnterNoteViewHeight() {
        guard let editNoteView = popUpView as? EnterNoteView else { return }
        
        let height = editNoteView.height()
        editNoteView.layoutIfNeeded()
        
        if height <= editNoteView.maxViewHeight {
            let frame = CGRect(x: 0, y: view.bounds.height - height - keyboardHeight, width: view.bounds.size.width, height: height)
            editNoteView.setupFrame(frame)
        }
    }
    
    // MARK: - EnterNoteViewDelegate
    
    func enterNoteViewTextDidChange(_ sender: EnterNoteView) {
        calculateEnterNoteViewHeight()
    }
    
    // MARK: - EditPhotoViewControllerDelegate
    
    func editPhotoViewController(_ sender: EditPhotoViewController, didChangePhoto photo: Photo, inFolder: Folder?) {
        
        sender.dismiss(animated: true, completion: {
            
            self.router?.hideFullScreenViewControler(self, animated: true, comletion: nil)
        })

        self.photoDelegate?.fullscreenPhotoViewController(self, didStartToUpload: photo, to: inFolder)
        photoUploadCoordinator.uploadPhotoToExtistingNode(photo) { [weak self] (result) in
            
            guard let strongSelf = self else { return }

            DispatchQueue.main.async {
                
                switch result {
                case .uploaded(_):
                    strongSelf.photosProvider?.replaceImage(photo.image!, withNodeID: photo.nodeID!)
                    strongSelf.photoDelegate?.fullscreenPhotoViewController(strongSelf, didFinishToUpload: photo, to: inFolder)
                    
                case .cached(_):
                    if let requiredNodeID = photo.nodeID {
                        strongSelf.photosProvider?.removeImage(withNodeID: requiredNodeID)
                    }
                    
                    strongSelf.photoDelegate?.fullscreenPhotoViewController(strongSelf, didFailToUpload: photo, to: inFolder)
                    
                case .failed(let reason):
                    strongSelf.photoDelegate?.fullscreenPhotoViewController(strongSelf, didFailToUpload: photo, to: inFolder)

                    print(reason)
                }
            }
        }
    }
    
    func editPhotoViewControllerDidCancelEditing(_ sender: EditPhotoViewController) {
        dismiss(animated: false, completion: nil)
    }
    
    // MARK: - SelectFolderViewControllerDelegate
    
    func selectFolderViewController(_ sender: SelectFolderViewController, didSelectFolder folder: Folder?) {
        if let editView = (popUpView as? EditView) {
            let folderTitle = (folder != nil ? folder!.title?.uppercased() : "MY PHOTOS")
            editView.selectFolderButton.setTitle(folderTitle, for: .normal)
        }
        
        let folderID = (folder?.folderID == nil ? "my" : folder?.folderID)
        
        if sender.uploadingPhoto?.cacheIdenifier == self.copiedPhoto?.cacheIdenifier {
            self.copiedPhoto?.folderID = folderID
            self.selectedFolderToSaveCopiedPhoto = folder
        }
        else {
            currentPhoto?.folderID = folderID
            self.selectedFolder = folder
        }
        
        navigationController?.popToViewController(self, animated: true)
        UIApplication.shared.isStatusBarHidden = true
    }    
}
