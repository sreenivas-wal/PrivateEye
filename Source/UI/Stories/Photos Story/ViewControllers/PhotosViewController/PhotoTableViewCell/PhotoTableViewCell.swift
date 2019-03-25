//
//  PhotoTableViewCell.swift
//  MyMobileED
//
//  Created by Admin on 1/18/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import MGSwipeTableCell

protocol PhotoTableViewCellDelegate: class {
    func loadImage(fromURL imageURL: URL, withBlock successBlock: @escaping (_ image: UIImage) -> ())
}

class PhotoTableViewCell: MGSwipeTableCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoImageContainerView: UIView!
    @IBOutlet weak var photoTitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    weak var photoDelegate: PhotoTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configureCell(with viewModel: PhotoViewModel) {
        let placeholderImage = UIImage(named: "photo-placeholder")
        
        if let link = viewModel.imageLink  {
            if let imageURL: URL = URL(string: link) {
                photoImageView.image = placeholderImage
                
                self.photoDelegate?.loadImage(fromURL: imageURL, withBlock: { (image) in
                    DispatchQueue.main.async {
                        self.photoImageView?.image = image
                    }
                })
            } else {
                photoImageView.image = placeholderImage
            }
        } else {
            photoImageView.image = placeholderImage
        }
        
        photoTitleLabel.text = viewModel.title
        timeLabel.text = viewModel.time
        timestampLabel.text = viewModel.userTimestamp
        
        self.photoImageContainerView.layer.cornerRadius = 2.0
        self.photoImageView.layer.cornerRadius = 2.0
        self.photoImageView.contentMode = .scaleAspectFill
        
        if viewModel.isHighlighted {
            
            self.photoImageContainerView.layer.borderWidth = 2.0
            self.photoImageContainerView.layer.borderColor = UIColor.red.cgColor
        }
        else {
            self.photoImageContainerView.layer.borderWidth = 0.0
            self.photoImageContainerView.layer.borderColor = UIColor.clear.cgColor
        }
    }
}
