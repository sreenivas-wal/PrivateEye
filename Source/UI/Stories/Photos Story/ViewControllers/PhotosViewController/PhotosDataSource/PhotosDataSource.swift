//
//  PhotoDataSource.swift
//  MyMobileED
//
//  Created by Admin on 1/20/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import MGSwipeTableCell

enum FolderContentSections: Int {
    case folders = 0
    case newFolder
    case photos
    
    static var numberOfSections: Int { return 3 }
    
    func cellHeight() -> CGFloat {
        switch self {
        case .folders:
            return 92
        case .newFolder:
            return 60
        case .photos:
            return UITableViewAutomaticDimension
        }
    }
}

protocol PhotosDataSourceDelegate: SelectFolderDataSourceDelegate {
    func photosDataSource(dataSource: PhotosDataSource, willEditPhoto photo: Photo, inCell cell: PhotoTableViewCell)
    func photosDataSource(dataSource: PhotosDataSource, willDeletePhoto photo: Photo,currentUser:User, inCell cell: PhotoTableViewCell)
    func photosDataSource(dataSource: PhotosDataSource, willSharePhoto photo: Photo, inCell cell: PhotoTableViewCell)
    func photosDataSource(dataSource: PhotosDataSource, didTapPhoto photo: Photo, canEditPhoto canEdit: Bool)
    func photosDataSource(dataSource: PhotosDataSource, isEmptyPhotos isEmpty: Bool)
    func photosDataSourceNewPhotosAdded(dataSource: PhotosDataSource)
    func photosDataSource(dataSource: PhotosDataSource, didLoadedFolder folder: Folder?)
    func selectFolderDataSourceDidTapNewFolder(_ sender: SelectFolderDataSourceProtocol)
}

class PhotosDataSource: BaseFolderDataSource, PhotosDataSourceProtocol, PhotoTableViewCellDelegate, MGSwipeTableCellDelegate, SelectFolderDataSourceProtocol {
    
    private let estimatedRowHeight: CGFloat = 100
    private let disableContentAlpha: CGFloat = 0.5
    let defaults = UserDefaults.standard
    
    weak var delegate: (PhotosDataSourceDelegate & SelectFolderDataSourceDelegate)?
    var photoViewController :PhotosViewController?
    private var currentUser: User?
    private var photosArray: [Photo] = [Photo]()
    private var photosRequest: NetworkRequest?
    private var photosProvider: PhotosProviderProtocol?
    private var selectedFolder: Folder?
    private var alertsManager: AlertsManager?
    private var router:PhotosRouterProtocol?
    private var hideOpenedCellCallback: (() -> ())?
    private var isEnabledContent: Bool = false
    var isMyFolder: Bool! = true
    
    init(tableView: UITableView,
         networkManager: PhotosNetworkProtocol,
         delegate: PhotosDataSourceDelegate,
         router: PhotosRouterProtocol,
         photosProvider: PhotosProviderProtocol,
         currentUser: User,
         alertsManager: AlertsManager,
         viewContoller:PhotosViewController,
         isEnabledContent: Bool) {
        self.photoViewController = viewContoller
        super.init(tableView: tableView, networkManager: networkManager)
        self.alertsManager = alertsManager
        self.delegate = delegate
        self.photosProvider = photosProvider
        self.currentUser = currentUser
        self.isEnabledContent = isEnabledContent
        self.router = router
        configureTableView()
    }
    
    override func registerCells() {
        super.registerCells()
        
        tableView?.register(UINib.init(nibName: "PhotoTableViewCell", bundle: nil), forCellReuseIdentifier: "PhotoTableViewCell")
    }
    
    // MARK: PhotosDataSourceProtocol
    
