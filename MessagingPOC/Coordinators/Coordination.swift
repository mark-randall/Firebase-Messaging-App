//
//  Coordination.swift
//
//  Created by Mark Randall on 1/19/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit

// MARK: - Results

enum ActionResult {
    case success
    case error(error: Error)
    case actionNotAllowed
}

typealias FlowResult = ActionResult


// MARK: - Action

/// Request to FlowController to update application Flow or Action with a Flow
/// NOTE: Flows are Actions
protocol Action {
}

// MARK: - Flow

protocol Flow {
}
