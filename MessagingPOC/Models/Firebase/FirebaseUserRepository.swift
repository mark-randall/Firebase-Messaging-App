//
//  FirebaseUserRepository.swift
//  MessagingPOC
//
//  Created by Mark Randall on 11/30/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseUI
import FirebaseMessaging

final class FirebaseUserRepository: NSObject, UserRepository {
    
    private lazy var authUI: FUIAuth? = { [weak self] in
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        let phoneAuth = FUIPhoneAuth.init(authUI: FUIAuth.defaultAuthUI()!)
        authUI?.providers = [FUIGoogleAuth(), FUIEmailAuth(), phoneAuth]
        return authUI
    }()
    
    private lazy var auth: Auth = Auth.auth()
    
    var currentUser: User? {
        guard let firebaseUser = auth.currentUser else { return nil }
        return User(firebaseUser: firebaseUser)
    }
    
    private let logger: LoggingManager
    
    init(logger: LoggingManager) {
        self.logger = logger
    }
    
    func fetchAuthViewController() -> UIViewController? {
        return authUI?.authViewController()
    }
    
    private let fetchAuthResultSubject = PassthroughSubject<Result<User?, Error>,Never>()
    func fetchAuthResult() -> AnyPublisher<Result<User?, Error>,Never> {
        fetchAuthResultSubject.first().eraseToAnyPublisher()
    }
    
    // TODO: how are errors surfaced here
    func signOut() {
        if let currentUser = self.currentUser {
            logger.log("FCM unsubscribe from topic: \(currentUser.id)", at: .debug)
            Messaging.messaging().unsubscribe(fromTopic: currentUser.id)
        }
        try? auth.signOut()
    }
}

// MARK: - FUIAuthDelegate

extension FirebaseUserRepository: FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, url: URL?, error: Error?) {
        
        if let error = error {
            if (error as NSError).code == FUIAuthErrorCode.userCancelledSignIn.rawValue {
                fetchAuthResultSubject.send(.success(nil))
            } else {
                fetchAuthResultSubject.send(.failure(error))
            }
        } else {
            
            if let currentUser = self.currentUser {
                logger.log("FCM subscribe to topic: \(currentUser.id)", at: .debug)
                Messaging.messaging().subscribe(toTopic: currentUser.id)
            }
            
            fetchAuthResultSubject.send(.success(currentUser))
        }
    }
}
