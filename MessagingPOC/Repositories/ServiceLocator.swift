//
//  ServiceLocator.swift
//  MessagingPOC
//
//  Created by Mark Randall on 11/30/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

protocol ServiceLocator: class {
    var userRepository: UserRepository { get }
    var messagesRepository: MessagesRepository { get }
    var loggingManager: LoggingManager { get }
}
