//
//  WelcomeViewController.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/13/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit

final class WelcomeViewController: UIViewController {
    
    // MARK: - ViewModel
        
    private var viewModel: WelcomeViewModelProtocol?
   
    // MARK: - Bind ViewModel
    
    func bindViewModel(_ viewModel: WelcomeViewModelProtocol) {
        self.viewModel = viewModel
    }
    
    // MARK: - Actions
    
    @IBAction private func signInButtonTapped() {
        viewModel?.handleViewEvent(.signInButtonTapped)
    }
}
