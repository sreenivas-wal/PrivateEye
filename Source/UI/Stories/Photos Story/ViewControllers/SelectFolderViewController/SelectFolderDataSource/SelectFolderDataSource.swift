//
//  SelectFolderDataSource.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 8/18/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

@objc protocol SelectFolderDataSourceDelegate: class {
    func selectFolderDataSource(_ sender: SelectFolderDataSourceProtocol, didTapFolder folder: Folder)
    @objc optional func selectFolderDataSourceDidTapNewFolder(_ sender: SelectFolderDataSourceProtocol)
    @objc optional func selectFolderDataSource(_ sender: SelectFolderDataSourceProtocol, willDeleteFolder folder: Folder, inCell cell: FolderTableViewCell)
    @objc optional func selectFolderDataSource(_ sender: SelectFolderDataSourceProtocol, willEditFolder folder: Folder, inCell cell: FolderTableViewCell)
    @objc optional func selectFolderDataSource(_ sender: SelectFolderDataSourceProtocol, willShareFolder folder: Folder, inCell cell: FolderTableViewCell)
}

enum SelectFolderSections: Int {
    case folders
    case newFolder
    
    static var numberOfSections: Int { return 2 }
    
    func cellHeight() -> CGFloat {
        switch self {
        case .folders:
            return 92
        case .newFolder:
            return 60
        }
    }
}

class SelectFolderDataSource: BaseFolderDataSource, SelectFolderDataSourceProtocol {

    weak var delegate: SelectFolderDataSourceDelegate?
    
    private var selectedFolder: Folder?

    init(tableView: UITableView, networkManager: PhotosNetworkProtocol, delegate: SelectFolderDataSourceDelegate, selectedFolder: Folder?) {
        super.init(tableView: tableView, networkManager: networkManager)
        
        self.delegate = delegate
        self.selectedFolder = selectedFolder
        
        configureQuery()
    }
    
    // MARK: - Private
    
    private func configureQuery() {
        paginationQuery = PhotosPaginationQuery()
        paginationQuery.ownershipFilter = .my
        paginationQuery.folderID = selectedFolder?.folderID
    }
    
    private func convertToViewModels(_ folders: [Folder]) -> [FolderViewModel] {
        var viewModels = [FolderViewModel]()
        
        for folder in folders {
            let viewModel = FolderViewModel(title: folder.title!, isEditable: folder.isEditable, changeble: true, isHighlighted: false)
            viewModels.append(viewModel)
        }
        
        return viewModels
    }

    // MARK: - SelectFolderDataSourceProtocol
    
    func reloadContent(forFolder folder: Folder?) {
        selectedFolder = folder
    
        _ = networkManager?.getFolderContents(withQuery: paginationQuery, successBlock: { (response) -> (Void) in
            let photoLoadingResponse = response.object as! PhotoLoadingPageResponse
            let folders = photoLoadingResponse.folder!.subfolders
            self.folders = folders
            self.folderViewModels = self.convertToViewModels(folders)
            
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }, failureBlock: { (error) -> (Void) in
            print("Error = \(error.message)")
        })
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let folderSection = SelectFolderSections(rawValue: indexPath.section)
        
        return folderSection!.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch SelectFolderSections(rawValue: indexPath.section) {
        case .folders?:
            let folder = folders[indexPath.row]
            
            if folder.isEditable {
                delegate?.selectFolderDataSource(self, didTapFolder: folder)
            }
            
            break
        case .newFolder?:
            delegate?.selectFolderDataSourceDidTapNewFolder?(self)
            break
        case .none:
            break
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SelectFolderSections.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch SelectFolderSections(rawValue: section) {
        case .folders?:
            return folders.count
        case .newFolder?:
            return 1
        case .none:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch SelectFolderSections(rawValue: indexPath.section) {
        case .folders?:
            let folderViewModel = folderViewModels[indexPath.row]
            let folderCell = tableView.dequeueReusableCell(withIdentifier: "FolderTableViewCell") as! FolderTableViewCell
            folderCell.configureCellWithFolder(folderViewModel)
            
            return folderCell
        case .newFolder?:
            let newFolderCell = tableView.dequeueReusableCell(withIdentifier: "AddItemTableViewCell") as! AddItemTableViewCell
            newFolderCell.configure(with: "+ ADD NEW FOLDER")
            
            return newFolderCell
        case .none:
            return UITableViewCell()
        }
    }

}
