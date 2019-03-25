//
//  CommentsDataSourceProtocol.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 10/18/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

protocol CommentsDataSourceProtocol: class {
    func reloadContent()
    func setEditing(editing: Bool, animated: Bool)
    func selectedComments() -> [Comment]
}
