//
//  ShareUsersAlertViewController.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 1/12/18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit

class ShareUsersAlertViewController: ShareAlertViewController, ShareAlertTableViewCellDelegate {

    var sharingDestination: SharingDestination = .user
    var sharingHandler: ((_ users: [ShareUser], _ viewController: UIViewController) -> (Void))?
    var users: [ShareUser] = []

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        sharingHandler?(users, self)
    }
    
    // MARK: - Overriden
    
    override func configureViewLayout() {
        let viewHeight = view.frame.height - keyboardFrame.height
        let alertViewHeight = minHeight() + CGFloat(users.count) * tableViewRowHeight
        let isOverAlertViewHeight = (alertViewHeight + alertViewOffset > viewHeight)
        alertViewHeightConstraint.constant = isOverAlertViewHeight ? viewHeight - alertViewOffset : alertViewHeight
        tableView.isScrollEnabled = isOverAlertViewHeight
    }
    
    override func reloadView() {
        super.reloadView()
        
        shareButton.isEnabled = (users.count > 0)
    }
    
    override func minHeight() -> CGFloat {
        switch sharingDestination {
        case .user:
            return 155.0
        case .doximity:
            return 220.0
        }
    }

    // MARK: UITableViewDelegate
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShareAlertTableViewCell", for: indexPath) as! ShareAlertTableViewCell
        cell.delegate = self
        cell.configure(withTitle: users[indexPath.row].username ?? "")

        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    // MARK: - ShareAlertTableViewCellDelegate
    
    func shareAlertTableViewCellDidTapDeleteButton(_ cell: ShareAlertTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        users.remove(at: indexPath.row)
        
        reloadView()
    }

}
