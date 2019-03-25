//
//  UIImage+Rotations.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 8/21/17.
//  Copyright © 2017 Company. All rights reserved.
//

import Foundation

extension UIImage {
    func rotatedImage(byDegrees degrees: CGFloat) -> UIImage {
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let affineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
        rotatedViewBox.transform = affineTransform
        
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        UIGraphicsBeginImageContext(rotatedSize)
        
        if let bitmap = UIGraphicsGetCurrentContext() {
            bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
            bitmap.rotate(by: (degrees * CGFloat.pi / 180))
            bitmap.scaleBy(x: 1.0, y: -1.0)
            bitmap.draw(cgImage!, in: CGRect(x: -size.width / 2,
                                                      y: -size.height / 2,
                                                      width: size.width,
                                                      height: size.height))
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
