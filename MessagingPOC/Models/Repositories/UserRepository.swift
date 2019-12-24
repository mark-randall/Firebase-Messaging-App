//
//  UserRepository.swift
//  MessagingPOC
//
//  Created by Mark Randall on 11/30/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Combine
import UIKit

protocol UserRepository {
    
    var currentUser: User? { get }
    
    func fetchAuthViewController() -> UIViewController?
    
    // TODO: figure out how to make this a Future
    func fetchAuthResult() -> AnyPublisher<Result<User?, Error>,Never>
    
    // TODO: how to surface errors
    func signOut()
}
