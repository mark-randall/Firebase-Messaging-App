//
//  RootCoordinator.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/13/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol RootCoordinatorController: CoordinatorController {

    var rootCoordinatorActionHandler: ActionHandler<MessagingApplicationFlow, RootAction>? { get set }
}

final class RootCoordinator: BaseCoordinatorWithActions<MessagingApplicationFlow, RootAction> {
    
    // MARK: - Dependencies
    
    private lazy var firestore: Firestore = {
        let db = Firestore.firestore()
        let settings = db.settings
        db.settings = settings
        return db
    }()
    
    private lazy var auth: Auth = {
       return Auth.auth()
    }()
    
    // MARK: - Coordinator overrides
    
    override func start(presentingViewController: UIViewController?) throws {
        
        rootViewController.view.backgroundColor = .white
        
        if auth.currentUser != nil {
            try presentFlow(.conversations)
        } else {
            guard let nc = rootViewController as? UINavigationController else { throw CoordinatorError.coordinatorNotPropertlyConfigured }
            let vc: WelcomeViewController = try UIViewController.create(storyboard: "Main", identifier: "WelcomeViewController")
            vc.rootCoordinatorActionHandler = actionHandler
            vc.currentFlow = .root
            nc.viewControllers = [vc]
        }
    }
    
    override func createRootViewController() -> UIViewController? {
        return presentingViewController
    }
    
    // MARK: - Coordinator flow overrides
    
    override func createCoordinator(forFlow flow: MessagingApplicationFlow) throws -> BaseCoordinator<MessagingApplicationFlow> {
        
        switch flow {
        case .signIn:
            (rootViewController as? UINavigationController)?.viewControllers = []
            return SignInCoordinator(flow: flow, presentingViewController: rootViewController, auth: auth)
        case .conversations:
            return ConversationsCoordinator(flow: flow, presentingViewController: rootViewController, firestore: firestore, auth: auth)
        case .root:
            return try super.createCoordinator(forFlow: flow)
        }
    }

    override func flowCompleted(_ flow: MessagingApplicationFlow, result: FlowResult) {
        
        switch flow {
        case .signIn:
            try? start(presentingViewController: nil)
        case .conversations:
            try? start(presentingViewController: nil)
        default:
            super.flowCompleted(flow, result: result)
        }
    }
    
    // MARK: - Coordinator action overrides
    
    override func perform(_ action: RootAction) throws {

        switch action {
        case .presentSignIn:
            try presentFlow(.signIn)
        case .showConversation(let id):
            guard childFlow == .conversations else { throw CoordinatorError.actionNotAllowed }
            guard let conversationsCoordinator = childCoordinator as? ConversationsCoordinator else { throw CoordinatorError.coordinatorNotPropertlyConfigured }
            try conversationsCoordinator.perform(.showConversation(id: id))
        }
    }
}
