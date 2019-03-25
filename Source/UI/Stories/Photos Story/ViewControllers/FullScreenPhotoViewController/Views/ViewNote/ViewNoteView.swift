//
//  ViewNoteView.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 8/16/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

class ViewNoteView: PopUpView, UITextViewDelegate {
    
    private let maxViewHeight: CGFloat = 300
    
    var closeButtonTapCallback: (() -> Void)?
    var viewCommentsTapCallback: (() -> (Void))?
    
    @IBOutlet fileprivate weak var noteTextView: UITextView!
    
    class func viewHeight() -> CGFloat {
        return 220.0
    }
    
    override func height() -> CGFloat {
        let height = ViewNoteView.viewHeight() + noteHeight()
        
        if height > maxViewHeight {
            noteTextView.isScrollEnabled = true
            
            return maxViewHeight
        } else {
            noteTextView.isScrollEnabled = false
            
            return height
        }
    }
    
    override func xibSetup() {
        super.xibSetup()
        
        noteTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
        noteTextView.textContainer.lineFragmentPadding = 0
    }
    
    override func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ViewNoteView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    func noteHeight() -> CGFloat {
        let sizeThatFitsTextView = noteTextView.sizeThatFits(CGSize(width: noteTextView.frame.size.width,
                                                                    height: CGFloat.greatestFiniteMagnitude))

        return sizeThatFitsTextView.height
    }
    
    // MARK: - Actions
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        if let validCloseCallback = closeButtonTapCallback {
            validCloseCallback()
        }
    }
    
    @IBAction func viewCommentsButtonTapped(_ sender: Any) {
        viewCommentsTapCallback?()
    }
    
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
        return true
    }
    
    func configure(with noteText: String?) {
        
        guard let requriedNoteText = noteText else {
            self.noteTextView.attributedText = nil
            self.noteTextView.text = nil
            return
        }
        
        let attributedString = self.atrributedLinkString(with: requriedNoteText)
        self.noteTextView.attributedText = attributedString
    }
}
