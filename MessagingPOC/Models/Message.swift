//
//  Message.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/26/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Message: Equatable, Comparable, Hashable {
    
    // MARK: - Comparable
    
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sent < rhs.sent
    }
    
    // MARK: - Properties
    
    let id: String
    let text: String
    let isRead: Bool
    let sent: Date
    let from: String
    
    // MARK: - Init
    
    init?(snapshot: DocumentSnapshot) {
        
        guard
            let data = snapshot.data(),
            let text = data["text"] as? String,
            let isRead = data["is_read"] as? Bool,
            let timestamp = data["time"] as? Timestamp,
            let sender = data["sender"] as? [String: Any],
            let from = sender["id"] as? String
            else {
                return nil
        }
        
        self.id = snapshot.documentID
        self.text = text
        self.isRead = isRead
        self.sent = timestamp.dateValue()
        self.from = from
    }
}
