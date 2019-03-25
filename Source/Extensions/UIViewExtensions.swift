//
//  UIViewExtensions.swift
//  MyMobileED
//
//  Created by Admin on 2/6/18.
//

import UIKit

extension UIView {

    class func fromNib<T: UIView>() -> T {
        guard let view = Bundle(for: self).loadNibNamed(String(describing: self), owner: nil, options: nil)?.first as? T else {
            fatalError("Unexpected error occured when try to get nib named \(String(describing: type(of: self)))")
        }

        return view
    }
}

extension UIView {

    func pinAllEdges(_ subView: UIView, edges: UIEdgeInsets) {
        pin(subView, edge: .bottom, constant: edges.bottom)
        pin(subView, edge: .top, constant: edges.top)
        pin(subView, edge: .left, constant: edges.left)
        pin(subView, edge: .right, constant: edges.right)
    }

    private func pin(_ subView: UIView, edge: NSLayoutAttribute, constant: CGFloat) {
        addConstraint(NSLayoutConstraint(item: self,
                                         attribute: edge,
                                         relatedBy: .equal,
                                         toItem: subView,
                                         attribute: edge,
                                         multiplier: 1.0,
                                         constant: constant))
    }
}
