//
//  SelectFolderViewController.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 8/17/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

protocol SelectFolderViewControllerDelegate: class {
    func selectFolderViewController(_ sender: SelectFolderViewController, didSelectFolder folder: Folder?)
}

class SelectFolderViewController: BaseContentViewController, SelectFolderDataSourceDelegate {
    
    @IBOutlet weak var saveButton: UIButton!
    
    private var dataSource: SelectFolderDataSourceProtocol?
    
    weak var delegate: SelectFolderViewControllerDelegate?
    var uploadingPhoto: Photo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSelectFolderDataSource()
        convigureHeaderBar()
        
        dataSource?.reloadContent(forFolder: selectedFolder)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.isStatusBarHidden = false
    }
    
    // MARK: - Overriden
    
    override func createFolder(withName name: String) {
        self.networkManager?.createFolder(withTitle: name, forParentFolder: self.selectedFolder, group: nil, successBlock: { (response) -> (Void) in
            self.handleSuccessFolderSaving()
        }, failureBlock: { (error) -> (Void) in
            if error.code == folderDuplicateNameErrorCode {
                self.showDuplicateFolderNameAlertController()
            } else {
                self.presentAlert(withMessage: error.message)
            }
        })
    }
    
    // MARK: Actions
    
    @IBAction func buttonCancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func buttonSaveTapped(_ sender: Any) {
        let folder = selectedFolder
        delegate?.selectFolderViewController(self, didSelectFolder: folder)
    }
    
    // MARK: - Private
    
    private func configureSelectFolderDataSource() {
        let dataSource = SelectFolderDataSource(tableView: self.tableView, networkManager: networkManager!, delegate: self, selectedFolder: selectedFolder)
        self.dataSource = dataSource
    }

    private func convigureHeaderBar() {
        var parentFolderTitle = "MY PHOTOS"
        
        if let folderTitle = selectedFolder?.title {
            parentFolderTitle = folderTitle.uppercased()
        }
        
        headerBar?.textTitleLabel = parentFolderTitle
    }
    
    // MARK: - SelectFolderDataSourceDelegate
    
    func selectFolderDataSource(_ sender: SelectFolderDataSourceProtocol, didTapFolder folder: Folder) {
        router?.showSelectFolderViewController(fromViewController: self,
                                               withAnimation: true,
                                               forFolder: folder,
                                               uploadingPhoto: uploadingPhoto!,
                                               delegate: delegate!)
    }
    
    func selectFolderDataSourceDidTapNewFolder(_ sender: SelectFolderDataSourceProtocol) {
        showNewFolderAlertController()
    }

    // MARK: - Overridden
    
    override func handleSuccessFolderSaving() {
        self.dataSource?.reloadContent(forFolder: self.selectedFolder)
    }
    
    // MARK: - HeaderBarDelegate
    
    func headerBar(_ header: HeaderBar, didTapLeftButton left: UIButton) {
        UIApplication.shared.isStatusBarHidden = true
        
        _ = self.navigationController?.popViewController(animated: true)
    }

}
