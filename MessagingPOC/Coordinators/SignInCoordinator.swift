//
//  SignInCoordinator.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/13/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit
import Combine

protocol SignInCoordinatorController: CoordinatorController {
    
    var signInCoordinatorActionHandler: ActionHandler<MessagingApplicationFlow, SignInAction>? { get set }
}

final class SignInCoordinator: BaseCoordinatorWithActions<MessagingApplicationFlow, SignInAction> {
    
    // MARK: - Dependencies
    
    private let serviceLocator: ServiceLocator
        
    private var subscriptions: [Cancellable] = []
    
    // MARK: - Init
    
    init(flow: MessagingApplicationFlow, presentingViewController: UIViewController, serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
        super.init(
            flow: flow,
            presentingViewController: presentingViewController,
            logger: serviceLocator.logger
        )
    }
    
    // MARK: - Coordinator
    
    override func start(topViewController: UIViewController?) throws {
        guard let vc = serviceLocator.userRepository.fetchAuthViewController() else { throw CoordinatorError.coordinatorNotPropertlyConfigured }
        
        subscriptions.append(serviceLocator.userRepository.fetchAuthResult().sink(receiveValue: { [weak self] result in
            
            switch result {
            case .failure(let error):
                self?.complete(withResult: .error(error: error))
            case .success(let user):
                if user != nil {
                    try? self?.perform(.showProfile)
                } else {
                    self?.complete(withResult: .success)
                }
            }
        }))
        
        rootViewController.present(vc, animated: true, completion: nil)
    }
        
    override func perform(_ action: SignInAction) throws {
        
        switch action {
        case .showProfile:
            let vc = try createViewController(forAction: action)
            guard let presentingNc = topViewController as? UINavigationController else { throw CoordinatorError.coordinatorNotPropertlyConfigured }
            presentingNc.viewControllers = [vc]
        case .logout:
            serviceLocator.userRepository.signOut() // TODO
            complete(withResult: .success)
        case .showConversations:
            complete(withResult: .success)
        }
    }
    
    override func createViewController(forAction action: SignInAction) throws -> UIViewController {
        
        switch action {
        case .showProfile:
            let vc: ProfileViewController = try UIViewController.create(storyboard: "Main", identifier: "ProfileViewController")
            let vm = ProfileViewModel(flow: flow, serviceLocator: serviceLocator)
            vm.signInCoordinatorActionHandler = actionHandler
            vc.bindViewModel(vm)
            return vc
        default:
            return try super.createViewController(forAction: action)
        }
    }
}
