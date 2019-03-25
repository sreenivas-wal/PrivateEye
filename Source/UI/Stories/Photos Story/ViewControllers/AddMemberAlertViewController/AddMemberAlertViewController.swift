//
//  AddMemberAlertViewController.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 1/25/18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit

class AddMemberAlertViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableViewRowHeight: CGFloat = 45.0
    private let alertViewOffset: CGFloat = 20.0
    private let additionalTextLabelBottomOffset: CGFloat = 20.0
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var additionalTextLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var additionalTextLabelBottomConstraint: NSLayoutConstraint!
    
    var router: PhotosRouterProtocol?
    var viewModel: AddMemberDisplayingInfoViewModel!
    var completionHandler: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        configureViewLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    @IBAction func okayButtonTapped(_ sender: Any) {
        completionHandler?()
    }
    
    // MARK: - Private
    
    private func configureTableView() {
        tableView.register(UINib.init(nibName: "AddMemberTableViewCell", bundle: nil), forCellReuseIdentifier: "AddMemberTableViewCell")
        tableView.rowHeight = tableViewRowHeight
        tableView.tableFooterView = UIView()
    }
    
    private func configureViewLayout() {
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.descriptionText

        let viewHeight = view.frame.height
        let alertViewHeight = viewModel.minimumHeight + (CGFloat(viewModel.contactViewModels.count) * tableViewRowHeight)
        let isOverAlertViewHeight = (alertViewHeight + alertViewOffset > viewHeight)
        contentViewHeightConstraint.constant = isOverAlertViewHeight ? viewHeight - alertViewOffset : alertViewHeight
        
        if viewModel.shouldShowAdditionalText {
            additionalTextLabel.text = viewModel.additionalText
            additionalTextLabelBottomConstraint.constant = additionalTextLabelBottomOffset
        } else {
            additionalTextLabel.text = ""
            additionalTextLabelBottomConstraint.constant = 0
            additionalTextLabel.isHidden = true
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.contactViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddMemberTableViewCell") as! AddMemberTableViewCell
        cell.configure(withContactViewModel: viewModel.contactViewModels[indexPath.row])
        
        return cell
    }
}
