//
//  ValidatorProtocol.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 9/26/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

protocol ValidatorProtocol: class {
    func isValidEmail(_ email: String) -> Bool
}
