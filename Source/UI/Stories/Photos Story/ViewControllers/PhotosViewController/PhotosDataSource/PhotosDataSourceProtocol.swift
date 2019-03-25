//
//  PhotosDataSourceProtocol.swift
//  MyMobileED
//
//  Created by Admin on 1/27/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

protocol PhotosDataSourceProtocol: SelectFolderDataSourceProtocol {
    func ownershiFilter() -> PhotosOwnership
    func changeOwnershipFilter(_ filter: PhotosOwnership)
    func dateFilter() -> PhotosFilterDate
    func changeDateFilter(_ filter: PhotosFilterDate)
    func didDeletePhoto(inCell cell: PhotoTableViewCell)
    func didChangeTitlePhoto(inCell cell: PhotoTableViewCell, withTitle title: String)
    func didShareContent()
    func changeCustomDateFilter(withStartDate startDate: Date, betweenEndDate endDate: Date)
    func searchPhotos(withValues values: String)
    func cancelSearch()
    func startCustomDate() -> Date?
    func endCustomDate() -> Date?
    func canEditFolderContent() -> Bool
    var isMyFolder: Bool! { get set }
}
