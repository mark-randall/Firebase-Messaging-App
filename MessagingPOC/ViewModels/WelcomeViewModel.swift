//
//  WelcomeViewModel.swift
//  MessagingPOC
//
//  Created by Mark Randall on 10/2/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation
import os.log
import Crashlytics

// MARK: - ViewState

struct WelcomeViewState: ViewState {
}

// MARK: - ViewEffect

enum WelcomeViewEffect: ViewEffect {
}

// MARK: - ViewEvent

enum WelcomeViewEvent: ViewEvent {
    case signInButtonTapped
}

typealias WelcomeViewModelProtocol = ViewModel<MessagingApplicationFlow, WelcomeViewState, WelcomeViewEffect, WelcomeViewEvent>

final class WelcomeViewModel: WelcomeViewModelProtocol, RootCoordinatorController {
    
    // MARK: - CoordinatorController
    
    weak var rootCoordinatorActionHandler: ActionHandler<MessagingApplicationFlow, RootAction>?
    
    // MARK: - Handle ViewEvent

    override func handleViewEvent(_ event: WelcomeViewEvent) {
        super.handleViewEvent(event)
        
        switch event {
        case .signInButtonTapped:
            try? rootCoordinatorActionHandler?.perform(.presentSignIn)
        }
    }
}
