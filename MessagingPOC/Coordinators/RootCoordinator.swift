//
//  RootCoordinator.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/13/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit
import Combine

protocol RootCoordinatorController: CoordinatorController {

    var rootCoordinatorActionHandler: ActionHandler<MessagingApplicationFlow, RootAction>? { get set }
}

final class RootCoordinator: BaseCoordinatorWithActions<MessagingApplicationFlow, RootAction> {
    
    private var subscriptions: [Cancellable] = []
    
    // MARK: - Dependencies

    private let serviceLocator: ServiceLocator
        
    init(flow: MessagingApplicationFlow, presentingViewController: UIViewController, serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
        super.init(flow: flow, presentingViewController: presentingViewController, logger: serviceLocator.logger)
    }
    
    // MARK: - Coordinator overrides
    
    override func start(topViewController: UIViewController?) throws {
        
        rootViewController.view.backgroundColor = .white
        
        subscriptions.append(serviceLocator.userRepository.fetchAuthResult().sink { [weak self] userResult in
            
            guard let self = self else { return }
            
            switch self.flow {
                
            case .root:
                
                if case .success(let u) = userResult, let user = u {
                    self.serviceLocator.logger.set(userProperty: MessagesUserProperty.signedInAs(id: user.id))
                    try? self.presentFlow(.conversations(userId: user.id))
                } else {
                    
                    guard
                        let nc = self.rootViewController as? UINavigationController,
                        let vc: WelcomeViewController = try? UIViewController.create(storyboard: "Main", identifier: "WelcomeViewController")
                        else { return }
                    let vm = WelcomeViewModel(flow: self.flow, logger: self.serviceLocator.logger)
                    vm.rootCoordinatorActionHandler = self.actionHandler
                    vc.bindViewModel(vm)
                    nc.viewControllers = [vc]
                }
                
            case .conversations: return // TODO: log user out
                
            case .signIn: return // TODO: this should never happen?
            }
        })
    }
    
    override func createRootViewController() -> UIViewController? {
        return topViewController
    }
    
    // MARK: - Coordinator flow overrides
    
    override func createCoordinator(forFlow flow: MessagingApplicationFlow) throws -> BaseCoordinator<MessagingApplicationFlow> {
        
        switch flow {
        case .signIn:
            return SignInCoordinator(flow: flow, presentingViewController: rootViewController, serviceLocator: serviceLocator)
        case .conversations(let uid):
            return ConversationsCoordinator(
                flow: flow,
                presentingViewController: rootViewController,
                serviceLocator: serviceLocator,
                uid: uid
            )
        case .root:
            return try super.createCoordinator(forFlow: flow)
        }
    }

    override func flowCompleted(_ flow: MessagingApplicationFlow, result: FlowResult) {
        
        switch flow {
        case .signIn:
            if case .success = result {
                try? start(topViewController: nil)
            }
        case .conversations:
            (rootViewController as? UINavigationController)?.topViewController?.dismiss(animated: true, completion: nil)
            try? start(topViewController: nil)
        default:
            super.flowCompleted(flow, result: result)
        }
        
        serviceLocator.logger.log(MessagingApplicationFlow.root, at: .debug)
    }
    
    // MARK: - Coordinator action overrides
    
    override func perform(_ action: RootAction) throws {

        switch action {
        case .presentSignIn:
            try presentFlow(.signIn)
        case .showConversation(let conversation):
            
            switch childFlow {
            case .conversations:
                guard let conversationsCoordinator = childCoordinator as? ConversationsCoordinator else { throw CoordinatorError.coordinatorNotPropertlyConfigured }
                try conversationsCoordinator.perform(.showConversation(conversation: conversation))
            default:
                throw CoordinatorError.actionNotAllowed
            }
        }
    }
}
