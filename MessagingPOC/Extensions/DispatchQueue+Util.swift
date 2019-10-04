import Foundation

extension DispatchQueue {

    /// Executes on main thread. Syncroniously if already on main thread. Otherwise schedules on main thread with async
    /// It is not possible to call sync on UI DispatchQueue because it will immediately cause a deadlock
    /// Helpful for writing unit tests because code is only excuted async if necessary
    ///
    /// - Parameter execute: Completion to call on main thread
    func execute(_ execute: @escaping () -> Void) {

        if Thread.isMainThread {
            execute()
        } else {
            DispatchQueue.main.async {
                execute()
            }
        }
    }
}
