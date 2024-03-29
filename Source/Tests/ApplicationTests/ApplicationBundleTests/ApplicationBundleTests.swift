//
//  ApplicationBundleTests.swift
//  MyMobileED
//
//  Created by Admin on 17.08.15.
//  Copyright (c) 2015 Company. All rights reserved.
//

import XCTest

class ApplicationBundleTests: XCTestCase {
    
    var currentBundle : NSBundle?
    
    //MARK: -
    
    override func setUp() {
        super.setUp()
        
        currentBundle = NSBundle(forClass: self.dynamicType)
    }
    
    override func tearDown() {
        currentBundle = nil
        
        super.tearDown()
    }
    
    //MARK: -
    
    func testThatLogicBundleLoaded() {
        let expectedExecutable = "ApplicationTests"
        
        XCTAssertEqual(currentBundle!.objectForInfoDictionaryKey("CFBundleExecutable") as? String, expectedExecutable)
        XCTAssertTrue(currentBundle!.loaded)
    }
}
