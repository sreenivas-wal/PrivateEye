//
//  GroupMembersLoadingPageResponse.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 1/24/18.
//  Copyright © 2018 Company. All rights reserved.
//

struct GroupMembersLoadingPageResponse {
    var limit: Int
    var groupMembers: [GroupMember]
    var pendingMembers: [Recipient]
}
