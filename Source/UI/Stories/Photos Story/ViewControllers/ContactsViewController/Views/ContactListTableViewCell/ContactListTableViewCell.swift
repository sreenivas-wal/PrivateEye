//
//  ContactListTableViewCell.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 12/21/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

protocol ContactListTableViewCellDelegate: class {
    func contactListTableViewCellDidTapDelete(_ sender: ContactListTableViewCell)
}

class ContactListTableViewCell: UITableViewCell {

    weak var delegate: ContactListTableViewCellDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabelCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var pendingImageView: UIImageView!
    
    func configure(withContactViewModel viewModel: ContactViewModel) {
        titleLabel.text = viewModel.contactName
        descriptionLabel.text = viewModel.displayingInfo
    }
    
    func configure(withUserViewModel viewModel: ShareUserViewModel) {
        titleLabel.text = viewModel.username
        descriptionLabel.text = ""
        titleLabelCenterYConstraint.constant = 0
    }
    
    func configure(withGroupMemberViewModel viewModel: GroupMemberViewModel) {
        titleLabel.text = viewModel.name
        descriptionLabel.text = ""
        titleLabelCenterYConstraint.constant = 0
        deleteButton.isHidden = !viewModel.canDelete
        titleLabel.textColor = viewModel.selected ? BaseColors.darkBlue.color() : UIColor(red: 133/255, green: 133/255, blue: 133/255, alpha: 1.0)
        pendingImageView.isHidden = viewModel.selected
        
        // TODO: Image
        pendingImageView.image = UIImage(named: "")
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        delegate?.contactListTableViewCellDidTapDelete(self)
    }
}
