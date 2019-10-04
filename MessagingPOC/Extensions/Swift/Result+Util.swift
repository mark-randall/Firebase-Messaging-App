//
//  Result+Util.swift
//  MessagingPOC
//
//  Created by Mark Randall on 10/4/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation

extension Result {
    
    var value: Success? {
        
        if case .success(let value) = self {
            return value
        } else {
            return nil
        }
    }
}
