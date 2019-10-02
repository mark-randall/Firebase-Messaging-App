//
//  SentMessage.swift
//  MessagingPOC
//
//  Created by Mark Randall on 9/22/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct SentMessage: Equatable {
    
    // MARK: - Properties
    
    let senderId: String
    let text: String
    let conversationId: String
    
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
    
    // MARK: - Init

    init(conversationId: String, senderId: String, text: String) {
        self.senderId = senderId
        self.text = text
        self.conversationId = conversationId
    }
}
