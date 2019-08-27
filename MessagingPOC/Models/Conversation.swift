//
//  Conversation.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/26/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Conversation: Equatable {
    
    let id: String
    let text: String
    let hasUnreadMessages: Bool
    let lastMessageSend: Date
    
    init?(snapshot: DocumentSnapshot) {
        
        guard
            let data = snapshot.data(),
            let text = data["last_message_text"] as? String,
            let hasUnreadMessages = data["has_unread_messages"] as? Bool,
            let timestamp = data["time"] as? Timestamp
            else {
                return nil
        }
        
        self.id = snapshot.documentID
        self.text = text
        self.hasUnreadMessages = hasUnreadMessages
        self.lastMessageSend = timestamp.dateValue()
    }
}
