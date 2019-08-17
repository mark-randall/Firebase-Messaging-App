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

final class RootCoordinator: BaseCoordinatorWithActions<MessagingApplicationFlow, RootAction> {
    
    // MARK: - Dependencies
    
    private lazy var firestore: Firestore = {
        let db = Firestore.firestore()
        let settings = db.settings
        db.settings = settings
        return db
    }()
    
    // MARK: - Coordinator overrides
    
    override func start() {
        
        rootViewController?.view.backgroundColor = .white
        
        if Auth.auth().currentUser != nil {
            presentFlow(MessagingApplicationFlow.conversations)
        } else {
            
            do {
                let vc = try createViewController(forAction: .root)
                (rootViewController as? UINavigationController)?.viewControllers = [vc]
            } catch {
                complete(withResult: .error(error: error))
            }
        }
    }
    
    // MARK: - Coordinator flow overrides
    
    override func createCoordinator(forFlow flow: MessagingApplicationFlow) throws -> BaseCoordinator<MessagingApplicationFlow> {
        
        switch flow {
        case .signIn:
            (rootViewController as? UINavigationController)?.viewControllers = []
            return SignInCoordinator(flow: flow, presentingViewController: rootViewController)
        case .conversations:
            return ConversationsCoordinator(flow: flow, presentingViewController: rootViewController, firestore: firestore)
        case .root:
            preconditionFailure("")
        }
    }

    override func flowCompleted(_ flow: MessagingApplicationFlow, result: FlowResult) {
        
        switch flow {
        case .signIn:
            start()
        default: break
        }
    }
    
    // MARK: - Coordinator action overrides
    
    override func perform(_ action: RootAction) -> ActionResult {

        switch action {
        case .signIn:
            presentFlow(.signIn)
            return .success
        default:
            return super.perform(action)
        }
    }
    
    override func createViewController(forAction action: RootAction) throws -> UIViewController {
        
        switch action {
        case .root:
            let vc: WelcomeViewController = try UIViewController.create(storyboard: "Main", identifier: "WelcomeViewController")
            vc.coordinatorActionHandler = actionHandler
            return vc
        case .signIn:
            preconditionFailure()
        }
    }
}
