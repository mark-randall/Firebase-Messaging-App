//
//  MessagesRepository.swift
//  MessagingPOC
//
//  Created by Mark Randall on 10/3/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Combine

protocol MessagesRepository {
    
    func fetchConversations(forUserId id: String) -> AnyPublisher<Result<[Conversation], Error>, Never>
    
    func deleteConversation(forUserId userId: String, conversationId: String) -> AnyPublisher<Result<Bool, Error>, Never>
    
    func fetchMessages(forUserId userId: String, conversationId: String) -> AnyPublisher<Result<[Message], Error>, Never>

    func updateMessageAsRead(forUserId userId: String, conversationId: String, messageId: String) -> AnyPublisher<Result<Bool, Error>, Never>

    func sendMessage(_ message: SentMessage, fromUserId userId: String) -> AnyPublisher<Result<Bool, Error>, Never>
    
    func fetchContacts(forUserId userId: String) -> AnyPublisher<Result<[Contact], Error>, Never>
}
