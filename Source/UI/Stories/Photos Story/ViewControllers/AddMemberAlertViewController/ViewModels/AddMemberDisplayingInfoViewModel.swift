//
//  AddMemberDisplayingInfoViewModel.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 1/25/18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit

struct AddMemberDisplayingInfoViewModel {
    var title: String
    var descriptionText: String
    var contactViewModels: [ContactViewModel]
    var shouldShowAdditionalText: Bool
    var additionalText: String
    var minimumHeight: CGFloat
    
    static func existingMembersDisplayingViewModel(_ contactViewModels: [ContactViewModel]) -> AddMemberDisplayingInfoViewModel {
        let title = "Existing Members"
        let description = "The following users have already been added to the group:"
        
        return AddMemberDisplayingInfoViewModel(title: title,
                                                descriptionText: description,
                                                contactViewModels: contactViewModels,
                                                shouldShowAdditionalText: false,
                                                additionalText: "",
                                                minimumHeight: 160.0)
    }
    
    static func profilesNotFoundDisplayingViewModel(_ contactViewModels: [ContactViewModel]) -> AddMemberDisplayingInfoViewModel {
        let title = "Profiles Not Found"
        let description = "We are unable to find a PrivateEye profile for the following user(s):"
        let additionalText = "This invitation will be marked as pending in the ‘Groups tab’ After creating a PrivateEye account the user(s) will receive all images shared to the group."
        
        return AddMemberDisplayingInfoViewModel(title: title,
                                                descriptionText:description,
                                                contactViewModels: contactViewModels,
                                                shouldShowAdditionalText: true,
                                                additionalText: additionalText,
                                                minimumHeight: 260.0)
    }
}
