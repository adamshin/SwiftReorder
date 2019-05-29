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
    case automatic
    case hidden
    case transparent
}

// MARK: - TableViewReorderDelegate

/**
 The delegate of a `ReorderController` must adopt the `TableViewReorderDelegate` protocol. This protocol defines methods for handling the reordering of rows.
 */
public protocol TableViewReorderDelegate: class {
    
    /**
     Tells the delegate that the user has moved a row from one location to another. Use this method to update your data source.
     - Parameter tableView: The table view requesting this action.
     - Parameter sourceIndexPath: The index path of the row to be moved.
     - Parameter destinationIndexPath: The index path of the row's new location.
     */
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    
    /**
     Asks the reorder delegate whether a given row can be moved.
     - Parameter tableView: The table view requesting this information.
     - Parameter indexPath: The index path of a row.
     */
    func tableView(_ tableView: UITableView, canReorderRowAt indexPath: IndexPath) -> Bool
    
    /**
     When attempting to move a row from a sourceIndexPath to a proposedDestinationIndexPath, asks the reorder delegate what the actual targetIndexPath should be. This allows the reorder delegate to selectively allow or modify reordering between sections or groups of rows, for example.
     - Parameter tableView: The table view requesting this information.
     - Parameter sourceIndexPath: The original index path of the row to be moved.
     - Parameter proposedDestinationIndexPath: The potential index path of the row's new location.
     */
    func tableView(_ tableView: UITableView, targetIndexPathForReorderFromRowAt sourceIndexPath: IndexPath, to proposedDestinationIndexPath: IndexPath) -> IndexPath

    /**
     Tells the delegate that the user has begun reordering a row.
     - Parameter tableView: The table view providing this information.
     - Parameter indexPath: The index path of the selected row.
     */
    func tableViewDidBeginReordering(_ tableView: UITableView, at indexPath: IndexPath)
    
    /**
     Tells the delegate that the user has finished reordering and that the row was moved.
     - Parameter tableView: The table view providing this information.
     - Parameter initialSourceIndexPath: The initial index path of the selected row, before reordering began.
     - Parameter finalDestinationIndexPath: The final index path of the selected row.
     */
    func tableViewDidFinishReordering(_ tableView: UITableView, from initialSourceIndexPath: IndexPath, to finalDestinationIndexPath: IndexPath)
    
    /**
     Tells the delegate that the user has finished reordering and that the row was deleted.
     - Parameter tableView: The table view providing this information.
     - Parameter initialSourceIndexPath: The initial index path of the selected row, before reordering began.
     */
    func tableViewDidFinishReorderingWithDeletion(_ tableView: UITableView, from initialSourceIndexPath: IndexPath)
    
    /**
     Tells the delegate that the user has moved the cell
     - Parameter tableView: The table view providing this information.
     - Parameter gestureRecognizer: The user gesture that moved the cell.
     */
    func tableViewDidMoveCell(_ tableView: UITableView, with gestureRecognizer: UIGestureRecognizer)
    
    /**
     Asks the delegate whether the cell should be deleted
     - Parameter tableView: The table view providing this information.
     - Parameter initialSourceIndexPath: The initial index path of the selected row, before reordering began.
     - Parameter finalDestinationIndexPath: The current index path of the selected row.
     - Parameter gestureRecognizer: The user gesture that moved the cell and has now ended.
     */
    func tableViewShouldRemoveCell(_ tableView: UITableView, from initialSourceIndexPath: IndexPath, to finalDestinationIndexPath: IndexPath, with gestureRecognizer: UIGestureRecognizer) -> Bool
}

public extension TableViewReorderDelegate {
    
    func tableView(_ tableView: UITableView, canReorderRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForReorderFromRowAt sourceIndexPath: IndexPath, to proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return proposedDestinationIndexPath
    }

    func tableViewDidBeginReordering(_ tableView: UITableView, at indexPath: IndexPath) {
    }
    
    func tableViewDidFinishReordering(_ tableView: UITableView, from initialSourceIndexPath: IndexPath, to finalDestinationIndexPath:IndexPath) {
    }
    
