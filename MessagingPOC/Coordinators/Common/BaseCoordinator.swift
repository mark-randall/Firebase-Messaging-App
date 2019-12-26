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
    
    private(set) var rootViewController: UIViewController!
    
    var topViewController: UIViewController? {
        rootViewController?.getTopNavigationOrTabbarController()
    }
    
    private(set) var childCoordinator: BaseCoordinator<T>?
    weak var parentCoordinator: BaseCoordinator<T>?
    
    init(flow: T, presentingViewController: UIViewController, logger: Logger) {
        self.flow = flow
        super.init()
        rootViewController = createRootViewController() ?? presentingViewController
        
        logger.log(flow, at: .debug)
    }
    
    func createRootViewController() -> UIViewController? {
        return nil
    }
    
    func start(topViewController: UIViewController?) throws {
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
        try flowCoordinator.start(topViewController: topViewController)
    }
    
    func createCoordinator(forFlow flow: T) throws -> BaseCoordinator<T> {
        throw CoordinatorError.flowNotHandled
    }
    
    func flowCompleted(_ flow: T, result: FlowResult) {
    }
}
