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

final class SignInCoordinator: NSObject, Coordinator {
    
    // MARK: - Dependencies
    
    private lazy var authUI: FUIAuth? = {
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        authUI?.providers = [FUIGoogleAuth(), FUIEmailAuth()]
        return authUI
    }()
    
    private let rootViewController: UIViewController
    private let coordinatorCompletion: ((PerformActionResult) -> Void)?
    
    // MARK: - Init
    
    init(rootViewController: UIViewController, completion: ((PerformActionResult) -> Void)?) {
        self.rootViewController = rootViewController
        self.coordinatorCompletion = completion
        super.init()
    }
    
    deinit {
        print("deinit")
    }
    
    // MARK: - Coordinator
    
    func start() {
        guard let vc = authUI?.authViewController() else { return }
        rootViewController.present(vc, animated: true, completion: nil)
    }
    
    func presentFlow(_ flow: ApplicationFlow, completion: ((PerformActionResult) -> Void)?) {
        completion?(.actionNotAllowed)
    }
    
    func perform(_ action: NoAction) -> PerformActionResult {
        return .actionNotAllowed
    }
}

// MARK: - FUIAuthDelegate

/// Used to customize the UI for Firebase Auth UI
extension SignInCoordinator: FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, url: URL?, error: Error?) {
        
        // UserRepository handles success by listening for FirebaseAuth addStateDidChangeListener
        // Current assumption is that this error doesn't need to be presented to the user
        if let error = error {
            
            let ns = error as NSError
            // If it's just the generic error that gets thrown when the login modal is dismissed
            // without a login, we will ignore it.
            guard ns.code != 1 else {
                //AnalyticsManager.shared.logCustomEvent(event: AnalyticsManager.SignInEvent.signFlowCompleted(result: .canceled))
                coordinatorCompletion?(.success)
                return
            }
            
            
            
            //AnalyticsManager.shared.logCustomEvent(event: AnalyticsManager.SignInEvent.signFlowCompleted(result: .failed))
            //window?.rootViewController?.getVisibleViewController().presentError(error)
            coordinatorCompletion?(.error(error: error))
        } else {
            //AnalyticsManager.shared.logCustomEvent(event: AnalyticsManager.SignInEvent.signFlowCompleted(result: .successful))
            //NotificationCenter.default.post(name: GlobalNotification.AuthWillComplete.name, object: self, userInfo: [:])
            coordinatorCompletion?(.success)
            
        }
        
        
    }
}
