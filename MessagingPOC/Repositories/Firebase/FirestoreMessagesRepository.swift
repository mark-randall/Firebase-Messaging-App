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

final class FirestoreMessagesRepository {
    
    private let firestore: Firestore
    
    init(firestore: Firestore) {
        self.firestore = firestore
    }
}


// MARK: - MessagesRepository

extension FirestoreMessagesRepository: MessagesRepository {
     
    func fetchConversations(forUserId id: String) -> AnyPublisher<Result<[Conversation], Error>, Never> {

        return firestore
        .collection("/users/\(id)/conversations")
        .whereField("is_blocked", isEqualTo: false)
        .whereField("is_deleted", isEqualTo: false)
        .order(by: "time", descending: true)
        .snapshotListenerPublisher()
        .map { result in
            
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

        let messages: AnyPublisher<Result<[Message], Error>, Never> = firestore
        .collection("/users/\(userId)/conversations/\(conversationId)/messages")
        .whereField("is_blocked", isEqualTo: false)
        .whereField("is_deleted", isEqualTo: false)
        .snapshotListenerPublisher()
        .map { result in
            
            switch result {
            case .failure(let error):
                return .failure(error)
            case .success(let snapshot):
                let messages = snapshot.documents.compactMap { Message(snapshot: $0) }
                return .success(messages)
            }
        }.eraseToAnyPublisher()
            
        let sendPendingMessages: AnyPublisher<Result<[Message], Error>, Never> = firestore
        .collection("/users/\(userId)/conversations/\(conversationId)/send_pending_messages")
        .snapshotListenerPublisher()
        .map { result in
            
            switch result {
            case .failure(let error):
                return .failure(error)
            case .success(let snapshot):
                let messages = snapshot.documents.compactMap { Message(snapshot: $0) }
                return .success(messages)
            }
        }.eraseToAnyPublisher()

        return Publishers.CombineLatest(messages, sendPendingMessages).map { (result1, result2) in
            
            switch result1 {
            case .failure(let error):
                return .failure(error)
            case .success(let messages):
                let newAndExistingMessages = Array(Set(messages + (result2.value ?? []))).sorted()
                return .success(newAndExistingMessages)
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

    func sendMessage(forUserId userId: String, conversationId: String, message: SentMessage) -> AnyPublisher<Result<Bool, Error>, Never> {
        
        return firestore
        .collection("users/\(userId)/conversations/\(conversationId)/send_pending_messages")
        .document(message.id)
        .setPublisher(message.data)
        .eraseToAnyPublisher()
    }
}
