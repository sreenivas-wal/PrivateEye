//
//  PaginationQuery.swift
//  MyMobileED
//
//  Created by Admin on 1/27/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

class PaginationQuery: NSObject {
    let ItemsOnPageDefault: Int = 10
    
    var limit: Int = 0
    var page: Int = 0

    func nextPage() {
        page = page + 1
    }
}
