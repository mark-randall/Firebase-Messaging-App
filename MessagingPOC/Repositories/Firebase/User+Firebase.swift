//
//  User+Firebase.swift
//  MessagingPOC
//
//  Created by Mark Randall on 11/30/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation
import FirebaseAuth

extension User {
    
    init(firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
    }
}
