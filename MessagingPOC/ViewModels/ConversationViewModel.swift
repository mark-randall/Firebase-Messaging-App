//
//  ConversationViewModel.swift
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

struct ConversationViewState: Equatable {
    let title = "Conversation"
    var messages: [Message]
}

// MARK: - ViewEffect

enum ConversationViewEffect {
}

// MARK: - ViewEvent

enum ConversationViewEvent {
    case messageViewed(IndexPath)
}

// MARK: - ViewModel

typealias ConversationViewModelProtocol = ViewModel<ConversationViewState, ConversationViewEffect, ConversationViewEvent>

final class ConversationViewModel: ConversationViewModelProtocol, ConversationsCoordinatorController {
    
    // MARK: - CoordinatorController
    
    var currentFlow: MessagingApplicationFlow?
    weak var conversationsCoordinatorActionHandler: ActionHandler<MessagingApplicationFlow, ConversationAction>?
    
    // MARK: - Dependencies
    
    private let firestore: Firestore
    private let log = OSLog(subsystem: "com.messaging", category: "conversations")
    
    // MARK: - State
    private var userId: String
    private var conversationSubscription: ListenerRegistration?
    
    // MARK: - Init
    
    init(firestore: Firestore, userId: String, conversationId: String) {
        self.firestore = firestore
        self.userId = userId
        super.init()
        
        conversationSubscription = firestore
            .collection("/users/\(userId)/messages")
            .whereField("conversation_id", isEqualTo: conversationId)
            .whereField("is_blocked", isEqualTo: false)
            .whereField("is_deleted", isEqualTo: false)
            .order(by: "time", descending: true)
            .addSnapshotListener { [weak self] documentSnapshot, error in
                
                guard let self = self else { return }
                
                if let error = error {
                    os_log("error fetching conversation messages", log: self.log, type: .error)
                    Crashlytics.sharedInstance().recordError(error)
                    //TODO: Handle error
                } else if let documentSnapshot = documentSnapshot{
                    let messages = documentSnapshot.documents.compactMap { Message(snapshot: $0) }
                    self.updateViewState(ConversationViewState(messages: messages))
                }
            }
    }
    
    deinit {
        conversationSubscription?.remove()
        conversationSubscription = nil
    }
    
    // MARK: - Handle ViewEvent
    
    override func handleViewEvent(_ event: ConversationViewEvent) {
        
        switch event {
            
        case .messageViewed(let indexPath):
            
            guard let message = viewState?.messages[safe: indexPath.row] else { return }
            
            firestore.collection("users/\(userId)/messages").document(message.id).updateData(["is_read": true]) { [weak self] error in
                
                guard let self = self else { return }
                
                if let error = error {
                    os_log("error marking message as read", log: self.log, type: .error)
                    Crashlytics.sharedInstance().recordError(error)
                } else {
                    os_log("message marked as read", log: self.log, type: .info)
                }
            }
        }
    }
}
