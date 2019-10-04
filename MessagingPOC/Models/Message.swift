//
//  Message.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/26/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation

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
}
