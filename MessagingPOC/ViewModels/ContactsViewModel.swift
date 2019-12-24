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

struct ContactData: Equatable, Hashable {
    
    let id: String
    let name: String
    
    init(contact: Contact) {
        self.id = contact.id
        self.name = contact.name
    }
}

struct ContactsViewState: ViewState {
    var contacts: [ContactData]
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

    private let serviceLocator: ServiceLocator
    private let log = OSLog(subsystem: "com.messaging", category: "contacts")
    
    // MARK: - State
    
    private var contacts: [Contact] = []
    
    private var cancellable: AnyCancellable?
    
    // MARK: - Init
    
    init(flow: MessagingApplicationFlow, serviceLocator: ServiceLocator, userId: String) {
        self.serviceLocator = serviceLocator
        super.init(flow: flow, loggingManager: serviceLocator.loggingManager)
        cancellable = serviceLocator.messagesRepository.fetchContacts(forUserId: userId).sink { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure: break
            case .success(let contacts):
                self.contacts = contacts
                let contactsData = contacts.map { ContactData(contact: $0) }
                self.viewStateSubject.send(ContactsViewState(contacts: contactsData))
            }
        }
    }
    
    override func handleViewEvent(_ event: ContactsViewEvent) {
        
        switch event {
        case .contactSelected(let indexPath):
            guard let contact = contacts[safe: indexPath.row] else { assertionFailure(); return }
            try? conversationsCoordinatorActionHandler?.perform(.contactSelected(contact: contact))
        }
    }
}
