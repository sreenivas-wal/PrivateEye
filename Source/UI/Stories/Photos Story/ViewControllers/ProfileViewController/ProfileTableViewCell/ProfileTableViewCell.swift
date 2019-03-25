//
//  ProfileTableViewCell.swift
//  MyMobileED
//
//  Created by Admin on 1/26/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

protocol ProfileTableViewCellDelegate: class {
    func profileTableViewCell(_ cell: ProfileTableViewCell, didEndEditingField value: String)
}

class ProfileTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueTextField: UITextField!
    
    weak var delegate: ProfileTableViewCellDelegate?

    func configureProfileCell(with profileViewModel: ProfileViewModel) {
        titleLabel.text = profileViewModel.title
        
        if let textValue = profileViewModel.value {
            valueTextField.isHidden = false
            valueTextField.text = textValue
            
            if profileViewModel.isEditable == true {
                valueTextField.isEnabled = true
            } else {
                valueTextField.isEnabled = false
            }
        } else {
            valueTextField.isHidden = true
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        delegate?.profileTableViewCell(self, didEndEditingField: textField.text!)
        
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == self.valueTextField) {
            let oldString = textField.text!
            let newStart = oldString.index(oldString.startIndex, offsetBy: range.location)
            let newEnd = oldString.index(oldString.startIndex, offsetBy: range.location + range.length)
            let newString = oldString.replacingCharacters(in: newStart..<newEnd, with: string)
            textField.text = newString.replacingOccurrences(of: " ", with: "\u{00a0}")
            return false
        } else {
            return true
        }
    }
}
