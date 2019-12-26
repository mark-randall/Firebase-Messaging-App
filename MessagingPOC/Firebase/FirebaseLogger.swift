//
//  Firebaselogger.swift
//  MessagingPOC
//
//  Created by Mark Randall on 12/26/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation
import os.log
import Crashlytics

class Firebaselogger: Logger {
        
    override func log(_ log: Loggable, at type: OSLogType = .default) {
        super.log(log, at: type)

        if let error = log as? Error {
            Crashlytics.sharedInstance().recordError(error)
        }
    }
    
    override func set(userProperty: UserProperty & Loggable) {
        super.set(userProperty: userProperty)
        
        if let messagesUserProperty = userProperty as? MessagesUserProperty {
            switch messagesUserProperty {
            case .signedInAs(let userId):
                Crashlytics.sharedInstance().setUserIdentifier(userId)
            default: break
            }
        } else {
            Crashlytics.sharedInstance().setObjectValue(userProperty.value, forKey: userProperty.key)
        }        
    }
}
