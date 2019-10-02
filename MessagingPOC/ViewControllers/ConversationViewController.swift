//
//  ConversationViewController.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/8/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit

final class ConversationViewController: UITableViewController {
    
    // MARK: - ViewModel
    
    private var viewModel: ConversationViewModelProtocol?
    
    // MARK: - Subviews
    
    private lazy var chatInputView: ConversationInputView = {
        let input = ConversationInputView.create()
        input.addTarget(self, action: #selector(chatInputEditingDidEnd), for: .editingDidEnd)
        return input
    }()
    
    // MARK: - UIViewController AccessoryView
    
    override var inputAccessoryView: UIView? {
        return chatInputView
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var canResignFirstResponder: Bool {
        return true
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
        tableView.allowsSelection = false
        
        becomeFirstResponder()
    }
    
    // MARK: - Bind ViewModel
    
    func bindViewModel(_ viewModel: ConversationViewModelProtocol) {
        self.viewModel = viewModel
        
        viewModel.subscribeToViewState { [weak self] viewState in
            self?.navigationItem.title = viewState.title
            self?.tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    
    @objc private func chatInputEditingDidEnd() {
        viewModel?.handleViewEvent(.sendMessage(chatInputView.text))
        chatInputView.clear()
    }
    
    // MARK: - UITableViewControllerDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.viewState?.messages.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // TODO: custom cell with config method
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        guard let message = viewModel?.viewState?.messages[safe: indexPath.row] else { return cell }
        cell.textLabel?.text = message.text
        cell.detailTextLabel?.text = "From: \(message.from)"
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewModel?.handleViewEvent(.messageViewed(indexPath))
    }
}
