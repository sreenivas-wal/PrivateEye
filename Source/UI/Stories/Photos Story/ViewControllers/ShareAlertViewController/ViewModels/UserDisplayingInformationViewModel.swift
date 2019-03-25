//
//  UserDisplayingInformationViewModel.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 1/23/18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation

struct UserDisplayingInformationViewModel {

    var title: String
    var descriptionText: String

    // MARK: - SharingViewModels
    
    static func shareToInstitutionViewModel() -> UserDisplayingInformationViewModel {
        let text = "Share to User in My Insitution"
        let descriptionText = ""
        
        return UserDisplayingInformationViewModel(title: text, descriptionText: descriptionText)
    }
    
    static func shareToDoximityViewModel() -> UserDisplayingInformationViewModel {
        let text = "Share to User in My Doximity Network"
        let descriptionText = "If a selected user does not have a Doximity account you can invite them via SMS or email."
        
        return UserDisplayingInformationViewModel(title: text, descriptionText: descriptionText)
    }
    
    static func shareByEmailsViewModel() -> UserDisplayingInformationViewModel {
        let text = "Share by Email"
        let descriptionText = "Be sure to use the email associated with the recepient’s Doximity or PrivateEye account. Otherwise, they cannot access the photo."
        
        return UserDisplayingInformationViewModel(title: text, descriptionText: descriptionText)
    }
    
    static func shareBySMSViewModel() -> UserDisplayingInformationViewModel {
        let text = "Share by SMS"
        let descriptionText = "Be sure to use the SMS associated with the recipient's Doximity or PrivateEyeHC account. Otherwise, they cannot access the photo."
        
        return UserDisplayingInformationViewModel(title: text, descriptionText: descriptionText)
    }

    // MARK: - AddMembersViewModels
    
    static func addMemberByEmailsViewModel() -> UserDisplayingInformationViewModel {
        let text = "Add Members by Email"
        let descriptionText = "Be sure to use the email associated with the recepient’s Doximity or PrivateEye account. Otherwise, they cannot access the photo."
        
        return UserDisplayingInformationViewModel(title: text, descriptionText: descriptionText)
    }
    
    static func addMemberBySMSViewModel() -> UserDisplayingInformationViewModel {
        let text = "Add Members by SMS"
        let descriptionText = "Be sure to use the email associated with the recepient’s Doximity or PrivateEye account. Otherwise, they cannot access the photo."
        
        return UserDisplayingInformationViewModel(title: text, descriptionText: descriptionText)
    }
    
    static func inviteMembersByEmailsViewModel() -> UserDisplayingInformationViewModel {
        let text = "Invite users by email"
        let descriptionText = "Enter Email ID below"
        
        return UserDisplayingInformationViewModel(title: text, descriptionText: descriptionText)
    }
    
    static func inviteMemberBySMSViewModel() -> UserDisplayingInformationViewModel {
        let text = "Invite by Number"
        let descriptionText = "Enter Mobile Number below"
        
        return UserDisplayingInformationViewModel(title: text, descriptionText: descriptionText)
    }
}
