//
//  WelcomeViewController.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/13/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit

final class WelcomeViewController: UIViewController, Controller {
    
    weak var coordinatorActionHandler: ActionHandler<MessagingApplicationFlow, RootAction>?
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // MARK: - Actions
    
    @IBAction private func signInButtonTapped() {
        coordinatorActionHandler?.perform(RootAction.signIn)
    }
}
