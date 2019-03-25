//
//  EnterNoteView.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 8/7/17.
//  Copyright © 2017 Company. All rights reserved.
//

import Foundation
import KMPlaceholderTextView

protocol EnterNoteViewDelegate: class {
    func enterNoteViewTextDidChange(_ sender: EnterNoteView)
}

class EnterNoteView : PopUpView, UITextViewDelegate {
    
    let maxViewHeight: CGFloat = 310
    
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var textView: KMPlaceholderTextView!
    
    var backButtonTapCallback: (() -> Void)?
    var continueButtonTapCallback: ((_ photoNote: String) -> (Void))?
    var viewCommentsButtonTapCallback: (() -> (Void))?
    weak var delegate: EnterNoteViewDelegate?
    
    class func viewHeight() -> CGFloat {
        return 230.0
    }
    
    override func height() -> CGFloat {
        let height = EnterNoteView.viewHeight() + noteHeight()
        
        if height > maxViewHeight {
            textView.isScrollEnabled = true
            
            return maxViewHeight
        } else {
            textView.isScrollEnabled = false
            
            return height
        }
    }
    
    override func xibSetup() {
        super.xibSetup()
        
        textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
        textView.textContainer.lineFragmentPadding = 0
        self.configureTextView()
    }
    
    override func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "EnterNoteView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }

    func noteHeight() -> CGFloat {
        let sizeThatFitsTextView = textView.sizeThatFits(CGSize(width: textView.frame.size.width,
                                                                height: CGFloat.greatestFiniteMagnitude))
        
        return sizeThatFitsTextView.height
    }
    
    // MARK: - Configure
    
    func configure(with noteText: String?, title: String?) {
        
        self.titleLabel.text = title
        
        guard let requriedNoteText = noteText else {
            self.textView.attributedText = nil
            self.textView.text = nil
            return
        }
        
        let attributedString = self.atrributedLinkString(with: requriedNoteText)
        self.textView.attributedText = attributedString
    }

    // MARK: - Actions
    
    @IBAction func backButtonTapped(_ sender: Any) {
        textView.resignFirstResponder()
        
        if let validBackCallback = backButtonTapCallback {
            validBackCallback()
        }
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        textView.resignFirstResponder()
        
        if let validContinueCallback = continueButtonTapCallback {
            validContinueCallback(textView.text!)
        }
    }
    
    @IBAction func viewCommentsButtonTapped(_ sender: Any) {
        viewCommentsButtonTapCallback?()
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.enterNoteViewTextDidChange(self)
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
        return true
    }
    
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {

        self.textView.isEditable = false
    }
    
    // MARK: - Private
    
    fileprivate func configureTextView() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EnterNoteView.handleTextViewTap(_:)))
        self.textView.isEditable = false
        self.textView.isSelectable = true
        self.textView.dataDetectorTypes = .link
        self.textView.addGestureRecognizer(tapGesture)
    }
    
    @objc fileprivate func handleTextViewTap(_ sender: UITapGestureRecognizer) {
        
        self.textView.isEditable = true
        self.textView.becomeFirstResponder()
    }
}
