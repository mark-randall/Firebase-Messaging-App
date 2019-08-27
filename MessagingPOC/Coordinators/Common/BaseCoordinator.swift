//
//  BaseCoordinator.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/17/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit

// MARK: - BaseCoordinator

class BaseCoordinator<T: Flow>: NSObject {
    
    var flow: T
    var childFlow: T?
    
    lazy var rootViewController: UIViewController = { [weak self] in return self?.createRootViewController() ?? self?.presentingViewController ?? UINavigationController() }()
    private(set) weak var presentingViewController: UIViewController?
    
    private(set) var childCoordinator: BaseCoordinator<T>?
    weak var parentCoordinator: BaseCoordinator<T>?
    
    init(flow: T, presentingViewController: UIViewController) {
        self.flow = flow
        super.init()
        self.presentingViewController = presentingViewController
    }
    
    func createRootViewController() -> UIViewController? {
        return presentingViewController
    }
    
    func start(presentingViewController: UIViewController?) throws {
    }
    
    func complete(withResult result: FlowResult) {
        
        // Nil childCoordinator before calling flowCompleted because flowCompleted may set childCoordinator if a new coordinator is created
        parentCoordinator?.childCoordinator = nil
        childFlow = nil
        parentCoordinator?.flowCompleted(flow, result: result)
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