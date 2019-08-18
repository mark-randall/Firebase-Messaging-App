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

final class ProfileViewController: UIViewController, CoordinatorController {
    
    // MARK: - CoordinatorController
    
    weak var coordinatorActionHandler: ActionHandler<MessagingApplicationFlow, ConversationAction>?

    // MARK: - Subviews
    
    private lazy var closeButton: UIBarButtonItem? = { [weak self] in
        guard let self = self else { return nil }
        return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeButtonTapped))
    }()
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = closeButton
    }
    
    // MARK: - Actions
    
    @IBAction private func logoutButtonTapped() {
        
        // TODO: what if VC is used by multiple flows?
        try? coordinatorActionHandler?.perform(.logout)
    }
    
    @objc private func closeButtonTapped() {
        try? coordinatorActionHandler?.perform(.dismissProfile)
    }
}
