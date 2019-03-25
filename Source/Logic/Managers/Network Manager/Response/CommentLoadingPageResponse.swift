//
//  CommentLoadingPageResponse.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 10/18/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

struct CommentLoadingPageResponse {
    var limit: Int
    var comments: [Comment]
    var canDeleteComments: Bool
}
