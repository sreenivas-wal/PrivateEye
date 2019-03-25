//
//  MembersDataSourceProtocol.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 1/25/18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit

protocol MembersDataSourceProtocol: class {
    func fetchMembers()
    func isGroupLeader() -> Bool
    func contentHeight() -> CGFloat
}
