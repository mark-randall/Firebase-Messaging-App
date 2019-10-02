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

enum SignInAction: Action {
    case showProfile
    case logout
    case showConversations
}

enum ConversationAction: Action {
    case showConversation(conversationId: String)
    case presentAddConversation
    case presentProfile
    case dismissProfile
    case logout
}
