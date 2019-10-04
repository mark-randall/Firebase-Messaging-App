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

struct ContactsViewState: ViewState {
    var messages: [Contact]
}

// MARK: - ViewEffect

enum ContactsViewEffect: ViewEffect {
}

// MARK: - ViewEvent

enum ContactsViewEvent: ViewEvent {
}

// MARK: - ViewModel

typealias ContactsViewModelProtocol = ViewModel<MessagingApplicationFlow, ContactsViewState, ContactsViewEffect, ContactsViewEvent>

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
    }
}
