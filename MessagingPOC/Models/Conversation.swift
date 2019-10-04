//
//  Conversation.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/26/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation

struct Conversation: Equatable {
    
    // MARK: - Properties
    
    let id: String
    let text: String
    let hasUnreadMessages: Bool
    let lastMessageSend: Date
}
