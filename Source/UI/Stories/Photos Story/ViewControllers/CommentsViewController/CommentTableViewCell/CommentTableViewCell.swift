//
//  CommentTableViewCell.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 10/18/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import TTTAttributedLabel

protocol CommentTableViewCellDelegate: class {
    
    func commentTableViewCell(_ cell: CommentTableViewCell, didSelectLinkWith url: URL)
}

class CommentTableViewCell: UITableViewCell, TTTAttributedLabelDelegate {

    weak var delegate: CommentTableViewCellDelegate?
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentLabel: TTTAttributedLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(withViewModel viewModel: CommentViewModel) {
        
        usernameLabel.text = viewModel.username
        dateLabel.text = viewModel.timestamp
        
        if let requiredCommnet = viewModel.comment {
            self.configureCommentLabel(with: requiredCommnet)
        }
    }

    // MARK: -
    // MARK: Private
    fileprivate func configureCommentLabel(with text: String) {
        
        let mainFont = UIFont(name: "Avenir-Book", size: 15.0) ?? .systemFont(ofSize: 15.0)
        let attributedString = NSMutableAttributedString(string: text)
        
        attributedString.addAttribute(NSFontAttributeName,
                                      value: mainFont,
                                      range: NSMakeRange(0, text.count))
        
        self.commentLabel.attributedText = attributedString

        guard let requiredDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        else {
            self.commentLabel.delegate = nil
            return
        }
        
        let matches = requiredDetector.matches(in: text, options: [],
                                            range: NSRange(location: 0, length: text.utf16.count))

        guard matches.isEmpty == false
        else {
            self.commentLabel.delegate = nil
            return
        }

        for matchedString in matches {
            self.commentLabel.addLink(with: matchedString)
        }

        self.commentLabel.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
        self.commentLabel.isUserInteractionEnabled = true
        self.commentLabel.delegate = self
    }
    
    // MARK: -
    // MARK: TTTAttributedLabelDelegate
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        
        guard let requiredDelegate = self.delegate else { return }
        requiredDelegate.commentTableViewCell(self, didSelectLinkWith: url)
    }
}
