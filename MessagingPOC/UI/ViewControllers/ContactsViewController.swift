//
//  ContactsViewController.swift
//  MessagingPOC
//
//  Created by Mark Randall on 10/2/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit

final class ContactsViewController: UITableViewController {

    // MARK: - ViewModel
    
    private var viewModel: ContactsViewModelProtocol?
    
    
    // MARK: - Bind ViewModel
    
    func bindViewModel(_ viewModel: ContactsViewModelProtocol) {
        self.viewModel = viewModel
        
        viewModel.subscribeToViewState { [weak self] viewState in
            self?.tableView.reloadData()
        }
    }
}
