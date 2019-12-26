//
//  FirebaseServiceLocator.swift
//  MessagingPOC
//
//  Created by Mark Randall on 11/30/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation
import FirebaseFirestore

final class FirebaseServiceLocator: ServiceLocator {
    
    lazy var userRepository: UserRepository = { [unowned self] in
        return FirebaseUserRepository(logger: self.loggingManager)
    }()

    lazy var messagesRepository: MessagesRepository = { [unowned self] in
        let db = Firestore.firestore()
        return FirestoreMessagesRepository(firestore: db, logging: self.loggingManager)
    }()
    
    lazy var loggingManager: LoggingManager = LoggingManager()
}
