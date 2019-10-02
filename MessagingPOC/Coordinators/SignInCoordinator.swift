//
//  SignInCoordinator.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/13/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseAuth

protocol SignInCoordinatorController: CoordinatorController {
    
    var signInCoordinatorActionHandler: ActionHandler<MessagingApplicationFlow, SignInAction>? { get set }
}

final class SignInCoordinator: BaseCoordinatorWithActions<MessagingApplicationFlow, SignInAction> {
    
    // MARK: - Dependencies
    
    private let auth: Auth
    
    private lazy var authUI: FUIAuth? = { [weak self] in
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        let phoneAuth = FUIPhoneAuth.init(authUI: FUIAuth.defaultAuthUI()!)
        authUI?.providers = [FUIGoogleAuth(), FUIEmailAuth(), phoneAuth]
        return authUI
    }()
    
    // MARK: - Init
    
    init(flow: MessagingApplicationFlow, presentingViewController: UIViewController, auth: Auth) {
        self.auth = auth
        super.init(flow: flow, presentingViewController: presentingViewController)
    }
    
    // MARK: - Coordinator
    
    override func start(presentingViewController: UIViewController?) throws {
        guard let vc = authUI?.authViewController() else { throw CoordinatorError.coordinatorNotPropertlyConfigured }
        rootViewController.present(vc, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    override func perform(_ action: SignInAction) throws {
        
        switch action {
        case .showProfile:
            let vc = try createViewController(forAction: action)
            guard let presentingNc = self.presentingViewController as? UINavigationController else { throw CoordinatorError.coordinatorNotPropertlyConfigured }
            presentingNc.viewControllers = [vc]
        case .logout:
            try auth.signOut()
            complete(withResult: .success)
        case .showConversations:
            complete(withResult: .success)
        }
    }
    
    override func createViewController(forAction action: SignInAction) throws -> UIViewController {
        
        switch action {
        case .showProfile:
            let vc: ProfileViewController = try UIViewController.create(storyboard: "Main", identifier: "ProfileViewController")
            vc.signInCoordinatorActionHandler = actionHandler
            vc.currentFlow = .signIn
            return vc
        default:
            return try super.createViewController(forAction: action)
        }
    }
}

// MARK: - FUIAuthDelegate

extension SignInCoordinator: FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, url: URL?, error: Error?) {
        
        if let error = error {
            
            if (error as NSError).code == FUIAuthErrorCode.userCancelledSignIn.rawValue {
                complete(withResult: .success)
            } else {
                complete(withResult: .error(error: error))
            }
        } else {
            try? perform(.showProfile)
        }
    }
    
    func authUI(_ authUI: FUIAuth, didFinish operation: FUIAccountSettingsOperationType, error: Error?) {
        
    }
}
