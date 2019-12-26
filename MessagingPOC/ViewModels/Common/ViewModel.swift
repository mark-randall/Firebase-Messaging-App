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
    
    private let logger: Logger
    
    let viewStateSubject = CurrentValueSubject<VState?, Never>(nil)
    var viewState: AnyPublisher<VState?, Never> {
        viewStateSubject
            .removeDuplicates()
            .handleEvents(receiveOutput: { [weak self] in
                guard let viewState = $0 else { return }
                guard let self = self else { return }
                self.logger.log(viewState.forComponent("\(self.currentFlow)"), at: .debug)
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    let viewEffectSubject = PassthroughSubject<VEffect, Never>()
    var viewEffect: AnyPublisher<VEffect, Never> {
        viewEffectSubject
            .handleEvents(receiveOutput: { [weak self] in
                guard let self = self else { return }
                self.logger.log($0.forComponent("\(self.currentFlow)"), at: .debug)
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // MARK: - Init
    
    init(flow: F, logger: Logger) {
        self.currentFlow = flow
        self.logger = logger
    }
    
    // MARK: - ViewModel lifecycle
    
    func handleViewEvent(_ event: VEvent) {
        logger.log(event.forComponent("\(currentFlow)"), at: .debug)
        // Override as necessary
    }
    
    func handleCoordinatorEvent(_ event: CEvent) {
        logger.log(event.forComponent("\(currentFlow)"), at: .debug)
        // Override as necessary
    }
}
