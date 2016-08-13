//
// Copyright (c) 2016 Adam Shin
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
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
