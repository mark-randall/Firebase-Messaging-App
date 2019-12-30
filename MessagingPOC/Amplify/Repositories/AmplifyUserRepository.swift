//
//  AmplifyUserRepository.swift
//  MessagingPOC
//
//  Created by Mark Randall on 12/26/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation
import AWSMobileClient
import Combine

final class AmplifyUserRepository: NSObject {
    
    private let logger: Logger
    
    private let fetchAuthResultSubject = CurrentValueSubject<Result<User?, Error>,Never>(.success(nil))
    
    init(logger: Logger) {
        self.logger = logger
        
        super.init()
        
        // TODO; why is addUserStateListener not called
        AWSMobileClient.default().initialize { [weak self] (userState, error) in
            
            if let error = error {
                self?.logger.log(error as NSError, at: .error)
            } else if let userState = userState {
                self?.update(withUserState: userState)
            } else {
                preconditionFailure()
            }
        }
        
        AWSMobileClient.default().addUserStateListener(self) { [weak self] (userState, info) in
            self?.update(withUserState: userState)
        }
    }
    
    private func update(withUserState userState: UserState) {
        
        logger.log("AWS userState: \(userState)")
        
        switch userState {
        case .signedIn:
            guard let id = AWSMobileClient.default().identityId else {
                fetchAuthResultSubject.send(.success(nil))
                return
            }
            let user = User(id: id)
            fetchAuthResultSubject.send(.success(user))
        default:
            fetchAuthResultSubject.send(.success(nil))
        }
    }
}


// MARK: - UserRepository

extension AmplifyUserRepository: UserRepository {
    
    func fetchAuthResult() -> AnyPublisher<Result<User?, Error>,Never> {
        fetchAuthResultSubject.eraseToAnyPublisher()
    }
    
    func presentAuthViewController(with navigationController: UINavigationController) {

        let options = SignInUIOptions(
            canCancel: true,
            logoImage: nil,
            backgroundColor: .blue,
            secondaryBackgroundColor: .green,
            primaryColor: .red,
            disableSignUpButton: false
        )
        
        AWSMobileClient.default().showSignIn(navigationController: navigationController, signInUIOptions: options) { (userState, error) in
            print(userState, error)
        }
    }
    
    // TODO: how are errors surfaced here
    func signOut() {
        AWSMobileClient.default().signOut()
    }
}
