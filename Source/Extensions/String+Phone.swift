//
//  String+Phone.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 12/27/17.
//  Copyright © 2017 Company. All rights reserved.
//

import Foundation

extension String {
    func removedFormatString() -> String {
        let toBeRemoved = ["(", ")", "-", " ", " "]
        
        var resultString = self
        toBeRemoved.forEach({ (elementToRemove) in
            resultString = resultString.replacingOccurrences(of: elementToRemove, with: "")
        })
        
        return resultString
    }
}
