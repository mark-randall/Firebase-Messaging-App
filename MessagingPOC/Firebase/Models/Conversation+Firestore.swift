//
//  Conversation+Firestore.swift
//  MessagingPOC
//
//  Created by Mark Randall on 10/4/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation
import FirebaseFirestore

extension Conversation {
    
    init?(snapshot: DocumentSnapshot) {
        
        guard
            let data = snapshot.data(),
            let text = data["last_message_text"] as? String,
            let hasUnreadMessages = data["has_unread_messages"] as? Bool,
            let timestamp = data["time"] as? Timestamp,
            let contactsData = data["users"] as? [[String: Any]]
            else { return nil }
        
        self.id = snapshot.documentID
        self.text = text
        self.hasUnreadMessages = hasUnreadMessages
        self.lastMessageSend = timestamp.dateValue()
        
        self.contacts = contactsData.compactMap { data in
            
            guard
                let id = data["id"] as? String,
                let name = data["name"] as? String
                else { return nil }
            
            return Contact(id: id, name: name)
        }
    }
}
