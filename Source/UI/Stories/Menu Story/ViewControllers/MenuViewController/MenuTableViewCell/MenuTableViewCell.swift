//
//  MenuTableViewCell.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 8/28/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    func configureCellWith(_ viewModel: MenuFolderViewModel) {
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
    }
}
