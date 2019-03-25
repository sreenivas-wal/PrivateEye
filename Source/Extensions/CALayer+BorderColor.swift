//
//  a.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 8/28/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

extension CALayer {
    var borderUIColor: UIColor {
        get {
            return UIColor(cgColor: self.borderColor!)
        } set {
            self.borderColor = newValue.cgColor
        }
    }
}
