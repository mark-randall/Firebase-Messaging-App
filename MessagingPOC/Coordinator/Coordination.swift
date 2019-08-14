//
//  Coordination.swift
//
//  Created by Mark Randall on 1/19/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit

// MARK: - PerformActionResult

enum PerformActionResult {
    case success
    case error(error: Error)
    case actionNotAllowed
}

// MARK: - Coordinator

/// Responsible for updating Apps Flow or Action of current Flow
protocol Coordinator {
    
    associatedtype ApplicationFlow: Flow
    associatedtype CoordinatorAction: Action
    
    init(rootViewController: UIViewController, completion: ((PerformActionResult) -> Void)?)
    
    func start()
    
    func presentFlow(_ flow: ApplicationFlow, completion: ((PerformActionResult) -> Void)?)
    
    @discardableResult
    func perform(_ action: CoordinatorAction) -> PerformActionResult
}

// MARK: - Action

/// Request to FlowController to update application Flow or Action with a Flow
/// NOTE: Flows are Actions
protocol Action {}

// MARK: - Flow

protocol Flow {}

// MARK: - SingleActionCoordinator

enum NoAction: Action {
}
