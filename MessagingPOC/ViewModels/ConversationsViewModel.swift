//
//  ConversationsViewModel.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/26/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation
import FirebaseFirestore
import os.log
import Crashlytics

// MARK: - ViewState

struct ConversationsViewState: ViewState {
    let title = "Conversations"
    var conversations: [Conversation]
}

// MARK: - ViewEffect

enum ConversationsViewEffect: ViewEffect {
}

// MARK: - ViewEvent

enum ConversationsViewEvent: ViewEvent {
    case conversationSelected(IndexPath)
    case conversationDeleted(IndexPath)
    case profileButtonTapped
    case addButtonTapped
}

// MARK: - ViewModel

typealias ConversationsViewModelProtocol = ViewModel<MessagingApplicationFlow, ConversationsViewState, ConversationsViewEffect, ConversationsViewEvent>

final class ConversationsViewModel: ConversationsViewModelProtocol, ConversationsCoordinatorController {

    // MARK: - CoordinatorController
    
    weak var conversationsCoordinatorActionHandler: ActionHandler<MessagingApplicationFlow, ConversationAction>?
    
    // MARK: - Dependencies

    private let firestore: Firestore
    private let log = OSLog(subsystem: "com.messaging", category: "conversations")
    
    // MARK: - State
    
    private var conversations: [Conversation] = []
    
    // TODO: user real id
    private let userId: String
    private var conversationsSubscription: ListenerRegistration?
    
    // MARK: - Init
    
    init(flow: MessagingApplicationFlow, firestore: Firestore, userId: String) {
        self.firestore = firestore
        self.userId = userId
        super.init(flow: flow)
        
        Crashlytics.sharedInstance().setUserIdentifier(userId) // TODO: should this be here
        os_log("show converations for %@", log: self.log, type: .info, userId)
        
        // Fetch data
        conversationsSubscription = firestore
            .collection("/users/\(userId)/conversations")
            .whereField("is_blocked", isEqualTo: false)
            .whereField("is_deleted", isEqualTo: false)
            .order(by: "time", descending: true)
            .addSnapshotListener { [weak self] documentSnapshot, error in
                
                guard let self = self else { return }
                
                if let error = error {
                    os_log("error fetching conversations", log: self.log, type: .error)
                    Crashlytics.sharedInstance().recordError(error)
                    // TODO: Handle error
                } else if let documentSnapshot = documentSnapshot{
                    
                    self.conversations = documentSnapshot.documents.compactMap {
                        Conversation(snapshot: $0)
                    }
            
                    self.updateViewState(ConversationsViewState(conversations: self.conversations))
                }
            }
    }
    
    deinit {
        conversationsSubscription?.remove()
        conversationsSubscription = nil
    }
    
    // MARK: - Handle ViewEvent
    
    override func handleViewEvent(_ event: ConversationsViewEvent) {
        super.handleViewEvent(event)
        
        switch event {
            
        case .conversationDeleted(let indexPath):
            
            guard let conversation = conversations[safe: indexPath.row] else { return }
            
            firestore
                .collection("users/\(userId)/conversations")
                .document(conversation.id)
                .updateData(["is_deleted": true]) { [weak self] error in
                
                    guard let self = self else { return }
                    
                    if let error = error {
                        os_log("error deleting conversation", log: self.log, type: .error)
                        Crashlytics.sharedInstance().recordError(error)
                    } else {
                        os_log("deleted conversation", log: self.log, type: .info)
                    }
                }
            
        case .conversationSelected(let indexPath):
            guard let conversation = conversations[safe: indexPath.row] else { return }
            try? conversationsCoordinatorActionHandler?.perform(.showConversation(conversationId: conversation.id))
            
        case .profileButtonTapped:
            try? conversationsCoordinatorActionHandler?.perform(.presentProfile)
            
        case .addButtonTapped:
            try? conversationsCoordinatorActionHandler?.perform(.presentAddConversation)
        }
    }
}
