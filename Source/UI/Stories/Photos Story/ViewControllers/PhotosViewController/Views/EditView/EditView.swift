//
//  EditView.swift
//  MyMobileED
//
//  Created by Admin on 1/30/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

class EditView: PopUpView, UITextFieldDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var selectFolderButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var cancelButtonTapCallback: (() -> Void)?
    var doneButtonTapCallback: ((_ newTitle: String) -> Void)?
    var selectFolderButtonTapCallback: (() -> Void)?
    
    class func viewHeight() -> CGFloat {
        return 240.0
    }
        
    override func height() -> CGFloat {
        return EditView.viewHeight()
    }
    
    override func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "EditView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }

    @IBAction func buttonCancelTapped(_ sender: Any) {
        titleTextField.resignFirstResponder()
        
        if let validCancelCallback = cancelButtonTapCallback {
            validCancelCallback()
        }
    }
    
    @IBAction func buttonDoneTapped(_ sender: Any) {
        titleTextField.resignFirstResponder()
        
        if let validDoneCallback = doneButtonTapCallback {
            validDoneCallback(titleTextField.text!)
        }
    }
    
    @IBAction func selectFolderButtonTapped(_ sender: Any) {
        titleTextField.resignFirstResponder()
        
        if let validSelectFolderCallback = selectFolderButtonTapCallback {
            validSelectFolderCallback()
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
