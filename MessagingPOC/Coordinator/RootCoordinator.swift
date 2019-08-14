//
//  RootCoordinator.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/13/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit
import FirebaseAuth

final class RootCoordinator: NSObject, Coordinator {
    
    private(set) var rootViewController: UIViewController

    
    // MARK: - Init
    
    init(rootViewController: UIViewController, completion: ((PerformActionResult) -> Void)?) {
        self.rootViewController = rootViewController
        super.init()
    }
    
    // MARK: - Coordinator
    
    func start() {
        
        if Auth.auth().currentUser != nil {
            presentFlow(.conversations, completion: nil)
        } else {
            guard let vc: WelcomeViewController = try? UIViewController.create(storyboard: "Main", identifier: "WelcomeViewController") else { preconditionFailure() }
            vc.coordinator = self
            (rootViewController as? UINavigationController)?.viewControllers = [vc]
        }
    }

    func presentFlow(_ flow: ApplicationFlow, completion: ((PerformActionResult) -> Void)?) {
        
        switch flow {
        case .signIn:
            
            let signIn = SignInCoordinator(rootViewController: rootViewController) { result in
                
                switch result {
                case .actionNotAllowed: preconditionFailure()
                case .success:
                    if Auth.auth().currentUser != nil {
                        self.presentFlow(.conversations, completion: nil)
                    }
                case .error(let error):
                    // TODO: print error
                    print(error)
                }
            }
            
            signIn.start()
        
        case .conversations:
            guard let vc: ConversationsViewController = try? UIViewController.create(storyboard: "Main", identifier: "ConversationsViewController") else { return }
            (rootViewController as? UINavigationController)?.viewControllers = [vc]
        default:
            completion?(.actionNotAllowed)
        }
    }
    
    @discardableResult
    func perform(_ action: RootAction) -> PerformActionResult {
        
        switch action {
        case .signIn:
            presentFlow(.signIn) { result in
                print(result)
            }
            return .success
        }
    }
}