    func tableViewDidMoveCell(_ tableView: UITableView, with gestureRecognizer: UIGestureRecognizer) {
    }
    
    func tableViewShouldRemoveCell(_ tableView: UITableView, from initialSourceIndexPath: IndexPath, to finalDestinationIndexPath: IndexPath, with gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func tableViewDidFinishReorderingWithDeletion(_ tableView: UITableView, from initialSourceIndexPath: IndexPath) {
    }
}

// MARK: - ReorderController

/**
 An object that manages drag-and-drop reordering of table view cells.
 */
public class ReorderController: NSObject {
    
    // MARK: - Public interface
    
    /// The delegate of the reorder controller.
    public weak var delegate: TableViewReorderDelegate?
    
    /// Whether reordering is enabled.
    public var isEnabled: Bool = true {
        didSet { reorderGestureRecognizer.isEnabled = isEnabled }
    }
    
    public var longPressDuration: TimeInterval = 0.3 {
        didSet {
            reorderGestureRecognizer.minimumPressDuration = longPressDuration
        }
    }
    
    public var cancelsTouchesInView: Bool = false {
        didSet {
            reorderGestureRecognizer.cancelsTouchesInView = cancelsTouchesInView
        }
    }
    
    /// The duration of the cell selection animation.
    public var animationDuration: TimeInterval = 0.2
    
    /// The opacity of the selected cell.
    public var cellOpacity: CGFloat = 1
    
    /// The scale factor for the selected cell.
    public var cellScale: CGFloat = 1
    
    /// The shadow color for the selected cell.
    public var shadowColor: UIColor = .black
    
    /// The shadow opacity for the selected cell.
    public var shadowOpacity: CGFloat = 0.3
    
    /// The shadow radius for the selected cell.
    public var shadowRadius: CGFloat = 10
    
    /// The shadow offset for the selected cell.
    public var shadowOffset = CGSize(width: 0, height: 3)
    
    /// The spacer cell style.
    public var spacerCellStyle: ReorderSpacerCellStyle = .automatic
    
    /// Whether or not autoscrolling is enabled
    public var autoScrollEnabled = true
    
    /// The view used to represent the cell being reordered
    public internal(set) var snapshotView: UIView? = nil
    
    /**
     Returns a `UITableViewCell` if the table view should display a spacer cell at the given index path.
     
     Call this method at the beginning of your `tableView(_:cellForRowAt:)`, like so:
     ```
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     if let spacer = tableView.reorder.spacerCell(for: indexPath) {
     return spacer
     }
     
         // ...
     }
     ```
     - Parameter indexPath: The index path
     - Returns: An optional `UITableViewCell`.
     */
    public func spacerCell(for indexPath: IndexPath) -> UITableViewCell? {
        if case let .reordering(context) = reorderState, indexPath == context.destinationRow {
            return createSpacerCell()
        } else if case let .ready(snapshotRow) = reorderState, indexPath == snapshotRow {
            return createSpacerCell()
        }
        return nil
    }
    
    // MARK: - Internal state
    
    struct ReorderContext {
        var sourceRow: IndexPath
        var destinationRow: IndexPath
        var snapshotOffset: CGFloat
        var touchPosition: CGPoint
    }
    
    enum ReorderState {
        case ready(snapshotRow: IndexPath?)
        case reordering(context: ReorderContext)
    }
    
    weak var tableView: UITableView?
    
    var reorderState: ReorderState = .ready(snapshotRow: nil)
    
    var autoScrollDisplayLink: CADisplayLink?
    var lastAutoScrollTimeStamp: CFTimeInterval?
    
    lazy var reorderGestureRecognizer: UILongPressGestureRecognizer = {
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
        
        reorderState = .ready(snapshotRow: nil)
    }
    
    // MARK: - Reordering
    
