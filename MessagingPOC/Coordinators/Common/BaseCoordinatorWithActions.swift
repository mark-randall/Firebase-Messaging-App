//
//  BaseCoordinatorWithActions.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/18/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit

// MARK: - CoordinatorController

protocol CoordinatorController {
    
    associatedtype F: Flow
    
    var currentFlow: F { get }
}

// MARK: - ActionHandler

class ActionHandler<T: Flow, U: Action> {
    
    private weak var coordinator: BaseCoordinatorWithActions<T,U>?
    
    func setCoordinator(_ coordinator: BaseCoordinatorWithActions<T,U>) {
        self.coordinator = coordinator
    }
    
    func perform(_ action: U) throws {
        LoggingManager.shared.log(action, at: .debug)
        guard let coordinator = coordinator else { throw CoordinatorError.coordinatorNotPropertlyConfigured }
        return try coordinator.perform(action)
    }
}

// MARK: - BaseCoordinatorWithActions

class BaseCoordinatorWithActions<T: Flow, U: Action>: BaseCoordinator<T> {
    
    let actionHandler: ActionHandler<T, U>
    
    override init(flow: T, presentingViewController: UIViewController) {
        actionHandler = ActionHandler()
        super.init(flow: flow, presentingViewController: presentingViewController)
        actionHandler.setCoordinator(self)
    }
    
    func perform(_ action: U) throws {
        throw CoordinatorError.actionNotHandled
    }
    
    func createViewController(forAction action: U) throws -> UIViewController {
        throw CoordinatorError.actionNotHandled
    }
}
