//
//  ProfileViewController.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/18/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit
import Combine

final class ProfileViewController: UIViewController {
    
    // MARK: - ViewModel
    
    private var viewModel: ProfileViewModelProtocol?
    
    // MARK: - Subviews
    
    @IBOutlet private weak var startChattingButton: UIButton?
    
    private lazy var closeButton: UIBarButtonItem? = { [weak self] in
        guard let self = self else { return nil }
        return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeButtonTapped))
    }()
    
    // MARK: - Combine
    
    private var subscriptions: [Cancellable] = []
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Bind ViewModel
    
    func bindViewModel(_ viewModel: ProfileViewModelProtocol) {
        self.viewModel = viewModel
        
        subscriptions.append(viewModel.viewState.sink(receiveValue: { [weak self] viewState in
            guard let viewState = viewState else { return }
            
            if viewState.showCloseButton {
                self?.navigationItem.rightBarButtonItem = self?.closeButton
            } else {
                self?.navigationItem.rightBarButtonItem = nil
            }
            
            self?.startChattingButton?.isHidden = !viewState.showStartChattingButton
        }))
    }

    
    // MARK: - Actions
    
    @IBAction private func logoutButtonTapped() {
        viewModel?.handleViewEvent(.loggoutButtonTapped)
    }
    
    @objc private func closeButtonTapped() {
        viewModel?.handleViewEvent(.closeButtonTapped)
    }
    
    @IBAction private func startChattingButtonTapped() {
        viewModel?.handleViewEvent(.startChattingButtonTapped)
    }
}
