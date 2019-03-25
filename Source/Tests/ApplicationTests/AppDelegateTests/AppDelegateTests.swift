//
//  AppDelegateTests.swift
//  MyMobileED
//
//  Created by Admin on 17.08.15.
//  Copyright (c) 2015 Company. All rights reserved.
//

import UIKit
import XCTest

class AppDelegateTests: XCTestCase {
    
    func testWindowProperty() {
        let appDelegate = AppDelegate()
        let window = UIWindow()
        
        appDelegate.window = window
        
        XCTAssertEqual(window, appDelegate.window!)
    }
}
