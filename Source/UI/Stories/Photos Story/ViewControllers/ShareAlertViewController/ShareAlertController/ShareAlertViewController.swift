//
//  ShareAlertViewController.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 1/12/18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit

class ShareAlertViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let animationDuration: Double = 0.1
    
    let tableViewRowHeight: CGFloat = 31.0
    let alertViewOffset: CGFloat = 20.0
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var alertViewHeightConstraint: NSLayoutConstraint!
    
    var router: PhotosRouterProtocol?
    var userDisplayingInformationViewModel: UserDisplayingInformationViewModel = UserDisplayingInformationViewModel(title: "", descriptionText: "")
    var keyboardFrame: CGRect = CGRect.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        subscribeToKeyboardNotifications()
        configureViewForDisplayingInfo()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        configureViewLayout()
    }
    
    // MARK: - Public
    
    func configureTableView() {
        tableView.register(UINib.init(nibName: "ShareAlertTableViewCell", bundle: nil), forCellReuseIdentifier: "ShareAlertTableViewCell")
        tableView.rowHeight = tableViewRowHeight
        tableView.tableFooterView = UIView()
    }
    
    func reloadView() {
        view.setNeedsLayout()
        tableView.reloadData()
    }
    
    func configureViewLayout() {
        fatalError("Override this method")
    }
    
    func minHeight() -> CGFloat {
        fatalError("Override this method")
    }
    
    func configureViewForDisplayingInfo() {
        titleLabel.text = userDisplayingInformationViewModel.title
        descriptionLabel.text = userDisplayingInformationViewModel.descriptionText
    }
    
    // MARK: Notifications
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        var keyboardFrame: CGRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.view.frame.origin.y = -(keyboardFrame.height / 2)
            
            self.keyboardFrame = keyboardFrame
            self.reloadView()
        })
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.view.frame.origin.y = 0
            
            self.keyboardFrame = CGRect.zero
            self.reloadView()
        })
    }
    
    // MARK: - UITableViewDelegate
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("Override this method")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError("Override this method")
    }

}
