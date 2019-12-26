//
//  BaseCoordinatorWithActions.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/18/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit
import os.log

// MARK: - CoordinatorController

protocol CoordinatorController {
    
    associatedtype F: Flow
    
    var currentFlow: F { get }
}

// MARK: - ActionHandler

class ActionHandler<T: Flow, U: Action> {
    
    private weak var coordinator: BaseCoordinatorWithActions<T,U>?
    
    private let logger: Logger
    
    init(logger: Logger) {
        self.logger = logger
    }
    
    func setCoordinator(_ coordinator: BaseCoordinatorWithActions<T,U>) {
        self.coordinator = coordinator
    }
    
    func perform(_ action: U) throws {
        logger.log(action)
        guard let coordinator = coordinator else { throw CoordinatorError.coordinatorNotPropertlyConfigured }
        return try coordinator.perform(action)
    }
    
    func log(_ log: Loggable, at: OSLogType = .default) {
        guard let coordinator = self.coordinator else { return }
        logger.log(log.forComponent("\(coordinator.flow)"))
    }
}

// MARK: - BaseCoordinatorWithActions

class BaseCoordinatorWithActions<T: Flow, U: Action>: BaseCoordinator<T> {
    
    let actionHandler: ActionHandler<T, U>
    
    override init(flow: T, presentingViewController: UIViewController, logger: Logger) {
        actionHandler = ActionHandler(logger: logger)
        super.init(flow: flow, presentingViewController: presentingViewController, logger: logger)
        actionHandler.setCoordinator(self)
    }
    
    func perform(_ action: U) throws {
        throw CoordinatorError.actionNotHandled
    }
    
    func createViewController(forAction action: U) throws -> UIViewController {
        throw CoordinatorError.actionNotHandled
    }
}
