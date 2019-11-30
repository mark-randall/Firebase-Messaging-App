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
    
    // MARK: - CustomDebugStringConvertible
    
    var debugDescription: String {
        return "'\(text)' SENT TO '\(conversationId)'"
    }
    
    // MARK: - Properties
    
    var id: String = UUID().uuidString
    
    var data: [String: Any] {
        return [
            "id": UUID().uuidString,
            "conversation_id": conversationId,
            "sender": [
                "id": senderId,
                "name": "TODO"
            ],
            "text": text,
            "time": Timestamp(date: Date()),
            "is_read": true
        ]
    }
    
    private let senderId: String
    private let text: String
    private let conversationId: String
    
    // MARK: - Init

    init(conversationId: String, senderId: String, text: String) {
        self.senderId = senderId
        self.text = text
        self.conversationId = conversationId
    }
}