    func reloadContent(forFolder folder: Folder?) {
        
        selectedFolder = folder
        
        paginationQuery.folderID = folder?.folderID
        paginationQuery.isSharedWithMe = !canEditFolderContent()
        
        clearFolderContent()
        
        if let folder = folder, ownershiFilter() != .allInFolder, !paginationQuery.hasFilter {
            if folder.contentLoaded {
                reloadFolderDataSource(withFolders: folder.subfolders, photos: folder.photos)
                return
            }
        }
        
        tableView?.reloadData()
        delegate?.photosDataSource(dataSource: self, isEmptyPhotos: false)
        
        if photosRequest != nil {
            photosRequest?.dataRequest?.cancel()
        }
        
        photosRequest = self.networkManager?.getFolderContents(withQuery: paginationQuery, successBlock: { (response) -> (Void) in
            let photoLoadingResponse = response.object as! PhotoLoadingPageResponse            
            self.paginationQuery.limit = photoLoadingResponse.limit
            
            let photos = photoLoadingResponse.folder!.photos
            let folders = photoLoadingResponse.folder!.subfolders
            self.reloadFolderDataSource(withFolders: folders, photos: photos)
            
            if self.ownershiFilter() != .allInFolder, !self.paginationQuery.hasSearch, !self.paginationQuery.hasFilter {
                self.selectedFolder?.subfolders = folders
                self.selectedFolder?.photos = photos
                self.selectedFolder?.contentLoaded = true
                self.delegate?.photosDataSource(dataSource: self, didLoadedFolder: self.selectedFolder)
            }
            
            self.photosRequest = nil
            
            let shouldCheckEmpty = self.shouldCheckEmptyPhotos()
            var isEmptyFolderContent = (photos.count == 0)
            
            if case .group(_) = self.paginationQuery.ownershipFilter {
                isEmptyFolderContent = isEmptyFolderContent && (folders.count == 0)
            }
            
            if isEmptyFolderContent && shouldCheckEmpty {
                self.delegate?.photosDataSource(dataSource: self, isEmptyPhotos: true)
            } else {
                self.delegate?.photosDataSource(dataSource: self, isEmptyPhotos: false)
                
                if self.paginationQuery.ownershipFilter == .all
                    && self.paginationQuery.dateFilter == .none && self.paginationQuery.searchValueString == nil && self.paginationQuery.titleSearchValue == nil {
                    for currentPhoto in photos {
                        
                        if let lastUpdateTimestamp = self.lastUpdateTimestamp(),
                            let currentPhotoTime = currentPhoto.timestamp,
                            let currentPhotoFormattedDate = DateHelper.dateFrom(string: currentPhotoTime),
                            let lastUpdatedDate = DateHelper.dateFrom(string: lastUpdateTimestamp),
                            currentPhotoFormattedDate > lastUpdatedDate {
                            
                            self.delegate?.photosDataSourceNewPhotosAdded(dataSource: self)
                            break
                        }
                    }
                    
                    self.saveUpdateTimestamp()
                }
            }
        }, failureBlock: { (error) -> (Void) in
            print("Error = \(error.message)")
            self.photosRequest = nil
        })
    }
    
    func ownershiFilter() -> PhotosOwnership {
        return paginationQuery.ownershipFilter
    }
    
    func changeOwnershipFilter(_ filter: PhotosOwnership) {
        if filter == .my {
            paginationQuery.searchValueString = nil
            paginationQuery.titleSearchValue = nil
        }
        
        paginationQuery.ownershipFilter = filter
    }
    
    func dateFilter() -> PhotosFilterDate {
        return paginationQuery.dateFilter
    }
    
    func changeDateFilter(_ filter: PhotosFilterDate) {
        paginationQuery.dateFilter = filter
        paginationQuery.hasFilter = (filter != .none)
        
        selectedFolder?.contentLoaded = false
    }
    
    func changeCustomDateFilter(withStartDate startDate: Date, betweenEndDate endDate: Date) {
        paginationQuery.dateFilter = .custom
        paginationQuery.startDate = startDate
        paginationQuery.endDate = endDate
        paginationQuery.hasFilter = true
        
        selectedFolder?.contentLoaded = false
    }
    
    func didDeletePhoto(inCell cell: PhotoTableViewCell) {
        if let indexPath: IndexPath = (tableView?.indexPath(for: cell)) {
            DispatchQueue.main.async {
                self.photosArray.remove(at: indexPath.row)
                self.tableView?.deleteRows(at: [indexPath], with: .right)
            }
        }
    }
    
