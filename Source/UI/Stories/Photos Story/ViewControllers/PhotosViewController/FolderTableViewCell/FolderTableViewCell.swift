//
//  FolderTableViewCell.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 8/17/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class FolderTableViewCell: MGSwipeTableCell {

    private let editableAlpha: CGFloat = 1.0
    private let noneditableAlpha: CGFloat = 0.5
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var foldeImageView: UIImageView!
    
    func configureCellWithFolder(_ folderViewModel: FolderViewModel) {
        titleLabel.text = folderViewModel.title
        
        if folderViewModel.changeble {
            contentView.alpha = folderViewModel.isEditable ? editableAlpha : noneditableAlpha
        }
        
        self.foldeImageView.image = folderViewModel.isHighlighted ? UIImage(named: "updated_folder-icon") : UIImage(named: "folder-icon")
    }
}
