//
//  FirebaseServiceLocator.swift
//  MessagingPOC
//
//  Created by Mark Randall on 11/30/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase
import FirebaseMessaging
import GoogleSignIn
import Fabric
import Crashlytics

final class FirebaseServiceLocator: ServiceLocator {
    
    lazy var userRepository: UserRepository = { [unowned self] in
        return FirebaseUserRepository(logger: self.logger)
    }()

    lazy var messagesRepository: MessagesRepository = { [unowned self] in
        let db = Firestore.firestore()
        return FirestoreMessagesRepository(firestore: db, logging: self.logger)
    }()
    
    lazy var logger: Logger = Firebaselogger()
    
    init() {
        
        // Configure Firebase
        guard
            let firebasePlistFileName = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let firebaseOptions = FirebaseOptions(contentsOfFile: firebasePlistFileName)
            else {
                preconditionFailure()
        }
        FirebaseApp.configure(options: firebaseOptions)
        
        // Configure crash reporting
        Fabric.with([Crashlytics.self])
        
        // Configure Google Sign in
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
    }
}
