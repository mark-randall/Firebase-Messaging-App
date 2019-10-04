import UIKit

extension UIView {
    
    // Create an instance of a T which is a UIView from nib 
    //
    // - Parameter fromNib: String nib name
    // - Parameter bundle: NSBundle?
    // - Return T
    class func create<T: UIView>(fromNib nibName: String, bundle: Bundle? = nil) -> T? {
        return UINib(
            nibName: nibName,
            bundle: bundle
        ).instantiate(withOwner: nil, options: nil)[0] as? T
    }
}
