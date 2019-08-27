//
//  ProfileViewController.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/18/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit

// TODO: left off how to properly coorindate this screen??
// What puts it in a UINavigationController
// How do a add barbuttons to navc
// Which coordinator does his?

final class ProfileViewController: UIViewController, ConversationsCoordinatorController, SignInCoordinatorController {
    
    // MARK: - CoordinatorController

    var currentFlow: MessagingApplicationFlow?
    weak var conversationsCoordinatorActionHandler: ActionHandler<MessagingApplicationFlow, ConversationAction>?
    weak var signInCoordinatorActionHandler: ActionHandler<MessagingApplicationFlow, SignInAction>?
    
    // MARK: - Subviews
    
    @IBOutlet private weak var startChattingButton: UIButton?
    
    private lazy var closeButton: UIBarButtonItem? = { [weak self] in
        guard let self = self else { return nil }
        return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeButtonTapped))
    }()
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure VC for currentFlow
        if let currentFlow = currentFlow {
            
            switch currentFlow {
            case .conversations:
                navigationItem.rightBarButtonItem = closeButton
                startChattingButton?.isHidden = true
            case .signIn:
                startChattingButton?.isHidden = false
            default: break
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func logoutButtonTapped() {
        
        if let currentFlow = currentFlow {
            
            switch currentFlow {
            case .conversations:
                try? conversationsCoordinatorActionHandler?.perform(.logout)
            case .signIn:
                try? signInCoordinatorActionHandler?.perform(.logout)
            default: break
            }
        }
    }
    
    @objc private func closeButtonTapped() {
        try? conversationsCoordinatorActionHandler?.perform(.dismissProfile)
    }
    
    @IBAction private func startChattingButtonTapped() {
        try? signInCoordinatorActionHandler?.perform(.showConversations)
    }
}
