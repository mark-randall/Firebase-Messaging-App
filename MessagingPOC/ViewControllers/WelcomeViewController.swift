//
//  WelcomeViewController.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/13/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit

final class WelcomeViewController: UIViewController, RootCoordinatorController {
    
    // MARK: - CoordinatorController
    
    var currentFlow: MessagingApplicationFlow?
    weak var rootCoordinatorActionHandler: ActionHandler<MessagingApplicationFlow, RootAction>?
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        becomeFirstResponder()
    }
    
    // MARK: - Actions
    
    @IBAction private func signInButtonTapped() {
        try? rootCoordinatorActionHandler?.perform(.presentSignIn)
    }
}
