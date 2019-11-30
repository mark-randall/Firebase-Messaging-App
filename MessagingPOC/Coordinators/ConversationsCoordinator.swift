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
    private let messagesRepository: MessagesRepository
    private let auth: Auth
    private let uid: String
    
    // MARK: - ViewModels
    
    private weak var conversationViewModel: ConversationViewModelProtocol?
    
    // MARK: - Init
    
    init(
        flow: MessagingApplicationFlow,
        presentingViewController: UIViewController,
        firestore: Firestore,
        messagesRepository: MessagesRepository,
        auth: Auth,
        uid: String
    ) {
        self.firestore = firestore
        self.messagesRepository = messagesRepository
        self.auth = auth
        self.uid = "mJ0ROv2pEqg1E8JK13OF9D1Mfay2" // TODO: hardcoding for dev
        super.init(flow: flow, presentingViewController: presentingViewController)
    }
    
    override func createRootViewController() -> UIViewController? {
        guard let vc: ConversationsViewController = try? UIViewController.create(storyboard: "Main", identifier: "ConversationsViewController") else { return nil }
        let vm = ConversationsViewModel(flow: flow, messagesRepository: messagesRepository, userId: uid) // TODO
        vm.conversationsCoordinatorActionHandler = actionHandler
        vc.bindViewModel(vm)
        return vc
    }

    override func start(topViewController: UIViewController?) throws {
        guard let nc = topViewController as? UINavigationController else { throw CoordinatorError.coordinatorNotPropertlyConfigured }
        nc.viewControllers = [rootViewController]
    }
    
    // MARK: - CoordinatorWithActions
    
    override func perform(_ action: ConversationAction) throws  {
        
        switch action {
        case .showConversation:
            let vc = try createViewController(forAction: action)
            guard let nc = topViewController as? UINavigationController else { throw CoordinatorError.coordinatorNotPropertlyConfigured }
            
            if nc.topViewController is ConversationViewController {
                nc.popViewController(animated: false)
                nc.pushViewController(vc, animated: false)
            } else {
                nc.pushViewController(vc, animated: true)
            }
        case .presentAddConversation:
            let vc = try createViewController(forAction: action)
            let nc = UINavigationController(rootViewController: vc)
            topViewController?.present(nc, animated: true, completion: nil)
        case .presentProfile:
            let vc = try createViewController(forAction: action)
            let nc = UINavigationController(rootViewController: vc)
            guard let presentingNc = topViewController as? UINavigationController else { throw CoordinatorError.coordinatorNotPropertlyConfigured }
            presentingNc.present(nc, animated: true, completion: nil)
        case .dismissProfile:
            guard let nc = topViewController as? UINavigationController else { throw CoordinatorError.coordinatorNotPropertlyConfigured }
            nc.dismiss(animated: true, completion: nil)
        case .presentAddContacts:
            let vc = try createViewController(forAction: action)
            let nc = UINavigationController(rootViewController: vc)
            topViewController?.present(nc, animated: true, completion: nil)
        case .logout:
            try auth.signOut()
            complete(withResult: .success)
        case .contactAdded(let contact):
            guard
                let nc = topViewController as? UINavigationController
                else { throw CoordinatorError.coordinatorNotPropertlyConfigured }
            conversationViewModel?.handleCoordinatorEvent(.contactAdded(contact: contact))
            nc.dismiss(animated: true, completion: nil)
        }
    }
    
    override func createViewController(forAction action: ConversationAction) throws -> UIViewController {
     
        switch action {
        case .showConversation(let conversation):
            let vc: ConversationViewController = try UIViewController.create(storyboard: "Main", identifier: "ConversationViewController")
            let vm = ConversationViewModel(flow: flow, messageRepostiory: messagesRepository, userId: uid, conversation: conversation)
            vm.conversationsCoordinatorActionHandler = actionHandler
            conversationViewModel = vm
            vc.bindViewModel(vm)
            return vc
        case .presentAddConversation:
            let vc: ConversationViewController = try UIViewController.create(storyboard: "Main", identifier: "ConversationViewController")
            let vm = ConversationViewModel(flow: flow, messageRepostiory: messagesRepository, userId: uid)
            vm.conversationsCoordinatorActionHandler = actionHandler
            conversationViewModel = vm
            vc.bindViewModel(vm)
            return vc
        case .presentProfile:
            let vc: ProfileViewController = try UIViewController.create(storyboard: "Main", identifier: "ProfileViewController")
            let vm = ProfileViewModel(flow: flow)
            vm.conversationsCoordinatorActionHandler = actionHandler
            vc.bindViewModel(vm)
            return vc
        case .presentAddContacts:
            let vc: ContactsViewController = try UIViewController.create(storyboard: "Main", identifier: "ContactsViewController")
            let vm = ContactsViewModel(flow: flow, firestore: firestore)
            vm.conversationsCoordinatorActionHandler = actionHandler
            vc.bindViewModel(vm)
            return vc
        default:
            return try super.createViewController(forAction: action)
        }
    }
}
