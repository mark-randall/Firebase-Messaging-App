//
//  BaseCoordinator.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/17/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit

protocol Controller {
 
    associatedtype T: Flow
    associatedtype U: Action
    
    var coordinatorActionHandler: ActionHandler<T, U>? { get set }
}

class ActionHandler<T: Flow, U: Action> {

    private weak var coordinator: BaseCoordinatorWithActions<T,U>?

    func setCoordinator(_ coordinator: BaseCoordinatorWithActions<T,U>) {
        self.coordinator = coordinator
    }

    @discardableResult
    func perform(_ action: U) -> ActionResult {
        return coordinator?.perform(action) ?? .actionNotAllowed
    }
}

class BaseCoordinatorWithActions<T: Flow, U: Action>: BaseCoordinator<T> {
    
    let actionHandler: ActionHandler<T, U>
    
    override init(flow: T, presentingViewController: UIViewController? = nil) {
        actionHandler = ActionHandler()
        super.init(flow: flow, presentingViewController: presentingViewController)
        actionHandler.setCoordinator(self)
    }
    
    @discardableResult
    func perform(_ action: U) -> ActionResult {
        return .actionNotAllowed
    }
    
    func createViewController(forAction action: U) throws -> UIViewController {
        preconditionFailure("Abstract method")
    }
}

class BaseCoordinator<T: Flow>: NSObject {
    
    var flow: T
    
    var rootViewController: UIViewController?
    
    private(set) var childCoordinator: BaseCoordinator<T>?
    weak var parentCoordinator: BaseCoordinator<T>?
    
    init(flow: T, presentingViewController: UIViewController? = nil) {
        self.rootViewController = presentingViewController
        self.flow = flow
    }
    
    func start() {
    }
    
    func complete(withResult result: FlowResult) {
        parentCoordinator?.flowCompleted(flow, result: result)
        parentCoordinator?.childCoordinator = nil
    }
    
    // MARK: - Flows
    
    func presentFlow(_ flow: T) {
        
        do {
            let flowCoordinator = try createCoordinator(forFlow: flow)
            childCoordinator = flowCoordinator
            flowCoordinator.parentCoordinator = self
            flowCoordinator.start()
        } catch {
            flowCompleted(flow, result: .error(error: error))
        }
    }
    
    func createCoordinator(forFlow flow: T) throws -> BaseCoordinator<T> {
        flowCompleted(flow, result: .actionNotAllowed)
        preconditionFailure("Abstract must override")
    }
    
    func flowCompleted(_ flow: T, result: FlowResult) {
    }
}
