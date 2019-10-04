//
//  ViewModel.swift
//
//  Created by Mark Randall on 8/20/19.
//

import Foundation

protocol ViewState: Equatable, Loggable {}

protocol ViewEffect: Loggable {}

protocol ViewEvent: Loggable {}

/// Each ViewModel is responsible for 3 things:
///
/// - ViewState - value object completely represents a View state
/// - ViewEffects - events from the VM the needs to be handled by the view. e.g. present error
/// - ViewEvents - user actions and system events from the View the VM needs to handled. e.g. button tapped
///
class ViewModel<F: Flow, VState: ViewState, VEffect: ViewEffect, VEvent: ViewEvent> {

    private(set) var currentFlow: F
    
    private(set) var viewState: VState? {
        didSet {
            if let viewState = self.viewState {
                DispatchQueue.main.execute { [weak self] in
                    self?.viewStateSubscription?(viewState)
                }
            }
        }
    }

    private var viewStateSubscription: ((VState) -> Void)?
    private var viewEffectSubscription: ((VEffect) -> Void)?

    // MARK: - Init
    
    init(flow: F) {
        self.currentFlow = flow
    }
    
    // MARK: - ViewModel lifecycle
    
    func subscribeToViewState(_ completion: @escaping (VState) -> Void) {
        if let viewState = self.viewState {
            DispatchQueue.main.async {
                completion(viewState)
            }
        }
        viewStateSubscription = completion
    }

    func subscribeToViewEffects(_ completion: @escaping (VEffect) -> Void) {
        viewEffectSubscription = completion
    }

    func handleViewEvent(_ event: VEvent) {
        LoggingManager.shared.log(event, at: .debug)
        // Override as necessary
    }

    // TODO: determine how to hide from View. Should not be called by View.
    func performViewEffect(_ viewEffect: VEffect) {
        LoggingManager.shared.log(viewEffect, at: .debug)
        DispatchQueue.main.execute { [weak self] in
            self?.viewEffectSubscription?(viewEffect)
        }
    }

    // TODO: determine how to hide from View. Should not be called by View.
    func updateViewState(_ viewState: VState) {
        LoggingManager.shared.log(viewState, at: .debug)
        guard viewState != self.viewState else { return }
        self.viewState = viewState
    }
}
