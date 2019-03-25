//
//  UploadedImage.swift
//  MyMobileED
//
//  Created by Admin on 1/25/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import SwiftyJSON

class UploadedImage: NSObject {
    
    var fid: String?
    var uri: String?
    
    init(fid: String, uri: String) {
        self.fid = fid
        self.uri = uri
    }
    
    init?(json: JSON) {
        guard let fid = json["fid"].string else { return nil }
        guard let uri = json["uri"].string else { return nil }
        
        self.fid = fid
        self.uri = uri
    }
}
