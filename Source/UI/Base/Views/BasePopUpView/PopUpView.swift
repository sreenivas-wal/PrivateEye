//
//  PopUpView.swift
//  MyMobileED
//
//  Created by Admin on 1/20/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

class PopUpView: UIView {
    
    private let AnimationDuration = 0.2
    private var originalFrame: CGRect!
    
    var view: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.originalFrame = frame
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.originalFrame = frame
        xibSetup()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "PopUpView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    func height() -> CGFloat {
        return 0.0
    }
    
    func setupFrame(_ frame: CGRect) {
        self.frame = frame
        self.originalFrame = frame
    }
    
    func show(fromView view: UIView) {
        self.layer.removeAllAnimations()
        self.frame.origin.y = view.frame.maxY
        
        UIView.animate(withDuration: AnimationDuration, animations: {
            self.frame = self.originalFrame
        })
        
        view.addSubview(self)
    }
    
    func hideView(fromView view: UIView) {
        self.layer.removeAllAnimations()
        
        let endFrame = CGRect(x: 0,
                              y: view.bounds.size.height,
                              width: self.bounds.size.width,
                              height: self.bounds.size.height)
        UIView.animate(withDuration: AnimationDuration, animations: {
            self.frame = endFrame
        }, completion: { (finished: Bool) in
            if finished {
                self.removeFromSuperview()
            }
        })
    }
    
    internal func atrributedLinkString(with text: String) -> NSAttributedString {
        
        let mainFont = UIFont(name: "Avenir-Medium", size: 14.0) ?? .systemFont(ofSize: 14.0)
        let attributedString = NSMutableAttributedString(string: text)
        
        attributedString.addAttribute(NSFontAttributeName,
                                      value: mainFont,
                                      range: NSMakeRange(0, text.count))
        
        guard let requiredDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return  attributedString }

        let matches = requiredDetector.matches(in: text, options: [],
                                            range: NSRange(location: 0, length: text.utf16.count))
        
        let urlStrings = matches.flatMap { Range($0.range, in: text) }
                                .flatMap { text.substring(with: $0) }
        
        for urlStr in urlStrings {
            
            guard let requiredRange = text.range(of: urlStr) else { continue }
            attributedString.addAttribute(NSLinkAttributeName, value: urlStr, range: NSRange(requiredRange, in: text) )
        }
        
        return  attributedString
    }
}
