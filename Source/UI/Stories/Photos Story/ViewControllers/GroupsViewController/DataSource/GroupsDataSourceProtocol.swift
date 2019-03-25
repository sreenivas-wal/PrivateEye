//
//  GroupsDataSourceProtocol.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 1/22/18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation

protocol GroupsDataSourceProtocol: class {
    func reloadGroups(withKeywords keywords: String)
}
