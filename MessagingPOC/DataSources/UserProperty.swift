//
//  UserProperty.swift
//  MessagingPOC
//
//  Created by Mark Randall on 12/22/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation

enum MessagesUserProperty: UserProperty {
    
    case signedInAs(id: String)
    
    var key: String {
        switch self {
        case .signedInAs: return "user id"
        }
    }
    
    var value: Any {
        switch self {
        case .signedInAs(let id): return id
        }
    }
}
