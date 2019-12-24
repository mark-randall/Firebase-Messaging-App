//
//  Contact.swift
//  MessagingPOC
//
//  Created by Mark Randall on 10/2/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation

// Existing for new contact
struct Contact: Equatable, Hashable, CustomDebugStringConvertible {
    
    // MARK: - CustomDebugStringConvertible
    
    var debugDescription: String {
        return "\(name)"
    }
    
    // MARK: - Properties
    
    let id: String
    let name: String
    
    var data: [String: Any] {
        return [
            "id": id,
            "name": name
        ]
    }
}
