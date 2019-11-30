//
//  Message.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/26/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation

// Existing message
struct Message: Equatable, Comparable, Hashable, CustomDebugStringConvertible {
        
    // MARK: - CustomDebugStringConvertible
    
    var debugDescription: String {
        return "\(text)"
    }
    
    // MARK: - Comparable
    
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sent < rhs.sent
    }
    
    // MARK: - Properties
    
    let id: String
    let text: String
    let isRead: Bool
    let sent: Date
    let from: Contact
}