    func didChangeTitlePhoto(inCell cell: PhotoTableViewCell, withTitle title: String) {
        if let indexPath: IndexPath = (tableView?.indexPath(for: cell)) {
            DispatchQueue.main.async {
                self.photosArray[indexPath.row].title = title
                self.tableView?.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func didDeleteFolder(inCell cell: FolderTableViewCell) {
        if let indexPath: IndexPath = (tableView?.indexPath(for: cell)) {
            DispatchQueue.main.async {
                self.folders.remove(at: indexPath.row)
                self.folderViewModels.remove(at: indexPath.row)
                self.tableView?.deleteRows(at: [indexPath], with: .right)
            }
        }
    }
    
    func didChangeFolderTitle(_ title: String, inCell cell: FolderTableViewCell) {
        if let indexPath: IndexPath = (tableView?.indexPath(for: cell)) {
            DispatchQueue.main.async {
                self.folders[indexPath.row].title = title
                self.folderViewModels[indexPath.row].title = title
                self.tableView?.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func didShareContent() {
        if let validOpenedCellCallback = hideOpenedCellCallback {
            validOpenedCellCallback()
            
            hideOpenedCellCallback = nil
        }
    }
    
    func startCustomDate() -> Date? {
        if let startDate = paginationQuery.startDate {
            return startDate
        }
        
        return nil
    }
    
    func endCustomDate() -> Date? {
        if let endDate = paginationQuery.endDate {
            return endDate
        }
        
        return nil
    }
    
    func searchPhotos(withValues values: String) {
        paginationQuery.hasSearch = true
        
        if values.count > 0 {
            photosRequest = self.networkManager?.usernameAutocomplete(withUsernames: values, successBlock: { (response) -> (Void) in
                let usernamesDictionary = response.object as! Dictionary<String, Any>
                let usernamesString = self.usernamesString(fromDictionary: usernamesDictionary)
                
                self.paginationQuery.searchValueString = usernamesString
                self.paginationQuery.titleSearchValue = values
                
                self.selectedFolder?.contentLoaded = false
                self.reloadContent(forFolder: self.selectedFolder)
            }, failureBlock: { (error) -> (Void) in
                self.photosRequest = nil
                self.delegate?.photosDataSource(dataSource: self, isEmptyPhotos: true)
            })
        }
    }
    
    private func usernamesString(fromDictionary dictionary: Dictionary<String, Any>) -> String {
        let usernamesArray = Array(dictionary.keys)
        var usernamesString = ""
        
        if usernamesArray.count > 0 {
            usernamesString = usernamesArray[0]
            
            for index in 1 ..< usernamesArray.count {
                usernamesString = usernamesString + "," + usernamesArray[index]
            }
        }
        
        return usernamesString
    }
    
    func cancelSearch() {
        paginationQuery.searchValueString = nil
        paginationQuery.titleSearchValue = nil
        paginationQuery.hasSearch = false
        
        selectedFolder?.contentLoaded = false
        
        reloadContent(forFolder: selectedFolder)
    }
    
    func canEditFolderContent() -> Bool {
        guard let isEditable = selectedFolder?.isEditable else { return true }
        guard let uid = selectedFolder?.uid else { return isEditable }
        let isOwned = (uid == currentUser?.userID)
        
        return isEditable && isOwned
    }
    
    // MARK: Private
    
    private func configureTableView() {
        tableView?.estimatedRowHeight = estimatedRowHeight
    }
    
    private func reloadFolderDataSource(withFolders subfolders: [Folder], photos: [Photo]) {
        photosArray.append(contentsOf: photos)
        folders.append(contentsOf: subfolders)
        folderViewModels.append(contentsOf: self.convertToViewModels(subfolders))
        tableView?.reloadData()
    }
    
    private func clearFolderContent() {
        photosArray = []
        folders = []
        folderViewModels = []
        
        paginationQuery.page = 0
    }
    
    private func saveUpdateTimestamp() {
        let timestampString = DateHelper.stringDateFrom(Date())
        defaults.set(timestampString, forKey: "LastUpdateTimestamp")
    }
    
    private func lastUpdateTimestamp() -> String? {
        return defaults.string(forKey: "LastUpdateTimestamp")
    }
    
    private func convertToViewModel(_ photo: Photo) -> PhotoViewModel {
        let date = DateHelper.dateFrom(string: photo.timestamp!)
        let viewModel = PhotoViewModel()
        viewModel.title = photo.title
        viewModel.imageLink = photo.link
        
        if paginationQuery.ownershipFilter == .all {
            viewModel.userTimestamp = String(format:"By %@ on %@", photo.username!, DateHelper.formatedStringDate(fromDate: date!))
        } else {
            viewModel.userTimestamp = DateHelper.formatedStringDateWithDayName(fromDate: date!)
        }
        
        viewModel.time = DateHelper.formatedStringTime(fromDate: date!)
        
        let isSharedWithMe = !canEditFolderContent()
        
        var isHighlighted: Bool = false
        if photo.isUpdated && isSharedWithMe {
            isHighlighted = true
        }
        
        viewModel.isHighlighted = isHighlighted
        
        return viewModel
    }
    
    private func canEditContent(of folder: Folder) -> Bool {
        
        let isEditable = folder.isEditable
        guard let uid = folder.uid else { return false }
        let isOwned = (uid == currentUser?.userID)
        
        return isEditable && isOwned
    }
    
    private func convertToViewModels(_ folders: [Folder]) -> [FolderViewModel] {
        var viewModels = [FolderViewModel]()
        
        for folder in folders {
            
            let isSharedWithMe = !canEditContent(of: folder)
            let isHighlighted = folder.isUpdated && isSharedWithMe
            
            let viewModel = FolderViewModel(title: folder.title!, isEditable: folder.isEditable, changeble: false, isHighlighted: isHighlighted)
            viewModels.append(viewModel)
        }
        
        return viewModels
    }
    
    private func shouldCheckEmptyPhotos() -> Bool {
        let hasSearchValue = (self.paginationQuery.searchValueString?.count != 0 ||
            self.paginationQuery.titleSearchValue?.count != 0) &&
            (self.paginationQuery.hasSearch)
        
        if case .group(let group) = self.ownershiFilter() {
            if isEnabledContent {
                return (currentUser?.userID != group.ownerId)
            }
            
            return true
        }
        
        return hasSearchValue
    }
    
    // MARK: UITableViewDelegate & UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch paginationQuery.ownershipFilter {
        case .my, .group(_):
            return FolderContentSections.numberOfSections
        case .all, .allInFolder:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch paginationQuery.ownershipFilter {
        case .my, .group(_):
            let folderSection = FolderContentSections(rawValue: indexPath.section)
            
            return folderSection!.cellHeight()
        case .all, .allInFolder:
            return FolderContentSections.photos.cellHeight()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch paginationQuery.ownershipFilter {
        case .group(_):
            switch FolderContentSections(rawValue: section) {
            case .folders?:
                if paginationQuery.hasSearch {
                    return 0
                }
                
                return folders.count
            case .photos?:
                return photosArray.count
            case .newFolder?, .none:
                return canChangeContent() ? 1 : 0
            }
        case .my:
            switch FolderContentSections(rawValue: section) {
            case .folders?:
                if paginationQuery.hasSearch {
                    return 0
                }
                
                return folders.count
            case .newFolder?:
                if paginationQuery.isSharedWithMe {
                    return 0
                }
                return (canEditFolderContent() && !paginationQuery.hasSearch || canChangeContent()) ? 1 : 0
            case .photos?:
                return photosArray.count
            case .none:
                return 0
            }
        case .all, .allInFolder:
            return photosArray.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch paginationQuery.ownershipFilter {
        case .my, .group(_):
            switch FolderContentSections(rawValue: indexPath.section) {
            case .folders?:
                let cell = createFolderTableViewCell(inTableView: tableView, forIndexPath: indexPath)
                
                return cell
            case .newFolder?:
                let newFolderCell = tableView.dequeueReusableCell(withIdentifier: "AddItemTableViewCell") as! AddItemTableViewCell
                newFolderCell.configure(with: "+ ADD NEW FOLDER")
                
                return newFolderCell
            case .photos?:
                let cell = createPhotoTableViewCell(inTableView: tableView, forIndexPath: indexPath)
                
                return cell
            case .none:
                return UITableViewCell()
            }
        case .all, .allInFolder:
            let cell = createPhotoTableViewCell(inTableView: tableView, forIndexPath: indexPath)
            
            return cell
        }
    }
    
    private func createPhotoTableViewCell(inTableView tableView: UITableView, forIndexPath indexPath: IndexPath) -> PhotoTableViewCell {
        let currentPhoto = photosArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoTableViewCell") as! PhotoTableViewCell
        cell.photoDelegate = self
        cell.delegate = self
        cell.configureCell(with: convertToViewModel(currentPhoto))
        cell.contentView.alpha = isEnabledContent ? 1 : disableContentAlpha
        
        if canEditFolderContent() && canEditPhoto(currentPhoto) {
            
            cell.rightSwipeSettings.transition = .static
            
            let editButton = createTableViewCellEditButton(withCallback: { (cell) -> Bool in
                self.delegate?.photosDataSource(dataSource: self, willEditPhoto: currentPhoto, inCell: cell as! PhotoTableViewCell)
                return false
            })
            
            // changed right buttons
            let deleteButton = createTableViewCellDeleteButton(withCallback: { (cell) -> Bool in
                self.delegate?.photosDataSource(dataSource: self, willDeletePhoto: currentPhoto,currentUser: self.currentUser!, inCell: cell as! PhotoTableViewCell)
                return true
            })
            
            if case .group = ownershiFilter() {
                if self.isEnabledContent { cell.rightButtons = [editButton,deleteButton] }
                return cell
            }
            let shareButton = createTableViewCellShareButton(withCallback: { (cell) -> Bool in
                if self.currentUser?.userRole == "unverified" {
                    self.alertsManager?.showUnVerifiedAlertController(forViewController: self.photoViewController!, withOkayCallback: { () -> (Void) in
                        
                    }, withOpenCallback: { () -> (Void) in
                        self.verifyUserNow()
                    })
                } else if self.currentUser?.userRole == "in_progress" {
                    self.alertsManager?.showInReviewAlertController(forViewController: self.photoViewController!, withOkayCallback: { () -> (Void) in
                        
                    })
                }
                self.delegate?.photosDataSource(dataSource: self, willSharePhoto: currentPhoto, inCell: cell as! PhotoTableViewCell)
                self.hideOpenedCellCallback = { [weak cell] in cell?.hideSwipe(animated: true) }
                
                return false
            })
            cell.rightButtons = [deleteButton, editButton, shareButton]
        } else {
            cell.rightButtons = []
        }
        return cell
    }
    
    private func canEditPhoto(_ photo: Photo) -> Bool {
        return photo.uid == currentUser?.userID
    }
    
    private func canChangeContent() -> Bool {
        if case .group(let group) = ownershiFilter() {
            return (currentUser?.userID == group.ownerId) && isEnabledContent && isMyFolder && selectedFolder == nil
        }
        return !canEditFolderContent()
    }
    
    func createShareButton(in folderCell: FolderTableViewCell, withFolder folder: Folder) -> MGSwipeButton {
        return self.createTableViewCellShareButton { (cell) -> Bool in
            self.delegate?.selectFolderDataSource?(self, willShareFolder: folder, inCell: folderCell)
            self.hideOpenedCellCallback = { [weak cell] in cell?.hideSwipe(animated: true) }
            
            return false
        }
    }
    
    func createEditButton(in folderCell: FolderTableViewCell, withFolder folder: Folder) -> MGSwipeButton {
        return self.createTableViewCellEditButton(withCallback: { (cell) -> Bool in
            self.delegate?.selectFolderDataSource?(self, willEditFolder: folder, inCell: folderCell)
            return false
        })
    }
    
    func createDeleteButton(in folderCell: FolderTableViewCell, withFolder folder: Folder) -> MGSwipeButton {
        return self.createTableViewCellDeleteButton(withCallback: { (cell) -> Bool in
            self.delegate?.selectFolderDataSource?(self, willDeleteFolder: folder, inCell: folderCell)
            return true
        })
    }
    
    private func createFolderTableViewCell(inTableView tableView: UITableView, forIndexPath indexPath: IndexPath) -> FolderTableViewCell {
        let folder = folders[indexPath.row]
        let folderCell = tableView.dequeueReusableCell(withIdentifier: "FolderTableViewCell") as! FolderTableViewCell
        folderCell.configureCellWithFolder(folderViewModels[indexPath.row])
        folderCell.contentView.alpha = isEnabledContent ? 1 : disableContentAlpha
        
        if folder.isEditable && canEditFolderContent() && isEnabledContent {
            
            folderCell.rightSwipeSettings.transition = .static
            let editButton = self.createEditButton(in: folderCell, withFolder: folder)
            let deleteButton = self.createDeleteButton(in: folderCell, withFolder: folder)
            if case .group = ownershiFilter() {
                
                if self.canEditContent(of: folder) { folderCell.rightButtons = [editButton,deleteButton] }
                return folderCell
            }
            
            let shareButton = self.createShareButton(in: folderCell, withFolder: folder)
            folderCell.rightButtons = [deleteButton, editButton, shareButton]
        } else if !folder.isEditable {
            folderCell.rightSwipeSettings.transition = .static
            let deleteButton = self.createDeleteButton(in: folderCell, withFolder: folder)
            folderCell.rightButtons = [deleteButton]
        }
        return folderCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard FolderContentSections(rawValue: indexPath.section) == .photos || ownershiFilter() != .my else { return }
        
        if paginationQuery.page >= (paginationQuery.limit - 1) {
            return
        }
        
        if indexPath.row == photosArray.endIndex - 1 {
            paginationQuery.nextPage()
            
            photosRequest = self.networkManager?.getFolderContents(withQuery: paginationQuery, successBlock: { (response) -> (Void) in
                let response = response.object as! PhotoLoadingPageResponse
                let photos = response.folder!.photos
                self.photosArray.append(contentsOf: photos)
                
                var indexPathsForInsert = [IndexPath]()
                
                guard let firstPhoto = photos.first else { return }
                guard let startIndex = self.photosArray.index(of: firstPhoto) else { return }
                
                var section = 0
                
                switch self.ownershiFilter() {
                case .group(_), .my:
                    section = FolderContentSections.photos.rawValue
                    break
                case .all, .allInFolder:
                    break
                }
                
                for index in startIndex...self.photosArray.count - 1 {
                    indexPathsForInsert.append(IndexPath(row: index, section: section))
                }
                
                DispatchQueue.main.async {
                    self.tableView?.beginUpdates()
                    self.tableView?.insertRows(at: indexPathsForInsert, with: .none)
                    self.tableView?.endUpdates()
                }
                
                self.photosRequest = nil
            }, failureBlock: { (error) -> (Void) in
                self.photosRequest = nil
                print("Error")
            })
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch paginationQuery.ownershipFilter {
        case .all, .allInFolder:
            handlePhotoSelecting(at: indexPath)
            
            return
        case .my, .group(_):
            if !isEnabledContent { return }
            
            switch FolderContentSections(rawValue: indexPath.section) {
            case .folders?:
                let folder = folders[indexPath.row]
                delegate?.selectFolderDataSource(self, didTapFolder: folder)
                
                break
            case .newFolder?:
                if paginationQuery.ownershipFilter == .my {
                    delegate?.selectFolderDataSourceDidTapNewFolder?(self)
                } else {
                    if self.currentUser?.userRole == "unverified" {
                        self.alertsManager?.showUnVerifiedAlertController(forViewController: self.photoViewController!, withOkayCallback: { () -> (Void) in
                            
                        }, withOpenCallback: { () -> (Void) in
                            self.verifyUserNow()
                        })
                    } else if self.currentUser?.userRole == "in_progress" {
                        self.alertsManager?.showInReviewAlertController(forViewController: self.photoViewController!, withOkayCallback: { () -> (Void) in
                            
                        })
                    } else {
                        delegate?.selectFolderDataSourceDidTapNewFolder?(self)
                    }
                }
                break
            case .photos?:
                handlePhotoSelecting(at: indexPath)
                
                break
            case .none:
                break
            }
            
            break
        }
    }
    
    private func handlePhotoSelecting(at indexPath: IndexPath) {
        let index = indexPath.row
        let photo = photosArray[index]
        photo.folder = selectedFolder
        
        let canEdit = canEditPhoto(photo) && canEditFolderContent()
        delegate?.photosDataSource(dataSource: self, didTapPhoto: photo, canEditPhoto: canEdit)
    }
    
    func verifyUserNow(){
        self.router?.showPEVerificationViewController(fromViewController: self.photoViewController!, navigationController: (self.photoViewController?.navigationController)!, withAnimation: false)
    }
    
    // MARK: PhotoTableViewCellDelegate
    
    func loadImage(fromURL imageURL: URL, withBlock successBlock: @escaping (_ image: UIImage) -> ()) {
        _ = self.photosProvider?.retrievePreviewPhoto(byUrl: imageURL,successBlock: successBlock, failureBlock: { (message) in
            print("Message error = \(message)")
        })
    }
}
