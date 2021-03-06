//
//  ConversationViewModel.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/26/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation
import Combine

// MARK: - ViewState

struct MessageData: Equatable, Hashable {
    
    let id: String
    let text: String
    let from: String

    init(message: Message) {
        id = message.id
        text = message.text
        from = message.from.name
    }
}

struct ConversationViewState: ViewState {
    let title = "Conversation"
    var contactsEditable: Bool = false
    var messages: [MessageData] = []
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
    
    private let serviceLocator: ServiceLocator
    
    // MARK: - State
    
    private let userId: String
    private let conversation: Conversation?
    private var newConverationContacts: [Contact] = []
    private var messages: [Message] = []
    
    private var cancellable: AnyCancellable?
    
    // MARK: - Init
    
    init(
        flow: MessagingApplicationFlow,
        serviceLocator: ServiceLocator,
        userId: String,
        conversation: Conversation? = nil
    ) {
        self.serviceLocator = serviceLocator
        self.userId = userId
        self.conversation = conversation
        super.init(flow: flow, logger: serviceLocator.logger)
        
        if let conversation = conversation {
            subscribeTo(conversationId: conversation.id)
        } else {
            viewStateSubject.send(ConversationViewState(contactsEditable: true))
        }
    }
        
    private func subscribeTo(conversationId: String) {
    
        cancellable = serviceLocator.messagesRepository.fetchMessages(forUserId: userId, conversationId: conversationId).sink { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure: break
            case .success(let messages):
                self.messages = messages
                let viewState = ConversationViewState(
                    messages: messages.map({ MessageData(message: $0) }),
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
        case .contactWasSelected(let contact):
            guard var viewState = self.viewStateSubject.value else { assertionFailure(); return }
            newConverationContacts.append(contact)
            
            viewState.contacts = newConverationContacts
            .map { ContactData(contact: $0) }
            .map { $0.name }.joined(separator: ", ")
            
            viewStateSubject.send(viewState)
        }
    }
    
    override func handleViewEvent(_ event: ConversationViewEvent) {
        super.handleViewEvent(event)
        
        switch event {
            
        case .messageViewed(let indexPath):
            
            guard let conversation = self.conversation else { return }
            guard let message = messages[safe: indexPath.row] else { return }
            guard !message.isRead else { return }
            
            _ = serviceLocator.messagesRepository.updateMessageAsRead(forUserId: userId, conversationId: conversation.id, messageId: message.id).sink { [weak self] result in
                                
                switch result {
                case .failure(let error):
                    self?.conversationsCoordinatorActionHandler?.log(error as NSError, at: .error)
                case .success:
                    self?.conversationsCoordinatorActionHandler?.log("message marked as read")
                }
            }

        case .sendMessage(let messageText):
            
            let message: SentMessage
            if let conversationId = self.conversation?.id {
                message = SentMessage(
                    sendTo: .existingConversation(id: conversationId),
                    senderId: userId,
                    text: messageText
                )
            } else {
                message = SentMessage(
                    sendTo: .newConversation(id: UUID().uuidString, to: newConverationContacts),
                    senderId: userId,
                    text: messageText
                )
                subscribeTo(conversationId: message.conversationId)
            }
            
            _ = serviceLocator.messagesRepository.sendMessage(message, fromUserId: userId).sink { [weak self] result in
                                
                switch result {
                case .failure(let error):
                    self?.conversationsCoordinatorActionHandler?.log(error as NSError, at: .error)
                case .success:
                    self?.conversationsCoordinatorActionHandler?.log("message sent")
                }
            }
            
        case .addContactTapped:
            try? conversationsCoordinatorActionHandler?.perform(.presentAddContacts)
        }
    }
}
