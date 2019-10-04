//
//  LoggingManager.swift
//  MessagingPOC
//
//  Created by Mark Randall on 10/2/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation

// TODO: improve / finish though

// MARK: Loggable things

enum LogLevel: String {
    case debug
}

protocol Loggable {
    var logMessage: String { get }
}

protocol LoggableComponent {
    var logMessage: String { get }
    var component: String { get }
}

// MARK: - Things which are loggable

extension LoggableComponent where Self: Flow {

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

extension Loggable {
    
    var logMessage: String {
        return "\(self)"
    }
}

// MARK: - LoggingManager

final class LoggingManager {
    
    static var shared = LoggingManager()
    
    private init() {}
    
    private var component: String = ""
    
    func log(_ log: LoggableComponent, at level: LogLevel) {
        self.component = ""
        print("~ \(level.rawValue) - \(component): \(log.logMessage)")
        self.component = log.component
    }
    
    func log(_ log: Loggable, at level: LogLevel) {
        print("~ \(level.rawValue) - \(component): \(log.logMessage)")
    }
}
