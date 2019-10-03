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

// MARK: - ViewState

struct ContactsViewState: Equatable {
    var messages: [Contact]
}

// MARK: - ViewEffect

enum ContactsViewEffect {
}

// MARK: - ViewEvent

enum ContactsViewEvent {
}

typealias ContactsViewModelProtocol = ViewModel<ContactsViewState, ContactsViewEffect, ContactsViewEvent>

final class ContactsViewModel: ContactsViewModelProtocol, ConversationsCoordinatorController {
    
    // MARK: - CoordinatorController
    
    var currentFlow: MessagingApplicationFlow?
    weak var conversationsCoordinatorActionHandler: ActionHandler<MessagingApplicationFlow, ConversationAction>?
    
    // MARK: - Dependencies

    private let firestore: Firestore
    private let log = OSLog(subsystem: "com.messaging", category: "contacts")
    
    // MARK: - Init
    
    init(firestore: Firestore) {
        self.firestore = firestore
    }
}
