//
//  SentMessage.swift
//  MessagingPOC
//
//  Created by Mark Randall on 9/22/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation
import FirebaseFirestore

// Message begin sent
struct SentMessage: Equatable, CustomDebugStringConvertible {

    enum SentTo: Equatable {
        case existingConversation(id: String)
        case newConversation(id: String, to: [Contact])
        
        var data: [String: Any] {
            switch self {
            case .newConversation(let id, let contacts):
                return [
                    "_send_to": [
                        "is_new": true,
                        "conversation_id": id,
                        "contacts": contacts.map({ $0.data })
                    ]
                ]
            case .existingConversation(let id):
                return [
                    "_send_to": [
                        "is_new": false,
                        "conversation_id": id
                    ]
                ]
            }
        }
    }
    
    // MARK: - CustomDebugStringConvertible
    
    var debugDescription: String {
        return "'\(text)' SENT TO '\(sendTo.data)'"
    }
    
    // MARK: - Properties
    
    var id: String = UUID().uuidString
    
    var conversationId: String {
        switch sendTo {
        case .newConversation(let id, _): return id
        case .existingConversation(let id): return id
        }
    }
    
    var data: [String: Any] {
        return [ 
            "sender": [
                "id": senderId,
                "name": "TODO"
            ],
            "text": text,
            "time": Timestamp(date: Date()),
            "is_read": true,
            "is_blocked": false,
            "is_deleted": false,
            "is_flagged": false
        ].merging(sendTo.data) { (_, new) in new }
    }
    
    private let senderId: String
    private let text: String
    let sendTo: SentTo
    
    // MARK: - Init

    init(sendTo: SentTo, senderId: String, text: String) {
        self.sendTo = sendTo
        self.senderId = senderId
        self.text = text
    }
}
