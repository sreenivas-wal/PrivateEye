//
//  URL+Support.swift
//  MyMobileED
//
//  Created by Admin on 8/9/17.
//  Copyright © 2017 Company. All rights reserved.
//

import Foundation

extension URL {
    static func supportUrl(fromHostLink hostLink: String) -> URL {
        let supportString = String(format: "%@/support", hostLink)
        
        return URL(string: supportString)!
    }
    
    static func touchIDSettingsUrl() -> URL {
        return URL(string: UIApplicationOpenSettingsURLString)!
    }
    
    static func signUpDoximityUrl() -> URL {
        return URL(string: "https://www.doximity.com/sign_ups/new")!
    }
}
