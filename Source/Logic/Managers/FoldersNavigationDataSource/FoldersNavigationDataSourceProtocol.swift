//
//  FoldersNavigationDataSourceProtocol.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 9/21/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

protocol FoldersNavigationDataSourceProtocol: class {
    
    func push(_ folder: Folder)
    func replaceTop(_ folder: Folder)
    func pop() -> Folder?
    func peek() -> Folder?
    func fetchAll() -> [Folder]
    func replace(withItems items:[Folder])
    func needUpdateStack()
    func pop(to folder: Folder)
    func popToRoot()
}
