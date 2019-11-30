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
    var contacts: String? = nil
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

typealias ConversationViewModelProtocol = ViewModel<MessagingApplicationFlow, ConversationViewState, ConversationViewEffect, ConversationViewEvent, ConversationCoordinatorEvent>

final class ConversationViewModel: ConversationViewModelProtocol, ConversationsCoordinatorController {
    
    // MARK: - CoordinatorController
    
    weak var conversationsCoordinatorActionHandler: ActionHandler<MessagingApplicationFlow, ConversationAction>?
    
    // MARK: - Dependencies
    
    private let messageRepostiory: MessagesRepository
    private let log = OSLog(subsystem: "com.messaging", category: "conversations")
    
    // MARK: - State
    
    private let userId: String
    private let conversation: Conversation?
    private var newConverationContacts: [Contact] = []
    
    private var cancellable: AnyCancellable?
    
    // MARK: - Init
    
    init(
        flow: MessagingApplicationFlow,
        messageRepostiory: MessagesRepository,
        userId: String,
        conversation: Conversation? = nil
    ) {
        self.messageRepostiory = messageRepostiory
        self.userId = userId
        self.conversation = conversation
        super.init(flow: flow)
        
        if let conversation = conversation {
            subscribeTo(conversationId: conversation.id)
        } else {
            viewStateSubject.send(ConversationViewState(contactsEditable: true))
        }
    }
        
    private func subscribeTo(conversationId: String) {
    
        cancellable = messageRepostiory.fetchMessages(forUserId: userId, conversationId: conversationId).sink { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure: break
            case .success(let messages):
                let viewState = ConversationViewState(
                    messages: messages,
                    contacts: self.conversation?.contacts.map({ $0.name }).joined(separator: ", ")
                )
                self.viewStateSubject.send(viewState)
            }
        }
    }
    
    // MARK: - Handle Events
    
    override func handleCoordinatorEvent(_ event: ConversationCoordinatorEvent) {
        super.handleCoordinatorEvent(event)
        
        switch event {
        case .contactAdded(let contact):
            guard var viewState = self.viewStateSubject.value else { assertionFailure(); return }
            newConverationContacts.append(contact)
            viewState.contacts = newConverationContacts.map { $0.name }.joined(separator: ", ")
            viewStateSubject.send(viewState)
        }
    }
    
    override func handleViewEvent(_ event: ConversationViewEvent) {
        super.handleViewEvent(event)
        
        switch event {
            
        case .messageViewed(let indexPath):
            
            guard let conversation = self.conversation else { return }
            guard let message = viewStateSubject.value?.messages[safe: indexPath.row] else { return }
            guard !message.isRead else { return }
            
            _ = messageRepostiory.updateMessageAsRead(forUserId: userId, conversationId: conversation.id, messageId: message.id).sink { [weak self] result in
                
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
            
            guard let conversationId = self.conversation?.id else { return }
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
