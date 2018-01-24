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

extension CGRect {
    
    init(center: CGPoint, size: CGSize) {
        self.init(x: center.x - (size.width / 2), y: center.y - (size.height / 2), width: size.width, height: size.height)
    }
    
}

extension ReorderController {
    
    func updateDestinationRow() {
        guard case .reordering(let context) = reorderState,
            let tableView = tableView,
            let proposedNewDestinationRow = proposedNewDestinationRow(),
            let newDestinationRow = delegate?.tableView(tableView, targetIndexPathForMoveFromRowAt: context.destinationRow, to: proposedNewDestinationRow),
            newDestinationRow != context.destinationRow
        else { return }
        
        var newContext = context
        newContext.destinationRow = newDestinationRow
        reorderState = .reordering(context: newContext)
        
        delegate?.tableView(tableView, reorderRowAt: context.destinationRow, to: newContext.destinationRow)
        
        tableView.beginUpdates()
        tableView.deleteRows(at: [context.destinationRow], with: .fade)
        tableView.insertRows(at: [newContext.destinationRow], with: .fade)
        tableView.endUpdates()
    }
    
    func proposedNewDestinationRow() -> IndexPath? {
        guard case .reordering(let context) = reorderState,
            let tableView = tableView,
            let superview = tableView.superview,
            let delegate = delegate,
            let snapshotView = snapshotView
        else { return nil }
        
        let snapshotFrameInSuperview = CGRect(center: snapshotView.center, size: snapshotView.bounds.size)
        let snapshotFrame = superview.convert(snapshotFrameInSuperview, to: tableView)
        
        let visibleCells = tableView.visibleCells.filter {
            // Workaround for an iOS 11 bug.
            
            // When adding a row using UITableView.insertRows(...), if the new
            // row's frame will be partially or fully outside the table view's
            // bounds, and the new row is not the first row in the table view,
            // it's inserted without animation.
            
            let cellOverlapsTopBounds = $0.frame.minY < tableView.bounds.minY + 5
            let cellIsFirstCell = tableView.indexPath(for: $0) == IndexPath(row: 0, section: 0)
            
            return !cellOverlapsTopBounds || cellIsFirstCell
        }
        
        let rowSnapDistances = visibleCells.map { cell -> (path: IndexPath, distance: CGFloat) in
            let path = tableView.indexPath(for: cell) ?? IndexPath(row: 0, section: 0)

            if context.destinationRow.compare(path) == .orderedAscending {
                return (path, abs(snapshotFrame.maxY - cell.frame.maxY))
            } else {
                return (path, abs(snapshotFrame.minY - cell.frame.minY))
            }
        }
        
        let sectionIndexes = 0..<tableView.numberOfSections
        let sectionSnapDistances = sectionIndexes.flatMap { section -> (path: IndexPath, distance: CGFloat)? in
            let rowsInSection = tableView.numberOfRows(inSection: section)
            
            if section > context.destinationRow.section {
                let rect: CGRect
                if rowsInSection == 0 {
                    rect = rectForEmptySection(section)
                } else {
                    rect = tableView.rectForRow(at: IndexPath(row: 0, section: section))
                }
                
                let path = IndexPath(row: 0, section: section)
                return (path, abs(snapshotFrame.maxY - rect.minY))
            }
            else if section < context.destinationRow.section {
                let rect: CGRect
                if rowsInSection == 0 {
                    rect = rectForEmptySection(section)
                } else {
                    rect = tableView.rectForRow(at: IndexPath(row: rowsInSection - 1, section: section))
                }
                
                let path = IndexPath(row: rowsInSection, section: section)
                return (path, abs(snapshotFrame.minY - rect.maxY))
            }
            else {
                return nil
            }
        }
        
        let snapDistances = rowSnapDistances + sectionSnapDistances
        return snapDistances.min(by: { $0.distance < $1.distance })?.path
    }
    
    func rectForEmptySection(_ section: Int) -> CGRect {
        guard let tableView = tableView else { return .zero }
        
        let sectionRect = tableView.rectForHeader(inSection: section)
        return UIEdgeInsetsInsetRect(sectionRect, UIEdgeInsets(top: sectionRect.height, left: 0, bottom: 0, right: 0))
    }
    
}
