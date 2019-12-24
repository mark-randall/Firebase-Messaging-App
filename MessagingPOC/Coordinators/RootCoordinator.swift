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
    
    // MARK: - Dependencies

    private let serviceLocator: ServiceLocator = FirebaseServiceLocator()
        
    // MARK: - Coordinator overrides
    
    override func start(topViewController: UIViewController?) throws {
        
        rootViewController.view.backgroundColor = .white
        
        if let user = serviceLocator.userRepository.currentUser {
            serviceLocator.loggingManager.set(userProperty: MessagesUserProperty.signedInAs(id: user.id))
            try presentFlow(.conversations)
        } else {
            guard let nc = rootViewController as? UINavigationController else { throw CoordinatorError.coordinatorNotPropertlyConfigured }
            let vc: WelcomeViewController = try UIViewController.create(storyboard: "Main", identifier: "WelcomeViewController")
            let vm = WelcomeViewModel(flow: flow, loggingManager: serviceLocator.loggingManager)
            vm.rootCoordinatorActionHandler = actionHandler
            vc.bindViewModel(vm)
            nc.viewControllers = [vc]
        }
    }
    
    override func createRootViewController() -> UIViewController? {
        return topViewController
    }
    
    // MARK: - Coordinator flow overrides
    
    override func createCoordinator(forFlow flow: MessagingApplicationFlow) throws -> BaseCoordinator<MessagingApplicationFlow> {
        
        switch flow {
        case .signIn:
            return SignInCoordinator(flow: flow, presentingViewController: rootViewController, serviceLocator: serviceLocator)
        case .conversations:
            guard let uid = serviceLocator.userRepository.currentUser?.id else { throw CoordinatorError.flowNotAllowed }
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
        
        serviceLocator.loggingManager.log(MessagingApplicationFlow.root, at: .debug)
    }
    
    // MARK: - Coordinator action overrides
    
    override func perform(_ action: RootAction) throws {

        switch action {
        case .presentSignIn:
            try presentFlow(.signIn)
        case .showConversation(let conversation):
            guard childFlow == .conversations else { throw CoordinatorError.actionNotAllowed }
            guard let conversationsCoordinator = childCoordinator as? ConversationsCoordinator else { throw CoordinatorError.coordinatorNotPropertlyConfigured }
            try conversationsCoordinator.perform(.showConversation(conversation: conversation))
        }
    }
}
