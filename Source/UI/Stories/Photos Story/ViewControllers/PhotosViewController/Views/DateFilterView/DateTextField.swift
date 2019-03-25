//
//  DateTextField.swift
//  MyMobileED
//
//  Created by Admin on 2/7/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

class DateTextField: UITextField {

    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
}
