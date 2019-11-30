//
//  Message+Firebase.swift
//  MessagingPOC
//
//  Created by Mark Randall on 10/4/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation
import FirebaseFirestore

extension Message {
    
    init?(snapshot: DocumentSnapshot) {
        
        guard
            let data = snapshot.data(),
            let text = data["text"] as? String,
            let isRead = data["is_read"] as? Bool,
            let timestamp = data["time"] as? Timestamp,
            let senderData = data["sender"] as? [String: Any],
            let senderId = senderData["id"] as? String,
            let senderName = senderData["name"] as? String
            else { return nil }
        
        self.id = snapshot.documentID
        self.text = text
        self.isRead = isRead
        self.sent = timestamp.dateValue()
        self.from = Contact(id: senderId, name: senderName)
    }
}
