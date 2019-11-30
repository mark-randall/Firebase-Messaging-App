//
//  ViewController.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/8/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit
import Combine

final class ConversationsViewController: UITableViewController {

    // MARK: - ViewModel
    
    private var viewModel: ConversationsViewModelProtocol?
    
    // MARK: - Datasource
    
    enum Section: CaseIterable {
        case conversations
    }
    
    private lazy var dataSource: UITableViewDiffableDataSource<Section, ConversationData> = { [unowned self] in
        
        return EditableDiffableDataSource(
            tableView: tableView,
            cellProvider: { [weak self] tableView, indexPath, conversation in
                
                // TODO: custom cell with config method
                let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
                cell.textLabel?.text = conversation.text
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.lineBreakMode = .byWordWrapping
                cell.detailTextLabel?.text = "@: \(conversation.lastMessageSend)"
                cell.detailTextLabel?.numberOfLines = 0
                cell.detailTextLabel?.lineBreakMode = .byWordWrapping
                return cell
            }
        )
    }()
    
    // MARK: - Combine
    
    private var subscriptions: [Cancellable] = []
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure subviews
        tableView.tableFooterView = UIView()
        dataSource.defaultRowAnimation = .fade
    }
    
    // MARK: - Bind ViewModel
    
    func bindViewModel(_ viewModel: ConversationsViewModelProtocol) {
        self.viewModel = viewModel
        
        subscriptions.append(viewModel.viewState.sink(receiveValue: { [weak self] viewState in
            guard let viewState = viewState else { return }
            
            self?.navigationItem.title = viewState.title
            var snapshot = NSDiffableDataSourceSnapshot<Section, ConversationData>()
            snapshot.appendSections(Section.allCases)
            snapshot.appendItems(viewState.conversations, toSection: Section.conversations)
            let animate = self?.tableView.numberOfSections ?? 0 > 0
            self?.dataSource.apply(snapshot, animatingDifferences: animate)
        }))
    }
    
    // MARK: - Actions
    
    @IBAction private func profileButtonTapped() {
        viewModel?.handleViewEvent(.profileButtonTapped)
    }
    
    @IBAction private func addButtonTapped() {
        viewModel?.handleViewEvent(.addButtonTapped)
    }
}

// MARK: - UITableViewDelegate
    
extension ConversationsViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.handleViewEvent(.conversationSelected(indexPath))
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completed in
            self?.viewModel?.handleViewEvent(.conversationDeleted(indexPath))
            completed(true)
        }
        action.backgroundColor = .systemRed
        let config = UISwipeActionsConfiguration(actions: [action])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
}
