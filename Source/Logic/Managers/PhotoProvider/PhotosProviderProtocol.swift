//
//  PhotoProviderProtocol.swift
//  MyMobileED
//
//  Created by Admin on 2/8/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

protocol PhotosProviderProtocol: class {
    func retrieveImage(byNodeID nodeID: String,
                       successBlock: @escaping (_ image: UIImage) -> (),
                       failureBlock: @escaping ((_ message: String) -> ())) -> NetworkRequest?
    
    func retrievePreviewPhoto(byUrl url: URL,
                              successBlock: @escaping (_ image: UIImage) -> (),
                              failureBlock: @escaping ((_ message: String) -> ())) -> NetworkRequest?
    
    func replaceImage(_ image: UIImage, withNodeID nodeID: String)
    func deleteOldPhotos()
    func removeImage(withNodeID nodeID: String)
}
