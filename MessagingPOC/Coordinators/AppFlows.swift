//
//  AppFlows.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/13/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation

// MARK: - Flows

enum MessagingApplicationFlow: Flow {
    case root
    case conversations
    case signIn
}

enum RootAction: Action {
    case root
    case signIn
}

enum ConversationAction: Action {
    case root
    case showConversation(id: String)
}
