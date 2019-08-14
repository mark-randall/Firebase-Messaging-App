//
//  AppFlows.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/13/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation

// MARK: - Flows

enum ApplicationFlow: Flow {
    case root
    case conversations
    case signIn
}

enum RootAction: Action {
    case signIn
}
