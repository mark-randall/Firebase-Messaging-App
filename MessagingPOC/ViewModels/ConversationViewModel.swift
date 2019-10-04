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
import Combine

// MARK: - ViewState

struct ConversationViewState: ViewState {

    let title = "Conversation"
    var contactsEditable: Bool = false
    var messages: [Message] = []
}

// MARK: - ViewEffect

enum ConversationViewEffect: ViewEffect {
}

// MARK: - ViewEvent

enum ConversationViewEvent: ViewEvent {
    case messageViewed(IndexPath)
    case sendMessage(String)
    case addContactTapped
}

// MARK: - ViewModel

typealias ConversationViewModelProtocol = ViewModel<MessagingApplicationFlow, ConversationViewState, ConversationViewEffect, ConversationViewEvent>

final class ConversationViewModel: ConversationViewModelProtocol, ConversationsCoordinatorController {
    
    // MARK: - CoordinatorController
    
    weak var conversationsCoordinatorActionHandler: ActionHandler<MessagingApplicationFlow, ConversationAction>?
    
    // MARK: - Dependencies
    
    private let messageRepostiory: MessagesRepository
    private let log = OSLog(subsystem: "com.messaging", category: "conversations")
    
    // MARK: - State
    
    private let userId: String
    private let conversationId: String?
    
    private var cancellable: AnyCancellable?
    
    // MARK: - Init
    
    init(flow: MessagingApplicationFlow, messageRepostiory: MessagesRepository, userId: String, conversationId: String? = nil) {
        self.messageRepostiory = messageRepostiory
        self.userId = userId
        self.conversationId = conversationId
        super.init(flow: flow)
        
        if let conversationId = conversationId {
            subscribeTo(conversationId: conversationId)
        } else {
            updateViewState(ConversationViewState(contactsEditable: true))
        }
    }
        
    private func subscribeTo(conversationId: String) {
    
        cancellable = messageRepostiory.fetchMessages(forUserId: userId, conversationId: conversationId).sink { [weak self] result in
            
            switch result {
            case .failure: break
            case .success(let messages):
                self?.updateViewState(ConversationViewState(messages: messages))
            }
        }
    }
    
    // MARK: - Handle ViewEvent
    
    override func handleViewEvent(_ event: ConversationViewEvent) {
        super.handleViewEvent(event)
        
        switch event {
            
        case .messageViewed(let indexPath):
            
            guard let conversationId = self.conversationId else { return }
            guard let message = viewState?.messages[safe: indexPath.row] else { return }
            guard !message.isRead else { return }
            
            _ = messageRepostiory.updateMessageAsRead(forUserId: userId, conversationId: conversationId, messageId: message.id).sink { [weak self] result in
                
                guard let self = self else { return }
                
                switch result {
                case .failure(let error):
                    os_log("error marking message as read", log: self.log, type: .error)
                    Crashlytics.sharedInstance().recordError(error)
                case .success:
                    os_log("message marked as read", log: self.log, type: .info)
                }
            }

        case .sendMessage(let message):
            
            guard let conversationId = self.conversationId else { return }
            let message = SentMessage(conversationId: conversationId, senderId: userId, text: message)
            
            _ = messageRepostiory.sendMessage(forUserId: userId, conversationId: conversationId, message: message).sink { [weak self] result in
                
                guard let self = self else { return }
                
                switch result {
                case .failure(let error):
                    os_log("error sending message", log: self.log, type: .error)
                    Crashlytics.sharedInstance().recordError(error)
                case .success:
                    os_log("message sent", log: self.log, type: .info)
                }
            }
            
        case .addContactTapped:
            try? conversationsCoordinatorActionHandler?.perform(.presentAddContacts)
        }
    }
}
