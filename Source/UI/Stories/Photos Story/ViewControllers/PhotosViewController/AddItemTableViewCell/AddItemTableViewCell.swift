//
//  AddFolderTableViewCell.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 8/17/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

class AddItemTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topLine: UIView!
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}
