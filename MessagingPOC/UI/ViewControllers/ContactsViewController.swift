//
//  ContactsViewController.swift
//  MessagingPOC
//
//  Created by Mark Randall on 10/2/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit
import Combine

final class ContactsViewController: UITableViewController {

    // MARK: - ViewModel
    
    private var viewModel: ContactsViewModelProtocol?
    
    // MARK: - DataSource
    
    enum Section: CaseIterable {
        case contacts
    }
    
    private lazy var dataSource: UITableViewDiffableDataSource<Section, Contact> = { [unowned self] in
        
        return EditableDiffableDataSource(
            tableView: tableView,
            cellProvider: { [weak self] tableView, indexPath, contact in
                
                // TODO: custom cell with config method
                let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
                cell.textLabel?.text = contact.name
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.lineBreakMode = .byWordWrapping
                cell.detailTextLabel?.text = contact.name
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
    
    func bindViewModel(_ viewModel: ContactsViewModelProtocol) {
        self.viewModel = viewModel
        
        subscriptions.append(viewModel.viewState.sink(receiveValue: { [weak self] viewState in
            guard let viewState = viewState else { return }
            
            var snapshot = NSDiffableDataSourceSnapshot<Section, Contact>()
            snapshot.appendSections(Section.allCases)
            snapshot.appendItems(viewState.contacts, toSection: Section.contacts)
            let animate = self?.tableView.numberOfSections ?? 0 > 0
            self?.dataSource.apply(snapshot, animatingDifferences: animate)
        }))
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.handleViewEvent(.contactSelected(indexPath))
    }
}
