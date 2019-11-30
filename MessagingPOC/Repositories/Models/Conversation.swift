//
//  Conversation.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/26/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation

struct Conversation: Equatable, Hashable, CustomDebugStringConvertible {
    
    // MARK: - CustomDebugStringConvertible
    
    var debugDescription: String {
        return "\(id)"
    }
    
    // MARK: - Properties
    
    let id: String
    let text: String
    let hasUnreadMessages: Bool
    let lastMessageSend: Date
    let contacts: [Contact] 
}
