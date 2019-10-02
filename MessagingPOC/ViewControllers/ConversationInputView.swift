//
//  ConversationInputView.swift
//  MessagingPOC
//
//  Created by Mark Randall on 9/18/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit

final class ConversationInputView: UIControl {

    static func create() -> ConversationInputView {
        return UIView.create(fromNib: "ConversationInputView")!
    }
    
    var text: String {
        return textView.text
    }
    
    // MARK: - Subviews
    
    @IBOutlet private weak var placeHolderLabel: UILabel! {
        didSet {
            placeHolderLabel.textColor = UIColor.lightGray
        }
    }
    
    @IBOutlet private weak var textView: UITextView! {
        didSet {
            textView.textColor = UIColor.darkText
            textView.font = UIFont.preferredFont(forTextStyle: .body)
            textView.isScrollEnabled = false
            textView.isEditable = true
            textView.textContainerInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
            textView.textContainer.lineFragmentPadding = 0.0
            textView.layer.borderColor = UIColor.lightGray.cgColor
            textView.layer.borderWidth = 1
            textView.layer.cornerRadius = 22
            textView.delegate = self
            
        }
    }
    
    @IBOutlet private weak var submitButton: UIButton! {
        didSet {
            submitButton.setTitle("Send", for: .normal)
            submitButton.setTitleColor(tintColor, for: .normal)
            submitButton.addTarget(self, action: #selector(submitButtonTappped), for: .touchUpInside)
            submitButton.isEnabled = false
        }
    }
    
    // MARK: - InitA
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width, height: textView.intrinsicContentSize.height)
    }
    
    override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }
    
    // MARK: - Actions
    
    func set(text: String) {
        textView.text = text
        textViewDidChange(textView)
    }
    
    func clear() {
        set(text: "")
    }
    
    @objc private func submitButtonTappped() {
        sendActions(for: .editingDidEnd)
    }
}

// MARK: - UITextViewDelegate

extension ConversationInputView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeHolderLabel.isHidden = !textView.text.isEmpty
        submitButton.isEnabled = !textView.text.isEmpty
        invalidateIntrinsicContentSize()
    }
}
