//
//  UITableView+Reorder.swift
//  SwiftReorder
//
//  Created by Adam Shin on 6/18/16.
//  Copyright © 2016 Adam Shin. All rights reserved.
//

import UIKit

public enum ReorderSpacerCellStyle {
    case Automatic
    case Hidden
    case Transparent
}

extension UITableView {
    
    private struct AssociatedKeys {
        static var reorder: UInt8 = 0
    }
    
    private var reorder: ReorderController? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.reorder) as? ReorderController }
        set { objc_setAssociatedObject(self, &AssociatedKeys.reorder, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    // MARK: Interface
    
    public var reorderDelegate: TableViewReorderDelegate? {
        get { return reorder?.delegate }
        set { self.reorder = ReorderController(tableView: self, delegate: newValue) }
    }
    
    public var reorderLongPressDuration: NSTimeInterval {
        get { return reorder?.longPressDuration ?? 0 }
        set { reorder?.longPressDuration = newValue }
    }
    public var reorderAnimationDuration: NSTimeInterval {
        get { return reorder?.animationDuration ?? 0 }
        set { reorder?.animationDuration = newValue }
    }
    public var reorderCellOpacity: CGFloat {
        get { return reorder?.cellOpacity ?? 1 }
        set { reorder?.cellOpacity = newValue }
    }
    public var reorderCellScale: CGFloat {
        get { return reorder?.cellScale ?? 1 }
        set { reorder?.cellScale = newValue }
    }
    public var reorderShadowColor: UIColor {
        get { return reorder?.shadowColor ?? .blackColor() }
        set { reorder?.shadowColor = newValue }
    }
    public var reorderShadowOpacity: CGFloat {
        get { return reorder?.shadowOpacity ?? 0 }
        set { reorder?.shadowOpacity = newValue }
    }
    public var reorderShadowRadius: CGFloat {
        get { return reorder?.shadowRadius ?? 0 }
        set { reorder?.shadowRadius = newValue }
    }
    public var reorderShadowOffset: CGSize {
        get { return reorder?.shadowOffset ?? .zero }
        set { reorder?.shadowOffset = newValue }
    }
    public var reorderSpacerCellStyle: ReorderSpacerCellStyle {
        get { return reorder?.spacerCellStyle ?? .Automatic }
        set { reorder?.spacerCellStyle = newValue }
    }
    
    public func spacerCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell? {
        return reorder?.spacerCellForIndexPath(indexPath)
    }
    
}

@objc public protocol TableViewReorderDelegate: class {
    
    optional func tableViewDidBeginReordering(tableView: UITableView)
    optional func tableViewDidFinishReordering(tableView: UITableView)
    
    optional func tableView(tableView: UITableView, canReorderRowAtIndexPath indexPath: NSIndexPath) -> Bool
    
    func tableView(tableView: UITableView, reorderRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)
    
}
