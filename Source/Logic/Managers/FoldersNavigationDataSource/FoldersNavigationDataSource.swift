//
//  FoldersNavigationDataSource.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 9/21/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

class FoldersNavigationDataSource: FoldersNavigationDataSourceProtocol {

    private var foldersStack: [Folder] = []
    
    // MARK: - FoldersNavigationDataSourceProtocol
    
    func push(_ folder: Folder) {
        foldersStack.append(folder)
    }
    
    func replaceTop(_ folder: Folder) {
        _ = foldersStack.popLast()
        foldersStack.append(folder)
    }
    
    func pop() -> Folder? {
        let folder = foldersStack.popLast()
        foldersStack.last?.subfolders.forEach({ (folder) in
            folder.contentLoaded = false
        })
        
        return folder
    }
    
    func peek() -> Folder? {
        return foldersStack.last
    }
    
    func fetchAll() -> [Folder] {
        return foldersStack
    }
    
    func replace(withItems items: [Folder]) {
        foldersStack = items
    }
    
    func needUpdateStack() {
        for folder in foldersStack {
            folder.contentLoaded = false
        }
    }
    
    func pop(to folder: Folder) {
        
        if foldersStack.isEmpty == false {
            
            for (index, currentFolder) in foldersStack.enumerated().reversed() {
                
                if currentFolder.folderID == folder.folderID {
                    break
                }
                
                if index == 0 {
                    break
                }
                
                let _ = self.pop()
            }
        }
    }
    
    func popToRoot() {
        
        for (index, _) in foldersStack.enumerated().reversed() {
            
            if index == 0 {
                break
            }
            
            let _ = self.pop()
        }
    }
}
