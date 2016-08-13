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
import QuartzCore

public class ReorderController: NSObject {
    
    private let autoScrollThreshold: CGFloat = 30
    private let autoScrollMinVelocity: CGFloat = 60
    private let autoScrollMaxVelocity: CGFloat = 280
    
    private enum ReorderState {
        case Ready(snapshotRow: NSIndexPath?)
        case Reordering(sourceRow: NSIndexPath, destinationRow: NSIndexPath, snapshotOffset: CGFloat)
    }
    
    private weak var tableView: UITableView?
    
    private var reorderState: ReorderState = .Ready(snapshotRow: nil)
    private var snapshotView: UIView? = nil
    
    private var autoScrollDisplayLink: CADisplayLink?
    private var lastTimeStamp: CFTimeInterval?
    
    private lazy var reorderGestureRecognizer: UILongPressGestureRecognizer = {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleReorderGesture))
        gestureRecognizer.delegate = self
        gestureRecognizer.minimumPressDuration = 0.3
        return gestureRecognizer
    }()
    
    public weak var delegate: TableViewReorderDelegate?
    
    public var longPressDuration: NSTimeInterval = 0.3
    public var animationDuration: NSTimeInterval = 0.2
    public var cellOpacity: CGFloat = 1
    public var cellScale: CGFloat = 1
    public var shadowColor = UIColor.blackColor()
    public var shadowOpacity: CGFloat = 0.3
    public var shadowRadius: CGFloat = 10
    public var shadowOffset = CGSize(width: 0, height: 3)
    public var spacerCellStyle: ReorderSpacerCellStyle = .Automatic
    
    // MARK: - Lifecycle
    
    init(tableView: UITableView) {
        super.init()
        
        self.tableView = tableView
        tableView.addGestureRecognizer(reorderGestureRecognizer)
        
        reorderState = .Ready(snapshotRow: nil)
    }
    
    // MARK: - Gesture recognizer
    
    @objc private func handleReorderGesture(gestureRecognizer: UIGestureRecognizer) {
        let gestureLocation = gestureRecognizer.locationInView(tableView)
        
        switch gestureRecognizer.state {
        case .Began:
            beginReorderWithTouchPoint(gestureLocation)
            
        case .Changed:
            updateReorderWithTouchPoint(gestureLocation)
            
        case .Ended, .Cancelled, .Failed, .Possible:
            endReorder()
        }
    }
    
    // MARK: - Reordering
    
    private func beginReorderWithTouchPoint(point: CGPoint) {
        guard case .Ready = reorderState else { return }
        guard let tableView = tableView, sourceRow = tableView.indexPathForRowAtPoint(point) else { return }
        
        guard delegate?.tableView?(tableView, canReorderRowAtIndexPath: sourceRow) != false else { return }
        
        createSnapshotViewForCellAtIndexPath(sourceRow)
        animateSnapshotViewIn()
        activateAutoScrollDisplayLink()
        
        let snapshotOffset = snapshotView.flatMap { $0.center.y - point.y } ?? 0
        reorderState = .Reordering(
            sourceRow: sourceRow,
            destinationRow: sourceRow,
            snapshotOffset: snapshotOffset
        )
        
        UIView.performWithoutAnimation {
            tableView.reloadRowsAtIndexPaths([sourceRow], withRowAnimation: .None)
        }
        
        delegate?.tableViewDidBeginReordering?(tableView)
    }
    
    private func updateReorderWithTouchPoint(point: CGPoint) {
        guard case let .Reordering(_, _, snapshotOffset) = reorderState else { return }
        guard let snapshotView = snapshotView else { return }
        
        snapshotView.center.y = point.y + snapshotOffset
        updateDestinationRow()
    }
    
    private func endReorder() {
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
    
    // MARK: - Destination row
    
    private func updateDestinationRow() {
        guard case let .Reordering(sourceRow, destinationRow, snapshotOffset) = reorderState else { return }
        guard let tableView = tableView else { return }
        
        guard let newDestinationRow = newDestinationRow() where newDestinationRow != destinationRow else { return }
        
        reorderState = .Reordering(
            sourceRow: sourceRow,
            destinationRow: newDestinationRow,
            snapshotOffset: snapshotOffset
        )
        delegate?.tableView(tableView, reorderRowAtIndexPath: destinationRow, toIndexPath: newDestinationRow)
        
        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths([destinationRow], withRowAnimation: .Fade)
        tableView.insertRowsAtIndexPaths([newDestinationRow], withRowAnimation: .Fade)
        tableView.endUpdates()
    }
    
    private func newDestinationRow() -> NSIndexPath? {
        guard case let .Reordering(_, destinationRow, _) = reorderState else { return nil }
        guard let tableView = tableView, snapshotView = snapshotView else { return nil }
        
        let rowSnapDistances = tableView.indexPathsForVisibleRows?.map { path -> (path: NSIndexPath, distance: CGFloat) in
            let rect = tableView.rectForRowAtIndexPath(path)
            
            if destinationRow.compare(path) == .OrderedAscending {
                return (path, abs(snapshotView.frame.maxY - rect.maxY))
            } else {
                return (path, abs(snapshotView.frame.minY - rect.minY))
            }
        } ?? []
        
        let sectionSnapDistances = (0..<tableView.numberOfSections).flatMap { section -> (path: NSIndexPath, distance: CGFloat)? in
            if section > destinationRow.section {
                let rect = tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: section))
                let path = NSIndexPath(forRow: 0, inSection: section)
                
                return (path, abs(snapshotView.frame.maxY - rect.minY))
            } else if section < destinationRow.section {
                let rowsInSection = tableView.numberOfRowsInSection(section)
                let rect = tableView.rectForRowAtIndexPath(NSIndexPath(forRow: rowsInSection - 1, inSection: section))
                let path = NSIndexPath(forRow: rowsInSection, inSection: section)
                
                return (path, abs(snapshotView.frame.minY - rect.maxY))
            } else {
                return nil
            }
        }
        
        let snapDistances = (rowSnapDistances + sectionSnapDistances).filter { delegate?.tableView?(tableView, canReorderRowAtIndexPath: $0.path) != false }
        return snapDistances.minElement({ $0.distance < $1.distance })?.path
    }
    
    // MARK: - Snapshot view
    
    private func createSnapshotViewForCellAtIndexPath(indexPath: NSIndexPath) {
        guard let cell = tableView?.cellForRowAtIndexPath(indexPath) else { return }
        
        removeSnapshotView()
        tableView?.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        
        UIGraphicsBeginImageContextWithOptions(cell.bounds.size, false, 0)
        cell.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let snapshotView = UIImageView(image: image)
        snapshotView.frame = cell.frame
        
        snapshotView.layer.masksToBounds = false
        snapshotView.layer.opacity = Float(cellOpacity)
        snapshotView.layer.transform = CATransform3DMakeScale(cellScale, cellScale, 1)
        
        snapshotView.layer.shadowColor = shadowColor.CGColor
        snapshotView.layer.shadowOpacity = Float(shadowOpacity)
        snapshotView.layer.shadowRadius = shadowRadius
        snapshotView.layer.shadowOffset = shadowOffset
        
        tableView?.addSubview(snapshotView)
        self.snapshotView = snapshotView
    }
    
    private func removeSnapshotView() {
        snapshotView?.removeFromSuperview()
        snapshotView = nil
    }
    
    private func animateSnapshotViewIn() {
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = cellOpacity
        opacityAnimation.duration = animationDuration
        
        let shadowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        shadowAnimation.fromValue = 0
        shadowAnimation.toValue = shadowOpacity
        shadowAnimation.duration = animationDuration
        
        let transformAnimation = CABasicAnimation(keyPath: "transform.scale")
        transformAnimation.fromValue = 1
        transformAnimation.toValue = cellScale
        transformAnimation.duration = animationDuration
        transformAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        snapshotView?.layer.addAnimation(opacityAnimation, forKey: nil)
        snapshotView?.layer.addAnimation(shadowAnimation, forKey: nil)
        snapshotView?.layer.addAnimation(transformAnimation, forKey: nil)
    }
    
    private func animateSnapshotViewOut() {
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = cellOpacity
        opacityAnimation.toValue = 1
        opacityAnimation.duration = animationDuration
        
        let shadowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        shadowAnimation.fromValue = shadowOpacity
        shadowAnimation.toValue = 0
        shadowAnimation.duration = animationDuration
        
        let transformAnimation = CABasicAnimation(keyPath: "transform.scale")
        transformAnimation.fromValue = cellScale
        transformAnimation.toValue = 1
        transformAnimation.duration = animationDuration
        transformAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        snapshotView?.layer.addAnimation(opacityAnimation, forKey: nil)
        snapshotView?.layer.addAnimation(shadowAnimation, forKey: nil)
        snapshotView?.layer.addAnimation(transformAnimation, forKey: nil)
        
        snapshotView?.layer.opacity = 1
        snapshotView?.layer.shadowOpacity = 0
        snapshotView?.layer.transform = CATransform3DIdentity
    }
    
    // MARK: - Spacer cell
    
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
    
    public func spacerCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell? {
        if case let .Reordering(_, destinationRow, _) = reorderState where indexPath == destinationRow {
            return spacerCell()
        } else if case let .Ready(snapshotRow) = reorderState where indexPath == snapshotRow {
            return spacerCell()
        }
        return nil
    }
    
    // MARK: - Auto scrolling
    
    private func activateAutoScrollDisplayLink() {
        autoScrollDisplayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLinkUpdate))
        autoScrollDisplayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        lastTimeStamp = nil
    }
    
    private func clearAutoScrollDisplayLink() {
        autoScrollDisplayLink?.invalidate()
        autoScrollDisplayLink = nil
        lastTimeStamp = nil
    }
    
    @objc private func handleDisplayLinkUpdate(displayLink: CADisplayLink) {
        guard let tableView = tableView, snapshotView = snapshotView else { return }
        
        if let lastTimeStamp = lastTimeStamp {
            let scrollVelocity = autoScrollVelocity()
            
            if scrollVelocity != 0 {
                let elapsedTime = displayLink.timestamp - lastTimeStamp
                let scrollDelta = CGFloat(elapsedTime) * scrollVelocity
                
                let oldOffset = tableView.contentOffset
                tableView.setContentOffset(CGPoint(x: oldOffset.x, y: oldOffset.y + CGFloat(scrollDelta)), animated: false)
                
                tableView.contentOffset.y = min(tableView.contentOffset.y, tableView.contentSize.height + tableView.contentInset.bottom - tableView.frame.height)
                tableView.contentOffset.y = max(tableView.contentOffset.y, -tableView.contentInset.top)
                
                let actualScrollDistance = tableView.contentOffset.y - oldOffset.y
                snapshotView.frame.origin.y += actualScrollDistance
                
                updateDestinationRow()
            }
        }
        lastTimeStamp = displayLink.timestamp
    }
    
    private func autoScrollVelocity() -> CGFloat {
        guard let tableView = tableView, snapshotView = snapshotView else { return 0 }
        
        let scrollBounds = UIEdgeInsetsInsetRect(tableView.bounds, tableView.contentInset)
        let distanceToTop = max(snapshotView.frame.minY - scrollBounds.minY, 0)
        let distanceToBottom = max(scrollBounds.maxY - snapshotView.frame.maxY, 0)
        
        if distanceToTop < autoScrollThreshold {
            return mapValue(distanceToTop, inRangeWithMin: autoScrollThreshold, max: 0, toRangeWithMin: -autoScrollMinVelocity, max: -autoScrollMaxVelocity)
        }
        if distanceToBottom < autoScrollThreshold {
            return mapValue(distanceToBottom, inRangeWithMin: autoScrollThreshold, max: 0, toRangeWithMin: autoScrollMinVelocity, max: autoScrollMaxVelocity)
        }
        return 0
    }
    
}

// MARK: - Gesture recognizer delegate

extension ReorderController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let tableView = tableView else { return false }
        
        let gestureLocation = gestureRecognizer.locationInView(tableView)
        guard let indexPath = tableView.indexPathForRowAtPoint(gestureLocation) else { return false }
        
        return delegate?.tableView?(tableView, canReorderRowAtIndexPath: indexPath) ?? true
    }
    
}

// MARK: - Utility

private func mapValue(value: CGFloat, inRangeWithMin minA: CGFloat, max maxA: CGFloat, toRangeWithMin minB: CGFloat, max maxB: CGFloat) -> CGFloat {
    return (value - minA) * (maxB - minB) / (maxA - minA) + minB
}
