//
//  CommentsViewController.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 10/18/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import KMPlaceholderTextView

enum CommentsEditingState: Int {
    case none = 0
    case edit
}

class CommentsViewController: BaseViewController, CommentsDataSourceDelegate, UITextViewDelegate, UIScrollViewDelegate {
    
    private let rightButtonFontSize: CGFloat = 14
    private let closeItemEdgeImageInset: CGFloat = 14
    private let deleteViewExpandedHeight: CGFloat = 100
    private let animationDuration: TimeInterval = 0.5
    private let defaultCommentViewHeight: CGFloat = 59
    private let textViewMaxHeight: CGFloat = 75
    private let textViewLineHeight: CGFloat = 23.5
    
    var router: PhotosRouterProtocol?
    var networkManager: CommentsNetworkProtocol?
    var userManager: SessionUserProtocol?
    var currentPhoto: Photo?
    var alertsManager: AlertsManager?
    
    private var commentsDataSource: CommentsDataSourceProtocol?
    private var editingState: CommentsEditingState = .none
    private var tapGestureRecognizer: UITapGestureRecognizer?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var writeCommentBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var postCommentButton: UIButton!
    @IBOutlet weak var noResultView: NoResultView!
    @IBOutlet weak var commentTextView: KMPlaceholderTextView!
    
