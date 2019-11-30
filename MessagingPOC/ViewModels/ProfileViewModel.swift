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

struct ProfileViewState: ViewState {
    var showStartChattingButton: Bool = false
    var showCloseButton: Bool = false
}

// MARK: - ViewEffect

enum ProfileViewEffect: ViewEffect {
}

// MARK: - ViewEvent

enum ProfileViewEvent: ViewEvent {
    case loggoutButtonTapped
    case closeButtonTapped
    case startChattingButtonTapped
}

// MARK: - ViewModel

typealias ProfileViewModelProtocol = ViewModel<MessagingApplicationFlow, ProfileViewState, ProfileViewEffect, ProfileViewEvent, EmptyCoordinatorEvent>

final class ProfileViewModel: ProfileViewModelProtocol, ConversationsCoordinatorController, SignInCoordinatorController {
    
    // MARK: - CoordinatorController
    
    weak var conversationsCoordinatorActionHandler: ActionHandler<MessagingApplicationFlow, ConversationAction>?
    weak var signInCoordinatorActionHandler: ActionHandler<MessagingApplicationFlow, SignInAction>?
    
    // MARK: - Init
    
    convenience init(flow: MessagingApplicationFlow, serviceLocator: ServiceLocator) {
        self.init(flow: flow, loggingManager: serviceLocator.loggingManager)
            
        switch currentFlow {
        case .conversations:
            viewStateSubject.send(ProfileViewState(showCloseButton: true))
        case .signIn:
            viewStateSubject.send(ProfileViewState(showStartChattingButton: true))
        default: break
        }
    }
    
    // MARK: - Handle ViewEvent
    
    override func handleViewEvent(_ event: ProfileViewEvent) {
        super.handleViewEvent(event)
        
        switch event {
        case .loggoutButtonTapped:
            
            switch currentFlow {
            case .conversations:
                try? conversationsCoordinatorActionHandler?.perform(.logout)
            case .signIn:
                try? signInCoordinatorActionHandler?.perform(.logout)
            default: break
            }
        case .closeButtonTapped:
            try? conversationsCoordinatorActionHandler?.perform(.dismissProfile)
            
        case .startChattingButtonTapped:
            try? signInCoordinatorActionHandler?.perform(.showConversations)
        }
    }
}
