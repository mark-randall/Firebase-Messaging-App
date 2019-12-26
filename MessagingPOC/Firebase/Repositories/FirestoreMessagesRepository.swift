//
//  FirestoreMessagesRepository.swift
//  MessagingPOC
//
//  Created by Mark Randall on 10/3/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Combine

enum FirestoreMessagesRepositoryLoggable: Loggable {
    
    case collectionUpdated(path: String, snapshotResult: Result<QuerySnapshot, Error>)
    
    var component: String { "FirestoreMessagesRepository" }
    
    var logMessage: String {
        switch self {
        case .collectionUpdated(let path, let snapshot):
            return "\(path) RETURNED \(snapshot)"
        }
    }
}

final class FirestoreMessagesRepository {
    
    private let firestore: Firestore
    private let logging: Logger
    
    init(firestore: Firestore, logging: Logger) {
        self.firestore = firestore
        self.logging = logging
    }
}

// MARK: - MessagesRepository

extension FirestoreMessagesRepository: MessagesRepository {
     
    func fetchConversations(forUserId id: String) -> AnyPublisher<Result<[Conversation], Error>, Never> {

        let collection = firestore.collection("/users/\(id)/conversations")
        
        return collection
        .whereField("is_blocked", isEqualTo: false)
        .whereField("is_deleted", isEqualTo: false)
        .order(by: "time", descending: true)
        .snapshotListenerPublisher()
        .handleEvents(receiveOutput: { [weak self] result in
            
            // Debug log
            self?.logging.log(FirestoreMessagesRepositoryLoggable.collectionUpdated(path: "\(collection.path)", snapshotResult: result), at: .debug)
            
        }).map { result in
            
            switch result {
            case .failure(let error):
                return .failure(error)
            case .success(let snapshot):
                let conversations = snapshot.documents.compactMap { Conversation(snapshot: $0) }
                return .success(conversations)
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteConversation(forUserId userId: String, conversationId: String) -> AnyPublisher<Result<Bool, Error>, Never> {

        return firestore
        .collection("/users/\(userId)/conversations")
        .document(conversationId)
        .updatePublisher(["is_deleted": true])
        .eraseToAnyPublisher()
    }
    
    func fetchMessages(forUserId userId: String, conversationId: String) -> AnyPublisher<Result<[Message], Error>, Never> {

        let collection = firestore.collection("/users/\(userId)/conversations/\(conversationId)/messages")
        
        return collection
        .whereField("is_blocked", isEqualTo: false)
        .whereField("is_deleted", isEqualTo: false)
        .order(by: "time", descending: false)
        .snapshotListenerPublisher()
        .handleEvents(receiveOutput: { [weak self] result in
            self?.logging.log(FirestoreMessagesRepositoryLoggable.collectionUpdated(path: "\(collection.path)", snapshotResult: result), at: .debug)
        }).map { result in
            
            switch result {
            case .failure(let error):
                return .failure(error)
            case .success(let snapshot):
                let messages = snapshot.documents.compactMap { Message(snapshot: $0) }
                return .success(messages)
            }
        }.eraseToAnyPublisher()
    }

    func updateMessageAsRead(forUserId userId: String, conversationId: String, messageId: String) -> AnyPublisher<Result<Bool, Error>, Never> {
        
        return firestore
        .collection("users/\(userId)/conversations/\(conversationId)/messages")
        .document(messageId)
        .updatePublisher(["is_read": true])
        .eraseToAnyPublisher()
    }

    func sendMessage(_ message: SentMessage, fromUserId userId: String) -> AnyPublisher<Result<Bool, Error>, Never> {
        
        return firestore
        .collection("users/\(userId)/conversations/\(message.conversationId)/messages")
        .document(message.id)
        .setPublisher(message.data)
        .eraseToAnyPublisher()
    }
    
    func fetchContacts(forUserId userId: String) -> AnyPublisher<Result<[Contact], Error>, Never> {
        
        let collection = firestore.collection("/users/\(userId)/contacts")
        
        return collection
        .order(by: "last_name", descending: false)
        .snapshotListenerPublisher()
        .handleEvents(receiveOutput: { [weak self] result in
            self?.logging.log(FirestoreMessagesRepositoryLoggable.collectionUpdated(path: "\(collection.path)", snapshotResult: result), at: .debug)
        }).map { result in
            
            switch result {
            case .failure(let error):
                return .failure(error)
            case .success(let snapshot):
                let conversations = snapshot.documents.compactMap { Contact(snapshot: $0) }
                return .success(conversations)
            }
        }.eraseToAnyPublisher()
    }
}
