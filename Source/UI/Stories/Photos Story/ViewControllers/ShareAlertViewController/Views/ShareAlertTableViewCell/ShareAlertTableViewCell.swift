//
//  ShareAlertTableViewCell.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 12/19/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

protocol ShareAlertTableViewCellDelegate: class {
    func shareAlertTableViewCellDidTapDeleteButton(_ cell: ShareAlertTableViewCell)
}

class ShareAlertTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var delegate: ShareAlertTableViewCellDelegate?
    
    func configure(withTitle title: String) {
        titleLabel.text = title
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        delegate?.shareAlertTableViewCellDidTapDeleteButton(self)
    }
}
