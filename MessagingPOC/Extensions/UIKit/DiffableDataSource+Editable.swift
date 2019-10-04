//
//  DiffableDataSource+Editable.swift
//  MessagingPOC
//
//  Created by Mark Randall on 10/4/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit

final class EditableDiffableDataSource<S: Hashable, I: Hashable>: UITableViewDiffableDataSource<S, I> {

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

