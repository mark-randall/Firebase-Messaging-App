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

// MARK: - Actions for Flows

enum RootAction: Action {
    case presentSignIn
    case showConversation(id: String)
}

enum ConversationAction: Action {
    case showConversation(id: String)
}
