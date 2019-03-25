//
//  PhotosPaginationQuery.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 8/23/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

enum PhotosOwnership {
    case all
    case allInFolder
    case my
    case group(group: Group)
    
    func associatedValue() -> Any? {
        switch self {
        case .all:
            return nil
        case .allInFolder:
            return nil
        case .my:
            return nil
        case .group(let group):
            return group
        }
    }
}

extension PhotosOwnership: Equatable {
    static func == (lhs: PhotosOwnership, rhs: PhotosOwnership) -> Bool {
        switch (lhs, rhs) {
        case (.all, .all):
            return true
        case (.allInFolder, .allInFolder):
            return true
        case (.my, .my):
            return true
        case let (.group(lGroup), .group(rGroup)):
            return lGroup == rGroup
        default:
            return false
        }
    }
}

enum PhotosFilterDate {
    case none
    case yesterday
    case week
    case month
    case custom
    
    var title: String {
        switch self {
        case .none: return ""
        case .yesterday: return "Yesterday"
        case .week: return "Last Week"
        case .month: return "Last Month"
        case .custom: return "Select Dates"
        }
    }
}

class PhotosPaginationQuery: PaginationQuery {

    var ownershipFilter: PhotosOwnership = .my
    var dateFilter: PhotosFilterDate = .none
    var searchValueString: String?
    var titleSearchValue: String?
    var hasSearch: Bool = false
    var hasFilter: Bool = false
    
    var folderID: String?
    var isSharedWithMe: Bool = false
    
    var endDate: Date?
    var startDate: Date?
    
}
