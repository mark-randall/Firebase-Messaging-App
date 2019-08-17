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
    
    init(flow: MessagingApplicationFlow, presentingViewController: UIViewController? = nil, firestore: Firestore) {
        self.firestore = firestore
        super.init(flow: flow, presentingViewController: presentingViewController)
    }
    
    override func start() {
        
        do {
            let vc = try createViewController(forAction: .root)
            (rootViewController as? UINavigationController)?.viewControllers = [vc]
            rootViewController = vc
        } catch {
            complete(withResult: .error(error: error))
        }
    }
    
    // MARK: - CoordinatorWithActions
    
    override func perform(_ action: ConversationAction) -> ActionResult {
        
        switch action {
        case .showConversation:
            guard let vc = try? createViewController(forAction: action) else { preconditionFailure() }
            rootViewController?.show(vc, sender: nil)
            return .success
        default:
            return super.perform(action)
        }
    }
    
    override func createViewController(forAction action: ConversationAction) throws -> UIViewController {
     
        switch action {
        case .root:
            let vc: ConversationsViewController = try UIViewController.create(storyboard: "Main", identifier: "ConversationsViewController")
            vc.coordinatorActionHandler = actionHandler
            vc.firestore = firestore
            return vc
        case .showConversation(let id):
            let vc: ConversationViewController = try UIViewController.create(storyboard: "Main", identifier: "ConversationViewController")
            vc.conversationId = id
            vc.coordinatorActionHandler = actionHandler
            vc.firestore = firestore
            return vc
        }
    }
}
