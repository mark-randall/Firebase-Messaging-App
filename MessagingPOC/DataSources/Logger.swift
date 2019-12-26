//
//  Logger.swift
//  MessagingPOC
//
//  Created by Mark Randall on 10/2/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation
import os.log

// MARK: Loggable things

protocol Loggable {
    var component: String { get }
    var logMessage: String { get }
}

private struct LoggableWithComponent: Loggable {
    var component: String
    var logMessage: String
}

extension Loggable {
    var component: String { "Default" }
    
    func forComponent(_ component: String) -> Loggable {
        return LoggableWithComponent(component: component.capitalized, logMessage: self.logMessage)
    }
}

// MARK: - Things which are loggable

extension Loggable where Self: Flow {

    var logMessage: String {
        return "Enter Flow: \(self)".capitalized
    }

    var component: String {
        return "\(self)".capitalized
    }
}

extension Loggable where Self: Action {
    
    var logMessage: String {
        return "Action: \(self)"
    }
}

extension Loggable where Self: ViewEvent {
    
    var logMessage: String {
        return "ViewEvent: \(self)"
    }
}

extension Loggable where Self: ViewEffect {
    
    var logMessage: String {
        return "ViewEffect: \(self)"
    }
}

extension Loggable where Self: ViewState {
    
    var logMessage: String {
        return "ViewState: \(self)"
    }
}

extension String: Loggable {
    
    var logMessage: String {
        return self
    }
}

extension NSError: Loggable {
    
    var logMessage: String {
        return localizedDescription
    }
}

extension Loggable {
    
    var logMessage: String {
        return "\(self)"
    }
}

// MARK: - UserProperty

protocol UserProperty: Loggable {
    var key: String { get }
    var value: Any { get }
}

extension UserProperty where Self: Loggable {
    
    var logMessage: String {
        return "\(key) = \(value)"
    }
}

// MARK: - Unified logging

class Logger {
        
    func log(_ log: Loggable, at type: OSLogType = .default) {
        let oslog = OSLog(subsystem: "com.messaging", category: log.component)
        os_log("%@", log: oslog, type: type, "\(log.logMessage) ~")
    }
    
    func set(userProperty: UserProperty & Loggable) {
        log(userProperty.forComponent("User property"))
    }
}
