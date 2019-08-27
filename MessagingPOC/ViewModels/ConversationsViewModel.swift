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

struct ConversationsViewState: Equatable {
    let title = "Conversations"
    var conversations: [Conversation]
}

// MARK: - ViewEffect

enum ConversationsViewEffect {
}

// MARK: - ViewEvent

enum ConversationsViewEvent {
    case conversationSelected(IndexPath)
    case conversationDeleted(IndexPath)
    case profileButtonTapped
}

// MARK: - ViewModel

typealias ConversationsViewModelProtocol = ViewModel<ConversationsViewState, ConversationsViewEffect, ConversationsViewEvent>

final class ConversationsViewModel: ConversationsViewModelProtocol, ConversationsCoordinatorController {

    // MARK: - CoordinatorController
    
    var currentFlow: MessagingApplicationFlow?
    weak var conversationsCoordinatorActionHandler: ActionHandler<MessagingApplicationFlow, ConversationAction>?
    
    // MARK: - Dependencies

    private let firestore: Firestore
    private let log = OSLog(subsystem: "com.messaging", category: "conversations")
    
    // MARK: - State
    
    private var conversations: [Conversation] = []
    
    // TODO: user real id
    private let userId: String = "123"
    private var conversationsSubscription: ListenerRegistration?
    
    // MARK: - Init
    
    init(firestore: Firestore) {
        self.firestore = firestore
        super.init()
        
        Crashlytics.sharedInstance().setUserIdentifier(userId)
        
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
        
        switch event {
            
        case .conversationDeleted(let indexPath):
            
            guard let conversation = conversations[safe: indexPath.row] else { return }
            
            firestore.collection("users/\(userId)/conversations").document(conversation.id).updateData(["is_deleted": true]) { [weak self] error in
                
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
            try? conversationsCoordinatorActionHandler?.perform(.showConversation(id: conversation.id))
            
        case .profileButtonTapped:
            try? conversationsCoordinatorActionHandler?.perform(.presentProfile)
        }
    }
}
