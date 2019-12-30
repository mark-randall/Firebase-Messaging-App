//
//  AmplifyServiceLocator.swift
//  MessagingPOC
//
//  Created by Mark Randall on 12/30/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation
import Amplify
import AWSMobileClient

final class AmplifyServiceLocator: ServiceLocator {
    
    lazy var userRepository: UserRepository = { [unowned self] in
        return AmplifyUserRepository(logger: self.logger)
    }()

    lazy var messagesRepository: MessagesRepository = { [unowned self] in
        preconditionFailure()
    }()
    
    lazy var logger: Logger = Firebaselogger()
    
    init() {
        
        // Configure Amplify
        
        do {
            try Amplify.configure()
            
            // AWSMobileClient is initialized by UserRepo
            
//            AWSMobileClient.default().initialize { (userState, error) in
//                if let userState = userState {
//                    print("UserState: \(userState.rawValue)")
//                } else if let error = error {
//                    print("error: \(error.localizedDescription)")
//                }
//            }
            
            print("Amplify initialized")
        } catch {
            print("Failed to configure Amplify \(error)")
        }
    }
}
