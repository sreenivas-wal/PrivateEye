//
//  AddMemberTableViewCell.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 1/25/18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit

class AddMemberTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(withContactViewModel viewModel: ContactViewModel) {
        titleLabel.text = viewModel.contactName
        
        if let displayingInfo = viewModel.displayingInfo {
            titleLabel.text?.append(String(format: "\n%@", displayingInfo))
        }
    }

}
