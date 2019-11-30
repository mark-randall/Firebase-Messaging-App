//
//  SelectContactsView.swift
//  MessagingPOC
//
//  Created by Mark Randall on 10/2/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit

final class ConversationContactsView: UIControl {

    static func create() -> ConversationContactsView {
        return UIView.create(fromNib: "ConversationContactsView")!
    }
    
    // MARK: - Internal properties
    
    var isEditable: Bool = false {
        didSet {
            addContactButton.isHidden = !isEditable
        }
    }
    
    // MARK: - Subviews
    
    @IBOutlet private weak var toLabel: UILabel! {
        didSet {
            toLabel.textColor = UIColor.lightGray
        }
    }
    
    @IBOutlet private weak var contactsLabel: UILabel! {
        didSet {
            contactsLabel.textColor = UIColor.lightGray
        }
    }
    
    @IBOutlet private weak var addContactButton: UIButton! {
        didSet {
            addContactButton.addTarget(self, action: #selector(addContactButtonTappped), for: .touchUpInside)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width, height: max(contactsLabel.intrinsicContentSize.height,addContactButton.intrinsicContentSize.height))
    }
    
    // MARK: - Actions
    
    @objc private func addContactButtonTappped() {
        sendActions(for: .editingDidBegin)
    }
}
