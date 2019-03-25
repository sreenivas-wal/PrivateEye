//
//  Node.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 8/21/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import SwiftyJSON

class Node: NSObject {

    var nodeID: String?
    var uri: String?
    
    init?(json: JSON) {
        guard let nodeID = json["nid"].string else { return }
        guard let uri = json["uri"].string else { return }
        
        self.nodeID = nodeID
        self.uri = uri
    }
}
