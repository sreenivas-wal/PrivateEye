//
//  ContactTableViewCell.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 11/15/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    private var topNameLabelOffset: CGFloat = 12.0
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var selectionImageView: UIImageView!
    
    @IBOutlet var selectionLayoutConstraintsCollection: [NSLayoutConstraint]!
    @IBOutlet var nonselectionLayoutConstrainsCollection: [NSLayoutConstraint]!
    @IBOutlet weak var nameLabelTopConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(withContactViewModel viewModel: ContactViewModel) {
        nameLabel.text = viewModel.contactName
        descriptionLabel.text = viewModel.displayingInfo
        
        configureSelectionConstraint(viewModel.isSelected, canSelect: viewModel.canSelect)
    }
    
    func configure(withShareViewModel viewModel: ShareUserViewModel) {
        nameLabel.text = viewModel.username
        descriptionLabel.text = nil
        nameLabelTopConstraint.constant = topNameLabelOffset
        
        configureSelectionConstraint(viewModel.isSelected, canSelect: viewModel.canSelect)
    }

    // MARK: - Private
    
    func configureSelectionConstraint(_ isSelected: Bool, canSelect: Bool) {
        if canSelect {
            NSLayoutConstraint.deactivate(nonselectionLayoutConstrainsCollection)
            NSLayoutConstraint.activate(selectionLayoutConstraintsCollection)
            
            selectionImageView.isHidden = false
            selectionImageView.image = isSelected ? UIImage(named: "dot-selected") : UIImage(named: "dot-deselected")
        } else {
            NSLayoutConstraint.deactivate(selectionLayoutConstraintsCollection)
            NSLayoutConstraint.activate(nonselectionLayoutConstrainsCollection)
            
            selectionImageView.isHidden = true
        }
    }
    
}
