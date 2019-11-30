//
//  ViewModel.swift
//
//  Created by Mark Randall on 8/20/19.
//

import Foundation
import Combine

protocol ViewState: Equatable, Loggable {}

protocol ViewEffect: Loggable {}

protocol ViewEvent: Loggable {}

protocol CoordinatorEvent: Loggable {}

struct EmptyCoordinatorEvent: CoordinatorEvent {}

/// Each ViewModel is responsible for 3 things:
///
/// - ViewState - value object completely represents a View state
/// - ViewEffects - events from the VM the needs to be handled by the view. e.g. present error
/// - ViewEvents - user actions and system events from the View the VM needs to handled. e.g. button tapped
/// - CoordinatorEvent - events published by the coordinator. Generally used for pass messages from another VM within the coordinators Flow
///
class ViewModel<F: Flow, VState: ViewState, VEffect: ViewEffect, VEvent: ViewEvent, CEvent: CoordinatorEvent> {

    private(set) var currentFlow: F
    
    private let loggingManager: LoggingManager
    
    let viewStateSubject = CurrentValueSubject<VState?, Never>(nil)
    var viewState: AnyPublisher<VState?, Never> {
        viewStateSubject
            .removeDuplicates()
            .handleEvents(receiveOutput: { [weak self] in
                guard let viewState = $0 else { return }
                self?.loggingManager.log(viewState, at: .debug)
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    let viewEffectSubject = PassthroughSubject<VEffect, Never>()
    var viewEffect: AnyPublisher<VEffect, Never> {
        viewEffectSubject
            .handleEvents(receiveOutput: { [weak self] in
                self?.loggingManager.log($0, at: .debug)
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // MARK: - Init
    
    init(flow: F, loggingManager: LoggingManager) {
        self.currentFlow = flow
        self.loggingManager = loggingManager
    }
    
    // MARK: - ViewModel lifecycle
    
    func handleViewEvent(_ event: VEvent) {
        loggingManager.log(event, at: .debug)
        // Override as necessary
    }
    
    func handleCoordinatorEvent(_ event: CEvent) {
        loggingManager.log(event, at: .debug)
        // Override as necessary
    }
}
