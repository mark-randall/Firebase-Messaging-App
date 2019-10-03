//
//  WelcomeViewModel.swift
//  MessagingPOC
//
//  Created by Mark Randall on 10/2/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation

import Foundation
import os.log
import Crashlytics

// MARK: - ViewState

struct WelcomeViewState: Equatable {
}

// MARK: - ViewEffect

enum WelcomeViewEffect {
}

// MARK: - ViewEvent

enum WelcomeViewEvent {
    case signInButtonTapped
}

typealias WelcomeViewModelProtocol = ViewModel<MessagingApplicationFlow, WelcomeViewState, WelcomeViewEffect, WelcomeViewEvent>

final class WelcomeViewModel: WelcomeViewModelProtocol, RootCoordinatorController {
    
    // MARK: - CoordinatorController
    
    weak var rootCoordinatorActionHandler: ActionHandler<MessagingApplicationFlow, RootAction>?
    
    // MARK: - Handle ViewEvent

    override func handleViewEvent(_ event: WelcomeViewEvent) {
        
        switch event {
        case .signInButtonTapped:
            try? rootCoordinatorActionHandler?.perform(.presentSignIn)
        }
    }
}
