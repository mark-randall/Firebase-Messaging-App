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
    case fcmToken(id: String)
    
    var key: String {
        switch self {
        case .signedInAs: return "user id"
        case .fcmToken: return "FCM instance token"
        }
    }
    
    var value: Any {
        switch self {
        case .signedInAs(let id): return id
        case .fcmToken(let id): return id
        }
    }
}
