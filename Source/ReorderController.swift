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

/**
 The style of the reorder spacer cell. Determines whether the cell separator line is visible.
 
 - Automatic: The style is determined based on the table view's style (plain or grouped).
 - Hidden: The spacer cell is hidden, and the separator line is not visible.
 - Transparent: The spacer cell is given a transparent background color, and the separator line is visible.
 */
public enum ReorderSpacerCellStyle {
    case Automatic
    case Hidden
    case Transparent
}

/**
 The delegate of a `ReorderController` must adopt the `TableViewReorderDelegate` protocol. This protocol defines methods for handling the reordering of rows.
 */
@objc public protocol TableViewReorderDelegate: class {
    
    func tableView(tableView: UITableView, reorderRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)
    
    optional func tableViewDidBeginReordering(tableView: UITableView)
    optional func tableViewDidFinishReordering(tableView: UITableView)
    optional func tableView(tableView: UITableView, canReorderRowAtIndexPath indexPath: NSIndexPath) -> Bool
    
}

/**
 An object that manages drag-and-drop reordering of table view cells.
 */
public class ReorderController: NSObject {
    
    // MARK: - Public interface
    
    /// The delegate of the reorder controller. This object must adopt the `TableViewReorderDelegate` protocol.
    public weak var delegate: TableViewReorderDelegate?
    
    public var longPressDuration: NSTimeInterval = 0.3 {
        didSet {
            reorderGestureRecognizer.minimumPressDuration = longPressDuration
        }
    }
    
    /// The duration of the cell selection animation.
    public var animationDuration: NSTimeInterval = 0.2
    
    /// The opacity of the selected cell.
    public var cellOpacity: CGFloat = 1
    
    /// The scale factor for the selected cell.
    public var cellScale: CGFloat = 1
    
    /// The shadow color for the selected cell.
    public var shadowColor = UIColor.blackColor()
    
    /// The shadow opacity for the selected cell.
    public var shadowOpacity: CGFloat = 0.3
    
    /// The shadow radius for the selected cell.
    public var shadowRadius: CGFloat = 10
    
    /// The shadow offset for the selected cell.
    public var shadowOffset = CGSize(width: 0, height: 3)
    
    /// The spacer cell style.
    public var spacerCellStyle: ReorderSpacerCellStyle = .Automatic
    
    // MARK: - Internal state
    
    internal enum ReorderState {
        case Ready(snapshotRow: NSIndexPath?)
        case Reordering(sourceRow: NSIndexPath, destinationRow: NSIndexPath, snapshotOffset: CGFloat)
    }
    
    internal weak var tableView: UITableView?
    
    internal var reorderState: ReorderState = .Ready(snapshotRow: nil)
    internal var snapshotView: UIView? = nil
    
    internal var autoScrollDisplayLink: CADisplayLink?
    internal var lastAutoScrollTimeStamp: CFTimeInterval?
    
    internal lazy var reorderGestureRecognizer: UILongPressGestureRecognizer = {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleReorderGesture))
        gestureRecognizer.delegate = self
        gestureRecognizer.minimumPressDuration = self.longPressDuration
        return gestureRecognizer
    }()
    
    // MARK: - Lifecycle
    
    init(tableView: UITableView) {
        super.init()
        
        self.tableView = tableView
        tableView.addGestureRecognizer(reorderGestureRecognizer)
        
        reorderState = .Ready(snapshotRow: nil)
    }
    
    // MARK: - Reordering
    
    internal func beginReorderWithTouchPoint(point: CGPoint) {
        guard case .Ready = reorderState else { return }
        guard let tableView = tableView, sourceRow = tableView.indexPathForRowAtPoint(point) else { return }
        
        guard delegate?.tableView?(tableView, canReorderRowAtIndexPath: sourceRow) != false else { return }
        
        createSnapshotViewForCellAtIndexPath(sourceRow)
        animateSnapshotViewIn()
        activateAutoScrollDisplayLink()
        
        tableView.reloadData()
        
        let snapshotOffset = snapshotView.flatMap { $0.center.y - point.y } ?? 0
        reorderState = .Reordering(
            sourceRow: sourceRow,
            destinationRow: sourceRow,
            snapshotOffset: snapshotOffset
        )

        delegate?.tableViewDidBeginReordering?(tableView)
    }
    
    internal func updateReorderWithTouchPoint(point: CGPoint) {
        guard case let .Reordering(_, _, snapshotOffset) = reorderState else { return }
        guard let snapshotView = snapshotView else { return }
        
        snapshotView.center.y = point.y + snapshotOffset
        updateDestinationRow()
    }
    
    internal func endReorder() {
        guard case let .Reordering(_, destinationRow, _) = reorderState else { return }
        guard let tableView = tableView else { return }
        
        reorderState = .Ready(snapshotRow: destinationRow)
        
        let rect = tableView.rectForRowAtIndexPath(destinationRow)
        let rectCenter = CGPoint(x: rect.midX, y: rect.midY)
        
        // If no values actually change inside a UIView animation block, the completion handler is called immediately.
        // This is a workaround for that case.
        if snapshotView?.center == rectCenter {
            snapshotView?.center.y += 0.1
        }
        
        UIView.animateWithDuration(animationDuration, animations: {
            self.snapshotView?.center = CGPoint(x: rect.midX, y: rect.midY)
        }, completion: { finished in
            if case let .Ready(snapshotRow) = self.reorderState {
                if let snapshotRow = snapshotRow {
                    self.reorderState = .Ready(snapshotRow: nil)
                    UIView.performWithoutAnimation {
                        tableView.reloadRowsAtIndexPaths([snapshotRow], withRowAnimation: .None)
                    }
                    self.removeSnapshotView()
                }
            }
        })
        animateSnapshotViewOut()
        clearAutoScrollDisplayLink()
        
        delegate?.tableViewDidFinishReordering?(tableView)
    }
    
    // MARK: - Spacer cell
    
    /**
     Returns a `UITableViewCell` if the table view should display a spacer cell at the given index path.
     
     Call this method at the beginning of your `tableView(_:cellForRowAtIndexPath:)`, like so:
     ```
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
         if let spacer = tableView.reorder.spacerCellForIndexPath(indexPath) {
             return spacer
         }
     
         // ...
     }
     ```
     - Parameter indexPath: The index path
     - Returns: An optional `UITableViewCell`.
     */
    public func spacerCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell? {
        if case let .Reordering(_, destinationRow, _) = reorderState where indexPath == destinationRow {
            return spacerCell()
        } else if case let .Ready(snapshotRow) = reorderState where indexPath == snapshotRow {
            return spacerCell()
        }
        return nil
    }
    
    private func spacerCell() -> UITableViewCell? {
        guard let snapshotView = snapshotView else { return nil }
        
        let cell = UITableViewCell()
        let height = snapshotView.bounds.height
        NSLayoutConstraint(item: cell, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: height).active = true
        
        let hideCell: Bool
        switch spacerCellStyle {
        case .Automatic:
            hideCell = tableView?.style == .Grouped
        case .Hidden:
            hideCell = true
        case .Transparent:
            hideCell = false
        }
        
        if hideCell {
            cell.hidden = true
        } else {
            cell.backgroundColor = .clearColor()
        }
        
        return cell
    }
    
}
