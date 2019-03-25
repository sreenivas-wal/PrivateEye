//
//  NotificationListItemCell.swift
//  MyMobileED
//
//  Created by Created by Admin on 14.06.18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation

struct NotificationListItemViewModel {
    
    let itemID: String
    let title: String
    let subtitle: String
}

class NotificationListItemCell: UITableViewCell {
    
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var subtitleLabel: UILabel!
    
    class var cell: NotificationListItemCell {
        return Bundle.main.loadNibNamed(NotificationListItemCell.cellIdentifier, owner: self, options: nil)?[0] as! NotificationListItemCell
    }
    
    class var cellNib: UINib {
        return UINib(nibName: "NotificationListItemCell", bundle: nil)
    }
    
    class var cellIdentifier: String {
        return "NotificationListItemCell"
    }
    
    func configure(with viewModel: NotificationListItemViewModel) {
        
        self.titleLabel.text = viewModel.title
        self.subtitleLabel.text = viewModel.subtitle
    }
}
