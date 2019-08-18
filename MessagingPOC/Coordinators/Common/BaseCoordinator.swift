//
//  BaseCoordinator.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/17/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit

// MARK: - Controller

protocol Controller {
 
    associatedtype T: Flow
    associatedtype U: Action
    
    var coordinatorActionHandler: ActionHandler<T, U>? { get set }
}

// MARK: - ActionHandler

class ActionHandler<T: Flow, U: Action> {

    private weak var coordinator: BaseCoordinatorWithActions<T,U>?

    func setCoordinator(_ coordinator: BaseCoordinatorWithActions<T,U>) {
        self.coordinator = coordinator
    }

    func perform(_ action: U) throws {
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

// MARK: - BaseCoordinator

class BaseCoordinator<T: Flow>: NSObject {
    
    var flow: T
    var childFlow: T?
    
    lazy var rootViewController: UIViewController = { [weak self] in return self?.createRootViewController() ?? UINavigationController() }()
    private(set) weak var presentingViewController: UIViewController?
    
    private(set) var childCoordinator: BaseCoordinator<T>?
    weak var parentCoordinator: BaseCoordinator<T>?
    
    init(flow: T, presentingViewController: UIViewController) {
        self.flow = flow
        super.init()
        self.presentingViewController = presentingViewController
    }
    
    func createRootViewController() -> UIViewController? {
        return UINavigationController()
    }
    
    func start(presentingViewController: UIViewController?) throws {
    }
    
    func complete(withResult result: FlowResult) {
        parentCoordinator?.flowCompleted(flow, result: result)
        parentCoordinator?.childCoordinator = nil
        childFlow = nil
    }
    
    // MARK: - Flows
    
    func presentFlow(_ flow: T) throws {
        let flowCoordinator = try createCoordinator(forFlow: flow)
        childCoordinator = flowCoordinator
        flowCoordinator.parentCoordinator = self
        childFlow = flow
        try flowCoordinator.start(presentingViewController: presentingViewController)
    }
    
    func createCoordinator(forFlow flow: T) throws -> BaseCoordinator<T> {
        throw CoordinatorError.flowNotHandled
    }
    
    func flowCompleted(_ flow: T, result: FlowResult) {
    }
}
