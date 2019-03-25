//
//  MultipleSelectionViewController.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 1/12/18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit

class MultipleSelectionViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    private let rightButtonFontSize: CGFloat = 14
    private let listContactsTableViewEstimatedRowHeight: CGFloat = 92
    
    private let selectedContactsViewMinHeight: CGFloat = 50
    private let selectedContactsTableViewRowHeight: CGFloat = 65
    private let selectecContactsViewTopOffset: CGFloat = 116
    
    private let expandCollapseAnimationDuration: Double = 0.3
    
    @IBOutlet weak var listContactsTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var noResultView: NoResultView!
    
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var selectedContactsView: UIView!
    @IBOutlet weak var selectedContactsTableView: UITableView!
    @IBOutlet weak var selectedContactsLabel: UILabel!
    @IBOutlet weak var selectedContactsContentView: UIView!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var refreshButtonView: UIView!
    @IBOutlet weak var selectedContactsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var contentViewBottomLayoutConstraint: NSLayoutConstraint!
    
    private var selectedContactsViewGestureRecognizer: UITapGestureRecognizer!
    private var shouldShowSelectedContactsView: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHeaderBar()
        configureDataSource()
        setupTableViews()
        configureSelectedContactsViewGestureRecognizer()
    }
    
    // MARK: - Public
    
    func configureHeaderBar() {
        headerBar?.rightButtonFont = UIFont(name: "Avenir-Heavy", size: rightButtonFontSize)
    }
    
    func setupTableViews() {
        setupListContactsTableView()
        setupSelectedContactsTableView()
    }
    
    func reloadView(animated: Bool) {
        let selectedContactsCount = selectedCount()
        let isEmptySelectedContacts = (selectedContactsCount == 0)
        var text = ""
        
        if isEmptySelectedContacts {
            selectedContactsLabel.textColor = UIColor(red: 93/255, green: 95/255, blue: 98/255, alpha: 1.0)
            text = "0 Contacts Selected"
        } else {
            selectedContactsLabel.textColor = BaseColors.darkBlue.color()
            text = String(format: "%ld Contact%@ Selected", selectedContactsCount, (selectedContactsCount == 1) ? "" : "s")
        }
        
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: animated ? expandCollapseAnimationDuration : 0) {
            self.configureViewLayout()
            self.view.layoutIfNeeded()
            self.selectedContactsTableView.reloadData()
        }
        
        selectedContactsLabel.text = text
    }
    
    func selectedCount() -> Int {
        fatalError("Override this method")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError("Override this method")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("Override this method")
    }
    
    func configureDataSource() {
        fatalError("Override this method")
    }
    
    // MARK: - Private
    
    private func setupListContactsTableView() {
        listContactsTableView.register(UINib.init(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: "ContactTableViewCell")
        listContactsTableView.rowHeight = UITableViewAutomaticDimension
        listContactsTableView.estimatedRowHeight = listContactsTableViewEstimatedRowHeight
        listContactsTableView.tableFooterView = UIView()
    }
    
    private func setupSelectedContactsTableView() {
        selectedContactsTableView.register(UINib.init(nibName: "ContactListTableViewCell", bundle: nil), forCellReuseIdentifier: "ContactListTableViewCell")
        selectedContactsTableView.rowHeight = selectedContactsTableViewRowHeight
        selectedContactsTableView.tableFooterView = UIView()
    }
    
    private func configureSelectedContactsViewGestureRecognizer() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectedViewDidTap(_:)))
        
        selectedContactsView.addGestureRecognizer(gestureRecognizer)
        selectedContactsViewGestureRecognizer = gestureRecognizer
    }
    
    @objc private func selectedViewDidTap(_ gestureRecognizer: UITapGestureRecognizer) {
        shouldShowSelectedContactsView = !shouldShowSelectedContactsView
        reloadView(animated: true)
    }
    
    private func configureViewLayout() {
        if shouldShowSelectedContactsView {
            setupExpandedSelectedView()
        } else {
            setupCollapsedSelectedView()
        }
    }
    
    private func setupExpandedSelectedView() {
        let contactsCounts = selectedCount()
        let selectedViewHeight = selectedContactsViewMinHeight + CGFloat(contactsCounts) * selectedContactsTableViewRowHeight
        
        let viewHeight = view.frame.height
        let isOverHeight = (selectecContactsViewTopOffset + selectedViewHeight) > viewHeight
        
        selectedContactsViewHeight.constant = isOverHeight ? viewHeight - selectedContactsView.frame.origin.y : selectedViewHeight
        selectedContactsContentView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1)
        if refreshButtonView.self != nil {
        refreshButtonView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1)
        }
        selectedContactsTableView.isScrollEnabled = isOverHeight
        arrowImageView.image = UIImage(named: "chevronUp")
    }
    
    private func setupCollapsedSelectedView() {
        selectedContactsViewHeight.constant = selectedContactsViewMinHeight
        selectedContactsContentView.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        if refreshButtonView.self != nil {
        refreshButtonView.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        }
        arrowImageView.image = UIImage(named: "chevronDown")
    }
    
    
   
    
    // MARK: Notifications
    
    @objc override func keyboardWillShow(_ notification: Notification) {
        super.keyboardWillShow(notification)
        
        var keyboardFrame: CGRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        UIView.animate(withDuration: expandCollapseAnimationDuration) {
            self.contentViewBottomLayoutConstraint.constant = keyboardFrame.height
            self.view.layoutIfNeeded()
        }
    }
    
    @objc override func keyboardWillHide(_ notification: Notification) {
        super.keyboardWillHide(notification)
        
        UIView.animate(withDuration: expandCollapseAnimationDuration) {
            self.contentViewBottomLayoutConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }

}
