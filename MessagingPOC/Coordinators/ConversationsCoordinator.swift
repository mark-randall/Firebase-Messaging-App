//
//  ConversationsCoordinator.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/13/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

protocol ConversationsCoordinatorController: CoordinatorController {
    
    var conversationsCoordinatorActionHandler: ActionHandler<MessagingApplicationFlow, ConversationAction>? { get set }
}

final class ConversationsCoordinator: BaseCoordinatorWithActions<MessagingApplicationFlow, ConversationAction> {
    
    // MARK: - Dependencies
    
    private let firestore: Firestore
    private let auth: Auth
    private let uid: String
    
    // MARK: - Init
    
    init(
        flow: MessagingApplicationFlow,
        presentingViewController: UIViewController,
        firestore: Firestore,
        auth: Auth,
        uid: String
    ) {
        self.firestore = firestore
        self.auth = auth
        self.uid = uid
        super.init(flow: flow, presentingViewController: presentingViewController)
    }
    
    override func createRootViewController() -> UIViewController? {
        guard let vc: ConversationsViewController = try? UIViewController.create(storyboard: "Main", identifier: "ConversationsViewController") else { return nil }
        let vm = ConversationsViewModel(firestore: firestore, userId: uid)
        vm.conversationsCoordinatorActionHandler = actionHandler
        vm.currentFlow = .conversations
        vc.bindViewModel(vm)
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
        case .presentProfile:
            let vc = try createViewController(forAction: action)
            let nc = UINavigationController(rootViewController: vc)
            guard let presentingNc = self.presentingViewController as? UINavigationController else { throw CoordinatorError.coordinatorNotPropertlyConfigured }
            presentingNc.present(nc, animated: true, completion: nil)
        case .dismissProfile:
            guard let nc = self.presentingViewController as? UINavigationController else { throw CoordinatorError.coordinatorNotPropertlyConfigured }
            nc.dismiss(animated: true, completion: nil)
        case .logout:
            try auth.signOut()
            complete(withResult: .success)
            try perform(.dismissProfile)
            
        }
    }
    
    override func createViewController(forAction action: ConversationAction) throws -> UIViewController {
     
        switch action {
        case .showConversation(let id):
            let vc: ConversationViewController = try UIViewController.create(storyboard: "Main", identifier: "ConversationViewController")
            let vm = ConversationViewModel(firestore: firestore, userId: uid, conversationId: id)
            vm.conversationsCoordinatorActionHandler = actionHandler
            vm.currentFlow = .conversations
            vc.bindViewModel(vm)
            return vc
        case .presentProfile:
            let vc: ProfileViewController = try UIViewController.create(storyboard: "Main", identifier: "ProfileViewController")
            vc.conversationsCoordinatorActionHandler = actionHandler
            vc.currentFlow = .conversations
            return vc
        default:
            return try super.createViewController(forAction: action)
        }
    }
}
