//
//  CaseTableViewCell.swift
//  MyMobileED
//
//  Created by Admin on 1/20/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

class CaseTableViewCell: UITableViewCell {

    @IBOutlet weak var caseNameLabel: UILabel!
    @IBOutlet weak var connectionStateLabel: UILabel!    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configureCell(with viewModel: CaseViewModel) {
        caseNameLabel.text = viewModel.title
        
        if viewModel.connected! {
            connectionStateLabel.textColor = BaseColors.deviceLightGreen.color()
            connectionStateLabel.text = "Case connected"
        } else {
            connectionStateLabel.textColor = BaseColors.deviceGray.color()
            connectionStateLabel.text = "Not connected"
        }

        viewModel.connecting! ? indicatorView.startAnimating() : indicatorView.stopAnimating()
    }
    
}
