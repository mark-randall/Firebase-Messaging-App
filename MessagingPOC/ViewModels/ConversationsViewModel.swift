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
import Combine

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

typealias ConversationsViewModelProtocol = ViewModel<MessagingApplicationFlow, ConversationsViewState, ConversationsViewEffect, ConversationsViewEvent, EmptyCoordinatorEvent>

final class ConversationsViewModel: ConversationsViewModelProtocol, ConversationsCoordinatorController {

    // MARK: - CoordinatorController
    
    weak var conversationsCoordinatorActionHandler: ActionHandler<MessagingApplicationFlow, ConversationAction>?
    
    // MARK: - Dependencies

    private let messagesRepository: MessagesRepository
    private let log = OSLog(subsystem: "com.messaging", category: "conversations")
    
    // MARK: - State
    
    private var conversations: [Conversation] = []
    private let userId: String
    
    private var cancellable: AnyCancellable?
    
    // MARK: - Init
    
    init(flow: MessagingApplicationFlow, messagesRepository: MessagesRepository, userId: String) {
        self.messagesRepository = messagesRepository
        self.userId = userId
        super.init(flow: flow)
        
        Crashlytics.sharedInstance().setUserIdentifier(userId) // TODO: should this be here
        os_log("show converations for %@", log: self.log, type: .info, userId)
        
        cancellable = messagesRepository.fetchConversations(forUserId: userId).sink { [weak self] result in
            
            switch result {
            case .failure: break
            case .success(let conversations):
                self?.conversations = conversations
                self?.updateViewState(ConversationsViewState(conversations: conversations))
            }
        }
    }
    
    // MARK: - Handle ViewEvent
    
    override func handleViewEvent(_ event: ConversationsViewEvent) {
        super.handleViewEvent(event)
        
        switch event {
            
        case .conversationDeleted(let indexPath):
            
            guard let conversation = conversations[safe: indexPath.row] else { return }
                        
            _ = messagesRepository.deleteConversation(forUserId: userId, conversationId: conversation.id).sink { [weak self] result in
                
                guard let self = self else { return }
                
                switch result {
                case .failure(let error):
                    os_log("error deleting conversation", log: self.log, type: .error)
                    Crashlytics.sharedInstance().recordError(error)
                case .success:
                    os_log("deleted conversation", log: self.log, type: .info)
                }
            }
        case .conversationSelected(let indexPath):
            guard let conversation = conversations[safe: indexPath.row] else { return }
            try? conversationsCoordinatorActionHandler?.perform(.showConversation(conversation: conversation))
            
        case .profileButtonTapped:
            try? conversationsCoordinatorActionHandler?.perform(.presentProfile)
            
        case .addButtonTapped:
            try? conversationsCoordinatorActionHandler?.perform(.presentAddConversation)
        }
    }
}
