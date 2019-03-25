//
//  GroupTableViewCell.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 1/22/18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {

    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet weak var leaderLabel: UILabel!
    
    func configure(with viewModel: GroupViewModel) {
        titleLabel.text = viewModel.title
        membersLabel.text = viewModel.membersInfo
        leaderLabel.text = viewModel.ownerInformation
        
        titleLabel.textColor = viewModel.isOwner ? BaseColors.darkBlue.color() : UIColor(red: 162/255, green: 162/255, blue: 162/255, alpha: 1.0)
        groupImageView.tintColor = viewModel.isOwner ? BaseColors.darkBlue.color() : UIColor(red: 179/255, green: 179/255, blue: 179/255, alpha: 1.0)
    }
    
}
