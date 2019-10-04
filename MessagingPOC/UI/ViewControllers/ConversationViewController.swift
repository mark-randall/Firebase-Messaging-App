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
    
    // MARK: - DataSource
    
    enum Section: CaseIterable {
        case messages
    }
    
    private lazy var dataSource: UITableViewDiffableDataSource<Section, Message> = { [unowned self] in
        
        return EditableDiffableDataSource(
            tableView: tableView,
            cellProvider: { [weak self] tableView, indexPath, contact in
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
                guard let message = self?.viewModel?.viewState?.messages[safe: indexPath.row] else { return cell }
                cell.textLabel?.text = message.text
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.lineBreakMode = .byWordWrapping
                cell.detailTextLabel?.text = "From: \(message.from)"
                cell.detailTextLabel?.numberOfLines = 0
                cell.detailTextLabel?.lineBreakMode = .byWordWrapping
                return cell
            }
        )
    }()
    
    // MARK: - Subviews
    
    private lazy var chatInputView: ConversationInputView = {
        let input = ConversationInputView.create()
        input.addTarget(self, action: #selector(chatInputEditingDidEnd), for: .editingDidEnd)
        return input
    }()
    
    private lazy var contactsView: ConversationContactsView = {
        let contacts = ConversationContactsView.create()
        contacts.addTarget(self, action: #selector(contactEditingDidBegin), for: .editingDidBegin)
        return contacts
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
        tableView.tableHeaderView = contactsView
        dataSource.defaultRowAnimation = .fade

        becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        chatInputView.becomeFirstResponder()
    }
    
    // MARK: - Bind ViewModel
    
    func bindViewModel(_ viewModel: ConversationViewModelProtocol) {
        self.viewModel = viewModel
        
        viewModel.subscribeToViewState { [weak self] viewState in
            self?.contactsView.isEditable = viewState.contactsEditable
            self?.navigationItem.title = viewState.title
            var snapshot = NSDiffableDataSourceSnapshot<Section, Message>()
            snapshot.appendSections(Section.allCases)
            snapshot.appendItems(viewState.messages, toSection: Section.messages)
            let animate = self?.tableView.numberOfSections ?? 0 > 0
            self?.dataSource.apply(snapshot, animatingDifferences: animate)
        }
    }
    
    // MARK: - Actions
    
    @objc private func chatInputEditingDidEnd() {
        viewModel?.handleViewEvent(.sendMessage(chatInputView.text))
        chatInputView.clear()
    }
    
    @objc private func contactEditingDidBegin() {
        viewModel?.handleViewEvent(.addContactTapped)
    }
}

// MARK: - UITableViewDelegate

extension ConversationViewController {

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewModel?.handleViewEvent(.messageViewed(indexPath))
    }
}
