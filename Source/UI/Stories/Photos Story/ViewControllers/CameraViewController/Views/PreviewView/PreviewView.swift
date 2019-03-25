//
//  PreviewView.swift
//  MyMobileED
//
//  Created by Vasyliev Konstantin on 2/6/18.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit

final class PreviewView: UIView {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var progressIndicatorView: UIView!
    var onSelectShowPreview: (() -> Void)? {
        didSet {
            guard let viewFromNib = self.subviews.first as? PreviewView else { return }
            viewFromNib.onSelectShowPreview = onSelectShowPreview
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 2.0
        self.layer.cornerRadius = 3.0
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        if self.subviews.isEmpty {
            let viewFromNib = PreviewView.fromNib() as PreviewView
            self.imageView = viewFromNib.imageView
            self.progressIndicatorView = viewFromNib.progressIndicatorView
            viewFromNib.translatesAutoresizingMaskIntoConstraints = false
            addSubview(viewFromNib)
            self.pinAllEdges(viewFromNib, edges: .zero)
        }
    }

    func setupImage(_ image: UIImage?) {
        imageView.image = image
        self.isHidden = false
        self.showProgressIndicator()
    }

    func showProgressIndicator() {
        progressIndicatorView.isHidden = false
    }

    func hideProgressIndicator() {
        progressIndicatorView.isHidden = true
    }
    
    @IBAction private func didTapPreview(_ sender: UIButton) {
        if progressIndicatorView.isHidden {
            onSelectShowPreview?()
        }
    }
}
