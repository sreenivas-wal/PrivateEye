//
//  SelectFolderDataSourceProtocol.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 8/18/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

@objc protocol SelectFolderDataSourceProtocol: class {
    func reloadContent(forFolder folder: Folder?)
    
    @objc optional func didDeleteFolder(inCell cell: FolderTableViewCell)
    @objc optional func didChangeFolderTitle(_ title: String, inCell cell: FolderTableViewCell)
}
