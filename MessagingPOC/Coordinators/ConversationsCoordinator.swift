//
//  ConversationsCoordinator.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/13/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit
import FirebaseFirestore

final class ConversationsCoordinator: BaseCoordinatorWithActions<MessagingApplicationFlow, ConversationAction> {
    
    // MARK: - Dependencies
    
    private let firestore: Firestore
    
    // MARK: - Init
    
    init(flow: MessagingApplicationFlow, presentingViewController: UIViewController, firestore: Firestore) {
        self.firestore = firestore
        super.init(flow: flow, presentingViewController: presentingViewController)
    }
    
    override func createRootViewController() -> UIViewController? {
        guard let vc: ConversationsViewController = try? UIViewController.create(storyboard: "Main", identifier: "ConversationsViewController") else { return nil }
        vc.coordinatorActionHandler = actionHandler
        vc.firestore = firestore
        return vc
    }

    override func start(presentingViewController: UIViewController?) throws {
        guard let nc = presentingViewController as? UINavigationController else { throw CoordinatorError.coordinatorNotPropertlyConfigured }
        nc.viewControllers = [rootViewController]
    }
    
    // MARK: - CoordinatorWithActions
    
    override func perform(_ action: ConversationAction) throws  {
        
        switch action {
        case .showConversation:
            let vc = try createViewController(forAction: action)
            guard let nc = self.presentingViewController as? UINavigationController else { throw CoordinatorError.coordinatorNotPropertlyConfigured }
            
            if nc.topViewController is ConversationViewController {
                nc.popViewController(animated: false)
                nc.pushViewController(vc, animated: false)
            } else {
                nc.pushViewController(vc, animated: true)
            }
        }
    }
    
    override func createViewController(forAction action: ConversationAction) throws -> UIViewController {
     
        switch action {
        case .showConversation(let id):
            let vc: ConversationViewController = try UIViewController.create(storyboard: "Main", identifier: "ConversationViewController")
            vc.conversationId = id
            vc.coordinatorActionHandler = actionHandler
            vc.firestore = firestore
            return vc
        }
    }
}