    func beginReorder(touchPosition: CGPoint) {
        guard case .ready = reorderState,
            let delegate = delegate,
            let tableView = tableView,
            let superview = tableView.superview
        else { return }
        
        let tableTouchPosition = superview.convert(touchPosition, to: tableView)
        
        guard let sourceRow = tableView.indexPathForRow(at: tableTouchPosition),
            delegate.tableView(tableView, canReorderRowAt: sourceRow)
        else { return }
        
        createSnapshotViewForCell(at: sourceRow)
        animateSnapshotViewIn()
        activateAutoScrollDisplayLink()
        
        tableView.reloadData()
        
        let snapshotOffset = (snapshotView?.center.y ?? 0) - touchPosition.y
        
        let context = ReorderContext(
            sourceRow: sourceRow,
            destinationRow: sourceRow,
            snapshotOffset: snapshotOffset,
            touchPosition: touchPosition
        )
        reorderState = .reordering(context: context)

        delegate.tableViewDidBeginReordering(tableView, at: sourceRow)
    }
    
    func updateReorder(touchPosition: CGPoint, gestureRecognizer: UIGestureRecognizer) {
        guard case .reordering(let context) = reorderState, let tableView = tableView else { return }
        
        var newContext = context
        newContext.touchPosition = touchPosition
        reorderState = .reordering(context: newContext)
        
        updateSnapshotViewPosition()
        updateDestinationRow()
        
        delegate?.tableViewDidMoveCell(tableView, with: gestureRecognizer)
    }
    
    func endReorder(gestureRecognizer: UIGestureRecognizer) {
        guard case .reordering(let context) = reorderState,
            let tableView = tableView,
            let superview = tableView.superview
        else { return }
        
        reorderState = .ready(snapshotRow: context.destinationRow)
        
        let cellRectInTableView = tableView.rectForRow(at: context.destinationRow)
        let cellRect = tableView.convert(cellRectInTableView, to: superview)
        let cellRectCenter = CGPoint(x: cellRect.midX, y: cellRect.midY)
        
        // If no values change inside a UIView animation block, the completion handler is called immediately.
        // This is a workaround for that case.
        if snapshotView?.center == cellRectCenter {
            snapshotView?.center.y += 0.1
        }
        
        guard delegate?.tableViewShouldRemoveCell(
            tableView,
            from: context.sourceRow,
            to: context.destinationRow,
            with: gestureRecognizer
            ) != true else {
                removeSnapshotView()
                clearAutoScrollDisplayLink()
                reorderState = .ready(snapshotRow: nil)
                
                UIView.performWithoutAnimation {
                    tableView.deleteRows(at: [context.destinationRow], with: .none)
                }
                return
        }
        
        UIView.animate(withDuration: animationDuration,
                       animations: {
                        self.snapshotView?.center = CGPoint(x: cellRect.midX, y: cellRect.midY)
        },
                       completion: { _ in
                        if case let .ready(snapshotRow) = self.reorderState, let row = snapshotRow {
                            self.reorderState = .ready(snapshotRow: nil)
                            
                            if let rowCount = tableView.dataSource?.tableView(tableView, numberOfRowsInSection: row.section),
                                rowCount > row.row {
                                // else the row has been removed during the animation and calling
                                // the following would crash
                                UIView.performWithoutAnimation {
                                    tableView.reloadRows(at: [row], with: .none)
                                }
                            }
                            
                            self.removeSnapshotView()
                        }
        }
        )
        animateSnapshotViewOut()
        clearAutoScrollDisplayLink()
        
        delegate?.tableViewDidFinishReordering(tableView, from: context.sourceRow, to: context.destinationRow)
    }
    
    // MARK: - Spacer cell
    
    private func createSpacerCell() -> UITableViewCell? {
        guard let snapshotView = snapshotView else { return nil }
        
        let cell = UITableViewCell()
        let height = snapshotView.bounds.height
        
        NSLayoutConstraint(
            item: cell,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 0,
            constant: height
        ).isActive = true
        
        let hideCell: Bool
        switch spacerCellStyle {
        case .automatic: hideCell = tableView?.style == .grouped
        case .hidden: hideCell = true
        case .transparent: hideCell = false
        }
        
        if hideCell {
            cell.isHidden = true
        } else {
            cell.backgroundColor = .clear
        }
        
        return cell
    }
    
}
