//
//  ViewModel.swift
//
//  Created by Mark Randall on 8/20/19.
//

import Foundation

/// Each ViewModel is responsible for 3 things:
///
/// - ViewState - value object completely represents a View state
/// - ViewEffects - events from the VM the needs to be handled by the view. e.g. present error
/// - ViewEvents - user actions and system events from the View the VM needs to handled. e.g. button tapped
///
class ViewModel<F: Flow, ViewState: Equatable, ViewEffect, ViewEvent> {

    private(set) var currentFlow: F
    
    private(set) var viewState: ViewState? {
        didSet {
            if let viewState = self.viewState {
                DispatchQueue.main.execute { [weak self] in
                    self?.viewStateSubscription?(viewState)
                }
            }
        }
    }

    private var viewStateSubscription: ((ViewState) -> Void)?
    private var viewEffectSubscription: ((ViewEffect) -> Void)?

    // MARK: - Init
    
    init(flow: F) {
        self.currentFlow = flow
    }
    
    // MARK: - ViewModel lifecycle
    
    func subscribeToViewState(_ completion: @escaping (ViewState) -> Void) {
        if let viewState = self.viewState {
            DispatchQueue.main.async {
                completion(viewState)
            }
        }
        viewStateSubscription = completion
    }

    func subscribeToViewEffects(_ completion: @escaping (ViewEffect) -> Void) {
        viewEffectSubscription = completion
    }

    func handleViewEvent(_ event: ViewEvent) {
        // Override as necessary
    }

    // TODO: determine how to hide from View. Should not be called by View.
    func performViewEffect(_ viewEffect: ViewEffect) {
        DispatchQueue.main.execute { [weak self] in
            self?.viewEffectSubscription?(viewEffect)
        }
    }

    // TODO: determine how to hide from View. Should not be called by View.
    func updateViewState(_ viewState: ViewState) {
        guard viewState != self.viewState else { return }
        self.viewState = viewState
    }
}
