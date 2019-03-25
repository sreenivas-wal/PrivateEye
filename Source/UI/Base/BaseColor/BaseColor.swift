//
//  BaseColor.swift
//  MyMobileED
//
//  Created by Admin on 1/20/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

enum BaseColors {
    case deviceLightGreen
    case deviceGray
    case darkBlue
    case lightBlue
    case darkRed
    case pickerGray
    case lightGreenColor
    case orange
    
    func color() -> UIColor {
        switch self {
        case .deviceLightGreen:
            return UIColor(red: 105/255, green: 180/255, blue: 23/255, alpha: 1.0)
        case .deviceGray:
            return UIColor(red: 41/255, green: 45/255, blue: 53/255, alpha: 0.6)
        case .darkBlue:
            return UIColor(red: 24/255, green: 82/255, blue: 137/255, alpha: 1)
        case .lightBlue:
            return UIColor(red: 48/255, green: 100/255, blue: 149/255, alpha: 1)
        case .darkRed:
            return UIColor(red: 208/255, green: 2/255, blue: 27/255, alpha: 1)
        case .pickerGray:
            return UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        case .lightGreenColor:
            return UIColor(red: 46/255, green: 222/255, blue: 183/255, alpha: 0.9)
        case .orange:
            return UIColor(red: 255/255, green: 162/255, blue: 62/255, alpha: 1)
        }
    }
}
