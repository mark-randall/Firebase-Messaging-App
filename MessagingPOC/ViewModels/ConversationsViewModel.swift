//
//  ConversationsViewModel.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/26/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation
import Combine

// MARK: - ViewState

struct ConversationData: Equatable, Hashable {
    
    let id: String
    let text: String
    let lastMessageSend: Date
    
    init(conversation: Conversation) {
        id = conversation.id
        text = conversation.text
        lastMessageSend = conversation.lastMessageSend
    }
}

struct ConversationsViewState: ViewState {
    let title = "Conversations"
    var conversations: [ConversationData]
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

    private let serviceLocator: ServiceLocator
    
    // MARK: - State
    
    private var conversations: [Conversation] = []
    private let userId: String
    
    private var cancellable: AnyCancellable?
    
    // MARK: - Init
    
    init(flow: MessagingApplicationFlow, serviceLocator: ServiceLocator, userId: String) {
        self.serviceLocator = serviceLocator
        self.userId = userId
        super.init(flow: flow, logger: serviceLocator.logger)
        
        conversationsCoordinatorActionHandler?.log("show converations for \(userId)")
            
        cancellable = serviceLocator.messagesRepository.fetchConversations(forUserId: userId).sink { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure: break
            case .success(let conversations):
                self.conversations = conversations
                let conversationsData = conversations.map { ConversationData(conversation: $0) }
                self.viewStateSubject.send(ConversationsViewState(conversations: conversationsData))
            }
        }
    }
    
    // MARK: - Handle ViewEvent
    
    override func handleViewEvent(_ event: ConversationsViewEvent) {
        super.handleViewEvent(event)
        
        switch event {
            
        case .conversationDeleted(let indexPath):
            
            guard let conversation = conversations[safe: indexPath.row] else { return }
                        
            _ = serviceLocator.messagesRepository.deleteConversation(forUserId: userId, conversationId: conversation.id).sink { [weak self] result in
                                
                switch result {
                case .failure(let error):
                    self?.conversationsCoordinatorActionHandler?.log(error as NSError, at: .error)
                case .success:
                    self?.conversationsCoordinatorActionHandler?.log("deleted conversation", at: .error)
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
