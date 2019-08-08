import UIKit

enum CreateStoryBoardError: Error {
    case invalidStoryboard
    case invalidStoryboardIdentifier
    case invalidViewControllerCreated
}

/// Factory to create UIViewControllers from a storynames
extension UIViewController {

    /// ViewController factory method
    ///
    /// - Parameters:
    ///   - storyboard: name of storyboard
    ///   - identifier: optional id of storyboard. If nil will return initial scene.
    /// - Returns: UIViewController
    /// - Throws: CreateStoryBoardError
    static func create<T: UIViewController>(storyboard: String, identifier: String? = nil) throws -> T {

        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        if let identifier = identifier {

            guard let vc = storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
                throw CreateStoryBoardError.invalidStoryboardIdentifier
            }
            return vc
        } else {

            guard let vc = storyboard.instantiateInitialViewController() as? T else {
                throw CreateStoryBoardError.invalidStoryboard
            }
            return vc
        }
    }
}
