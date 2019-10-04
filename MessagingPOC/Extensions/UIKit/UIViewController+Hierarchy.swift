//
//  UIViewController+Dismiss.swift
//
//  Created by mrandall on 3/25/16.
//  Copyright (c) 2015 Mark Randall. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func getTopNavigationOrTabbarController() -> UIViewController {
        let vc = getVisibleViewController()
        return vc.navigationController ?? vc.tabBarController ?? vc
    }
    
    /// Get the top most presented viewController
    /// Recursively returns the presentedViewControllers presentedViewController
    /// Returns self if self.presentedViewController = nil
    ///
    /// - Return UIViewController
    func getVisibleViewController() -> UIViewController {
        
        //check if VC has a presentedViewController
        guard let presentedViewController = self.presentedViewController else {
            
            //check if VC is NC, if so call recursively on NC.topVC
            if
                let nc = self as? UINavigationController,
                let topVC = nc.topViewController
            {
                return topVC.getVisibleViewController()
            }
            
            //check if VC is TabC, if so call recursivley on TabVC.selectedVC
            if
                let tabC = self as? UITabBarController,
                let selectedVC = tabC.selectedViewController
            {
                return selectedVC.getVisibleViewController()
            }
            
            //if self has not presented VC is not a NC or a TabVC return self
            return self
        }
        
        //if presentedVC has a presentedVC call recursively
        return presentedViewController.getVisibleViewController()
    }
}
