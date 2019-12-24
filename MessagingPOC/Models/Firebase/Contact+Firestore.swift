//
//  Contact+Firestore.swift
//  MessagingPOC
//
//  Created by Mark Randall on 12/22/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation
import FirebaseFirestore

extension Contact {
    
    init?(snapshot: DocumentSnapshot) {
        
        guard
            let data = snapshot.data(),
            let firstName = data["first_name"] as? String,
            let lastName = data["last_name"] as? String
            else { return nil }
        
        self.id = snapshot.documentID
        self.name = "\(firstName) \(lastName)" // TODO: localize
    }
}
