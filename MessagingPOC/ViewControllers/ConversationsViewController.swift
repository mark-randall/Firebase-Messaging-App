//
//  ViewController.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/8/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit

final class ConversationsViewController: UITableViewController {

    // MARK: - ViewModel
    
    private var viewModel: ConversationsViewModelProtocol?
    
    // MARK: - Subviews
    
    private lazy var profileButtton: UIBarButtonItem? = { [weak self] in
        guard let self = self else { return nil }
        return UIBarButtonItem(title: "Profile", style: .plain, target: self, action: #selector(profileButtonTapped))
    }()
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure subviews
        tableView.tableFooterView = UIView()
        navigationItem.rightBarButtonItem = profileButtton
    }
    
    func bindViewModel(_ viewModel: ConversationsViewModelProtocol) {
        self.viewModel = viewModel
        
        viewModel.subscribeToViewState { [weak self] viewState in
            self?.navigationItem.title = viewState.title
            self?.tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func profileButtonTapped() {
        viewModel?.handleViewEvent(.profileButtonTapped)
    }
    
    // MARK: - UITableViewControllerDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.viewState?.conversations.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // TODO: custom cell with config method
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        guard let conversation = viewModel?.viewState?.conversations[safe: indexPath.row] else { return cell }
        cell.textLabel?.text = conversation.text
        cell.detailTextLabel?.text = "@: \(conversation.lastMessageSend)"
        
        if conversation.hasUnreadMessages {
            cell.backgroundColor = .yellow
        } else {
            cell.backgroundColor = .white
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.handleViewEvent(.conversationSelected(indexPath))
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            viewModel?.handleViewEvent(.conversationDeleted(indexPath))
        }
    }
}
