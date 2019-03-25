//
//  Validator.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 9/26/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

class Validator: NSObject, ValidatorProtocol {

    private let emailRegex = "^[^@\\s]+@([^@\\s]+\\.)+[^@\\s]+$"
    
    // MARK: - ValidatorProtocol
    
    func isValidEmail(_ email: String) -> Bool {
        return !isEmpty(email) && validateEmail(email)
    }

    // MARK: - Private
    
    private func isEmpty(_ text: String) -> Bool {
        let trimText = text.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        return (trimText.count == 0)
    }
    
    private func validateEmail(_ email: String) -> Bool {
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        let result = emailTest.evaluate(with: email)
        
        return result
    }
}
