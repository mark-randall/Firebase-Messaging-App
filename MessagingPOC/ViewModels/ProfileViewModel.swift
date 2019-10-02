//
//  ProfileViewModel.swift
//  MessagingPOC
//
//  Created by Mark Randall on 10/2/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation
import os.log
import Crashlytics

// MARK: - ViewState

struct ProfileViewState: Equatable {
    var showStartChattingButton: Bool = false
    var showCloseButton: Bool = false
}

// MARK: - ViewEffect

enum ProfileViewEffect {
}

// MARK: - ViewEvent

enum ProfileViewEvent {
    case loggoutButtonTapped
    case closeButtonTapped
    case startChattingButtonTapped
}

typealias ProfileViewModelProtocol = ViewModel<ProfileViewState, ProfileViewEffect, ProfileViewEvent>

final class ProfileViewModel: ProfileViewModelProtocol, ConversationsCoordinatorController, SignInCoordinatorController {
    
    // MARK: - CoordinatorController
    
    var currentFlow: MessagingApplicationFlow?
    weak var conversationsCoordinatorActionHandler: ActionHandler<MessagingApplicationFlow, ConversationAction>?
    weak var signInCoordinatorActionHandler: ActionHandler<MessagingApplicationFlow, SignInAction>?
    
    init(currentFlow: MessagingApplicationFlow) {
        super.init()
        self.currentFlow = currentFlow
            
        switch currentFlow {
        case .conversations:
            updateViewState(ProfileViewState(showCloseButton: true))
        case .signIn:
            updateViewState(ProfileViewState(showStartChattingButton: true))
        default: break
        }
    }
    
    override func handleViewEvent(_ event: ProfileViewEvent) {
        
        switch event {
        case .loggoutButtonTapped:
            
            if let currentFlow = currentFlow {
                
                switch currentFlow {
                case .conversations:
                    try? conversationsCoordinatorActionHandler?.perform(.logout)
                case .signIn:
                    try? signInCoordinatorActionHandler?.perform(.logout)
                default: break
                }
            }
        case .closeButtonTapped:
            try? conversationsCoordinatorActionHandler?.perform(.dismissProfile)
            
        case .startChattingButtonTapped:
            try? signInCoordinatorActionHandler?.perform(.showConversations)
        }
    }
}
