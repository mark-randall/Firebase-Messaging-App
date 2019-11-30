//
//  ContactsViewModel.swift
//  MessagingPOC
//
//  Created by Mark Randall on 10/2/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation
import FirebaseFirestore
import os.log
import Crashlytics
import Combine

// MARK: - ViewState

struct ContactsViewState: ViewState {
    var contacts: [Contact]
}

// MARK: - ViewEffect

enum ContactsViewEffect: ViewEffect {
}

// MARK: - ViewEvent

enum ContactsViewEvent: ViewEvent {
    case contactSelected(IndexPath)
}

// MARK: - ViewModel

typealias ContactsViewModelProtocol = ViewModel<MessagingApplicationFlow, ContactsViewState, ContactsViewEffect, ContactsViewEvent, EmptyCoordinatorEvent>

final class ContactsViewModel: ContactsViewModelProtocol, ConversationsCoordinatorController {
    
    // MARK: - CoordinatorController
    
    weak var conversationsCoordinatorActionHandler: ActionHandler<MessagingApplicationFlow, ConversationAction>?
    
    // MARK: - Dependencies

    private let firestore: Firestore
    private let log = OSLog(subsystem: "com.messaging", category: "contacts")
    
    // MARK: - Init
    
    init(flow: MessagingApplicationFlow, firestore: Firestore) {
        self.firestore = firestore
        super.init(flow: flow)
        
        updateViewState(ContactsViewState(contacts: [Contact(id: "123", name: "Beans")]))
    }
    
    override func handleViewEvent(_ event: ContactsViewEvent) {
        
        switch event {
        case .contactSelected(let indexPath):
            guard let contact = viewState?.contacts[safe: indexPath.row] else { assertionFailure(); return }
            try? conversationsCoordinatorActionHandler?.perform(.contactAdded(contact: contact))
        }
    }
}
