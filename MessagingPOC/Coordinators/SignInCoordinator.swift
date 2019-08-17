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
    
    override func start() {
        
        guard let vc = authUI?.authViewController() else {
            // TODO: better error
            complete(withResult: .error(error: NSError(domain: "", code: 0, userInfo: [:])))
            return
        }
        
        rootViewController?.present(vc, animated: true, completion: nil)
    }
}

// MARK: - FUIAuthDelegate

extension SignInCoordinator: FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, url: URL?, error: Error?) {
        
        if let error = error {
            
            let ns = error as NSError
            guard ns.code != 1 else {
                complete(withResult: .success)
                return
            }

            complete(withResult: .error(error: error))
        } else {
            complete(withResult: .success)
        }
    }
}
