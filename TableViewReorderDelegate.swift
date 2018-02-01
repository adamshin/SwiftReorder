//
//  TableViewReorderDelegate.swift
//  SwiftReorder
//
//  Created by Adam Shin on 1/31/18.
//  Copyright © 2018 Adam Shin. All rights reserved.
//

import UIKit

/**
 The delegate of a `ReorderController` must adopt the `TableViewReorderDelegate` protocol. This protocol defines methods for handling the reordering of rows.
 */
public protocol TableViewReorderDelegate: class {
    
    /**
     Asks the reorder delegate whether a given row can be moved.
     - Parameter tableView: The table view requesting this information.
     - Parameter indexPath: The index path of a row.
     */
    func tableView(_ tableView: UITableView, canReorderRowAt indexPath: IndexPath) -> Bool
    
    /**
     Tells the delegate that the user has moved a row from one location to another. Use this method to update your data source.
     - Parameter tableView: The table view requesting this action.
     - Parameter sourceIndexPath: The index path of the row to be moved.
     - Parameter destinationIndexPath: The index path of the row's new location.
     */
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    
}

public extension TableViewReorderDelegate {
    
    func tableView(_ tableView: UITableView, canReorderRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}
