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
            let vm = WelcomeViewModel(flow: flow)
            vm.rootCoordinatorActionHandler = actionHandler
            vc.bindViewModel(vm)
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
            return SignInCoordinator(flow: flow, presentingViewController: rootViewController, auth: auth)
        case .conversations:
            guard let uid = auth.currentUser?.uid else { throw CoordinatorError.flowNotAllowed }
            return ConversationsCoordinator(flow: flow, presentingViewController: rootViewController, firestore: firestore, auth: auth, uid: uid)
        case .root:
            return try super.createCoordinator(forFlow: flow)
        }
    }

    override func flowCompleted(_ flow: MessagingApplicationFlow, result: FlowResult) {
        
        switch flow {
        case .signIn:
            if case .success = result {
                try? start(presentingViewController: nil)
            }
        case .conversations:
            (rootViewController as? UINavigationController)?.topViewController?.dismiss(animated: true, completion: nil)
            try? start(presentingViewController: nil)
        default:
            super.flowCompleted(flow, result: result)
        }
        
        LoggingManager.shared.log(flow, at: .debug)
    }
    
    // MARK: - Coordinator action overrides
    
    override func perform(_ action: RootAction) throws {

        switch action {
        case .presentSignIn:
            try presentFlow(.signIn)
        case .showConversation(let id):
            guard childFlow == .conversations else { throw CoordinatorError.actionNotAllowed }
            guard let conversationsCoordinator = childCoordinator as? ConversationsCoordinator else { throw CoordinatorError.coordinatorNotPropertlyConfigured }
            try conversationsCoordinator.perform(.showConversation(conversationId: id))
        }
    }
}
