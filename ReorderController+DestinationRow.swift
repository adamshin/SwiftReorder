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

extension ReorderController {
    
    internal func updateDestinationRow() {
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
    
    internal func newDestinationRow() -> NSIndexPath? {
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
            let rowsInSection = tableView.numberOfRowsInSection(section)
            
            if section > destinationRow.section {
                let rect: CGRect
                if rowsInSection == 0 {
                    rect = rectForEmptySection(section)
                } else {
                    rect = tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: section))
                }
                
                let path = NSIndexPath(forRow: 0, inSection: section)
                return (path, abs(snapshotView.frame.maxY - rect.minY))
            }
            else if section < destinationRow.section {
                let rect: CGRect
                if rowsInSection == 0 {
                    rect = rectForEmptySection(section)
                } else {
                    rect = tableView.rectForRowAtIndexPath(NSIndexPath(forRow: rowsInSection - 1, inSection: section))
                }
                
                let path = NSIndexPath(forRow: rowsInSection, inSection: section)
                return (path, abs(snapshotView.frame.minY - rect.maxY))
            }
            else {
                return nil
            }
        }
        
        let snapDistances = (rowSnapDistances + sectionSnapDistances).filter { delegate?.tableView?(tableView, canReorderRowAtIndexPath: $0.path) != false }
        return snapDistances.minElement({ $0.distance < $1.distance })?.path
    }
    
    internal func rectForEmptySection(section: Int) -> CGRect {
        guard let tableView = tableView else { return .zero }
        
        let sectionRect = tableView.rectForHeaderInSection(section)
        return UIEdgeInsetsInsetRect(sectionRect, UIEdgeInsets(top: sectionRect.height, left: 0, bottom: 0, right: 0))
    }
    
}
