
import UIKit

public extension UIView {
    
    /// Creates constraints from visualFormatting strings
    /// An NSLayoutConstraint is created from each visualFormatting element and activated
    /// views values have translatesAutoresizingMaskIntoConstraints set to false
    ///
    /// - Parameter visualFormatting: [String]
    /// - Parameter views: [String: UIView]
    /// - returns: [NSLayoutConstraint]
    ///
    @discardableResult
    static func createConstraints(
        visualFormatting: [String],
        views: [String: UIView],
        activitateCreatedConstraints: Bool = true
    ) -> [NSLayoutConstraint] {
        
        for view in views.values {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        var constraints: [NSLayoutConstraint] = []
        for visualFormat in visualFormatting {
            constraints += NSLayoutConstraint.constraints(withVisualFormat: visualFormat, options: [], metrics: nil, views: views)
        }
        
        if activitateCreatedConstraints == true {
            constraints.forEach { $0.isActive = true }
        }
        
        return constraints
    }
    
    @discardableResult
    func pinToSuperView(inset: UIEdgeInsets = UIEdgeInsets.zero, height: String = ">=0") -> [NSLayoutConstraint] {
        return UIView.createConstraints(visualFormatting: [
            "V:|-(\(inset.top))-[v(\(height))]-(\(inset.bottom))-|",
            "H:|-(\(inset.left))-[v]-(\(inset.right))-|"
        ], views: ["v": self])
    }
}
