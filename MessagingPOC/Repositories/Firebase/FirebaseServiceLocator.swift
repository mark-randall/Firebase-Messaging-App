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
    
    lazy var userRepository: UserRepository = FirebaseUserRepository()

    lazy var messagesRepository: MessagesRepository = {
        let db = Firestore.firestore()
        return FirestoreMessagesRepository(firestore: db)
    }()
    
    lazy var loggingManager: LoggingManager = LoggingManager()
}
