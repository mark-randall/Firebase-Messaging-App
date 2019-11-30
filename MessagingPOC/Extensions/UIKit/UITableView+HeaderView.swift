//
//  UITableView+HeaderView.swift
//  MessagingPOC
//
//  Created by Mark Randall on 11/30/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit

extension UITableView {

    func setTableHeaderView(headerView: UIView) {
        headerView.translatesAutoresizingMaskIntoConstraints = false

        self.tableHeaderView = headerView

        // Must setup AutoLayout after set tableHeaderView.
        headerView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        headerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    }

    func shouldUpdateHeaderViewFrame() -> Bool {
        guard let headerView = self.tableHeaderView else { return false }
        let oldSize = headerView.bounds.size
        
        // Update the size
        headerView.layoutIfNeeded()
        let newSize = headerView.bounds.size
        
        return oldSize != newSize
    }
}
