//
//  Coordination.swift
//
//  Created by Mark Randall on 1/19/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit

// MARK: - FlowResult

enum FlowResult {
    case success
    case error(error: Error)
}

// MARK: - CoordinatorError

enum CoordinatorError: Error {
    case coordinatorNotPropertlyConfigured
    case actionNotHandled
    case actionNotAllowed
    case flowNotHandled
    case flowNotAllowed
}

// MARK: - Action

/// Request to FlowController to update application Flow or Action with a Flow
/// NOTE: Flows are Actions
protocol Action: Equatable {
}

// MARK: - Flow

protocol Flow: Equatable {
}
