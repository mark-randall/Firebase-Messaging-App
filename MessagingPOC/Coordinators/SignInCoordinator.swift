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

final class SignInCoordinator: BaseCoordinator<MessagingApplicationFlow> {
    
    // MARK: - Dependencies
    
    private lazy var authUI: FUIAuth? = {
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        authUI?.providers = [FUIGoogleAuth(), FUIEmailAuth()]
        return authUI
    }()
    
    // MARK: - Coordinator
    
    override func start(presentingViewController: UIViewController?) throws {
        guard let vc = authUI?.authViewController() else { throw CoordinatorError.coordinatorNotPropertlyConfigured }
        rootViewController.present(vc, animated: true, completion: nil)
    }
}

// MARK: - FUIAuthDelegate

extension SignInCoordinator: FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, url: URL?, error: Error?) {
        
        if let error = error {
            
            if (error as NSError).code == 1 {
                complete(withResult: .success)
            } else {
                complete(withResult: .error(error: error))
            }
        } else {
            complete(withResult: .success)
        }
    }
}