    @IBOutlet weak var tableViewDeleteBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewCommentViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var postCommentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentTextViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDataSource()
        configureTableViewGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        commentsDataSource?.reloadContent()
    }
    
    // MARK: - Actions
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        let selectedComments = commentsDataSource!.selectedComments()
        networkManager?.removeComments(selectedComments, successBlock: { (response) -> (Void) in
            self.commentsDataSource?.reloadContent()
            self.setupDefaultViewState()
        }, failureBlock: { (error) -> (Void) in
            if error.code == 403 {
                self.presentAlert(withMessage: (error.json[0]).string!)
                return
            }
            self.presentAlert(withMessage: error.message)
        })
    }
    
    @IBAction func postCommentButtonTapped(_ sender: Any) {
        if currentPhoto?.uid != userManager?.currentUser?.userID {
            if userManager?.currentUser?.userRole == "unverified" {
                self.alertsManager?.showUnVerifiedAlertController(forViewController: self, withOkayCallback: { () -> (Void) in
                    
                }, withOpenCallback: { () -> (Void) in
                    self.verifyNow(router: self.router!)
                })
            } else if userManager?.currentUser?.userRole == "in_progress" {
                self.alertsManager?.showInReviewAlertController(forViewController: self, withOkayCallback: { () -> (Void) in
                    
                })
            }  else {
                postComment()
            }
        } else {
           postComment()
        }
    }
    
    func postComment() {
        postCommentButton.resignFirstResponder()
        let commentValue = commentTextView.text!
        postComment(withSubject: commentValue)
    }
    
    // MARK: - Private
    
    private func configureTableViewGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        headerBar?.addGestureRecognizer(tapGestureRecognizer)
        
        let tapTableViewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        tableView.addGestureRecognizer(tapTableViewGestureRecognizer)
        tapTableViewGestureRecognizer.cancelsTouchesInView = false
        self.tapGestureRecognizer = tapTableViewGestureRecognizer
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        swipe.direction = .down
        
        view.addGestureRecognizer(swipe)
    }
    
    func handleGesture(_ recognizer: UIGestureRecognizer) {
        view.endEditing(true)
    }
    
    private func configureDataSource() {
        let commentsDataSource = CommentsDataSource(tableView: tableView, networkManager: networkManager, delegate: self, photo: currentPhoto)
        self.commentsDataSource = commentsDataSource
    }
    
    private func configureHeaderView(withDeleteOption canDeleteComments: Bool) {
        if canEditPhoto() && canDeleteComments {
            setupHeaderBarEditItem()
            commentsDataSource?.setEditing(editing: false, animated: true)
        }
    }
    
    private func setupHeaderBarEditItem() {
        headerBar?.rightButtonHide = false
        headerBar?.rightButtonEnable = true
        headerBar?.rightButtonText = "EDIT"
        headerBar?.rightButtonImage = nil
        headerBar?.rightButtonFont = UIFont(name: "Avenir-Heavy", size: rightButtonFontSize)
    }
    
    override func keyboardWillShow(_ notification: Notification) {
        var keyboardFrame: CGRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        writeCommentBottomConstraint.constant = keyboardFrame.height
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        writeCommentBottomConstraint.constant = 0
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupHeaderBarCloseItem() {
        headerBar?.rightButtonText = ""
        headerBar?.rightButtonImage = UIImage(named: "camera-close")
        headerBar?.rightButtonImageEdgeInsets = UIEdgeInsetsMake(closeItemEdgeImageInset, closeItemEdgeImageInset, closeItemEdgeImageInset, closeItemEdgeImageInset)
    }
    
    private func canEditPhoto() -> Bool {
        return currentPhoto?.uid == userManager?.currentUser?.userID
    }
    
    private func postComment(withSubject subject: String) {
        clearPostComment()
        
        networkManager?.postComment(subject,
                                    forNodeID: currentPhoto?.nodeID,
                                    folderID: currentPhoto?.folderID,
                                    successBlock: { (response) -> (Void) in
                                        self.commentsDataSource?.reloadContent()
        }, failureBlock: { (error) -> (Void) in
            self.presentAlert(withMessage: error.message)
        })
    }
    
    private func setupDeleteViewVisibleState(_ isVisible: Bool) {
        deleteViewHeightConstraint.constant = isVisible ? deleteViewExpandedHeight : 0
    }
    
    private func clearPostComment() {
        postCommentButton.isHidden = true
        commentTextView.text = ""
        commentTextView.resignFirstResponder()
        postCommentViewHeightConstraint.constant = defaultCommentViewHeight
        calculatePostCommentViewHeight()
    }
    
    private func setupTableViewBottomConstraint(forEditingState state: CommentsEditingState) {
        switch editingState {
        case .none:
            tableViewDeleteBottomConstraint.isActive = false
            tableViewCommentViewBottomConstraint.isActive = true
            break
        case .edit:
            tableViewCommentViewBottomConstraint.isActive = false
            tableViewDeleteBottomConstraint.isActive = true
            
            break
            
        }
    }
    
    private func setupEditingViewState() {
        tapGestureRecognizer?.isEnabled = false
        editingState = .edit
        setupHeaderBarCloseItem()
        commentsDataSource?.setEditing(editing: true, animated: true)
        setupDeleteViewVisibleState(true)
        deleteButton.isEnabled = false
        setupTableViewBottomConstraint(forEditingState: .none)
    }
    
    private func setupDefaultViewState() {
        tapGestureRecognizer?.isEnabled = true
        editingState = .none
        setupHeaderBarEditItem()
        commentsDataSource?.setEditing(editing: false, animated: true)
        setupDeleteViewVisibleState(false)
        setupTableViewBottomConstraint(forEditingState: .edit)
    }
    
    private func configurePostCommentButtonVisibility() {
        let trancatedText = commentTextView.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let isEmpty = (trancatedText.count == 0)
        postCommentButton.isHidden = isEmpty
    }
    
    private func calculatePostCommentViewHeight() {
        let sizeThatFitsTextView = commentTextView.sizeThatFits(CGSize(width: commentTextView.frame.size.width,
                                                                       height: CGFloat.greatestFiniteMagnitude))
        
        if sizeThatFitsTextView.height > textViewMaxHeight {
            commentTextView.isScrollEnabled = true
        } else {
            commentTextView.isScrollEnabled = false
            
            commentTextViewHeightConstraint.constant = sizeThatFitsTextView.height
            postCommentViewHeightConstraint.constant = sizeThatFitsTextView.height + textViewLineHeight
        }
    }
    
    // MARK: - HeaderBarDelegate
    
    func headerBar(_ header: HeaderBar, didTapLeftButton left: UIButton) {
        navigationController?.popViewController(animated: true)
        let a = navigationController?.viewControllers.contains(NotificationHistoryListViewController())
    }
    
    func headerBar(_ header: HeaderBar, didTapRightButton right: UIButton) {
        clearPostComment()
        
        switch editingState {
        case .none:
            setupEditingViewState()
            
            break
        case .edit:
            setupDefaultViewState()
            
            break
        }
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        configurePostCommentButtonVisibility()
        calculatePostCommentViewHeight()
    }
    
    // MARK: - CommentsDataSourceDelegate
    
    func commentsDataSource(_ sender: CommentsDataSourceProtocol, selectedComments: [Comment]) {
        deleteButton.isEnabled = selectedComments.count > 0
    }
    
    func commentsDataSource(_ sender: CommentsDataSourceProtocol, isEmptyComments isEmpty: Bool) {
        noResultView.isHidden = !isEmpty
    }
    
    func commentsDataSource(_ sender: CommentsDataSourceProtocol, canDeleteComments canDelete: Bool) {
        configureHeaderView(withDeleteOption: canDelete)
    }
    
    func commentsDataSourceWillBeginScrolling(_ sender: CommentsDataSourceProtocol) {
        view.endEditing(true)
    }
    
    func commentsDataSource(_ sender: CommentsDataSourceProtocol, didSelectLinkWith url: URL) {
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }
}
