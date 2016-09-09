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
    
    internal func updateDestinationRow() {
        guard case let .reordering(sourceRow, destinationRow, snapshotOffset) = reorderState else { return }
        guard let tableView = tableView else { return }
        
        guard let newDestinationRow = newDestinationRow() , newDestinationRow != destinationRow else { return }
        
        reorderState = .reordering(
            sourceRow: sourceRow,
            destinationRow: newDestinationRow,
            snapshotOffset: snapshotOffset
        )
        delegate?.tableView(tableView, reorderRowAt: destinationRow, to: newDestinationRow)
        
        tableView.beginUpdates()
        tableView.deleteRows(at: [destinationRow], with: .fade)
        tableView.insertRows(at: [newDestinationRow], with: .fade)
        tableView.endUpdates()
    }
    
    internal func newDestinationRow() -> IndexPath? {
        guard case let .reordering(_, destinationRow, _) = reorderState else { return nil }
        guard let tableView = tableView, let snapshotView = snapshotView else { return nil }
        
        let snapshotFrame = CGRect(center: snapshotView.center, size: snapshotView.bounds.size)
        
        let rowSnapDistances = tableView.indexPathsForVisibleRows?.map { path -> (path: IndexPath, distance: CGFloat) in
            let rect = tableView.rectForRow(at: path)
            
            if (destinationRow as NSIndexPath).compare(path) == .orderedAscending {
                return (path, abs(snapshotFrame.maxY - rect.maxY))
            } else {
                return (path, abs(snapshotFrame.minY - rect.minY))
            }
        } ?? []
        
        let sectionSnapDistances = (0..<tableView.numberOfSections).flatMap { section -> (path: IndexPath, distance: CGFloat)? in
            let rowsInSection = tableView.numberOfRows(inSection: section)
            
            if section > (destinationRow as NSIndexPath).section {
                let rect: CGRect
                if rowsInSection == 0 {
                    rect = rectForEmptySection(section)
                } else {
                    rect = tableView.rectForRow(at: IndexPath(row: 0, section: section))
                }
                
                let path = IndexPath(row: 0, section: section)
                return (path, abs(snapshotFrame.maxY - rect.minY))
            }
            else if section < (destinationRow as NSIndexPath).section {
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
        
        let snapDistances = (rowSnapDistances + sectionSnapDistances).filter { delegate?.tableView(tableView, canReorderRowAt: $0.path) != false }
        return snapDistances.min(by: { $0.distance < $1.distance })?.path
    }
    
    internal func rectForEmptySection(_ section: Int) -> CGRect {
        guard let tableView = tableView else { return .zero }
        
        let sectionRect = tableView.rectForHeader(inSection: section)
        return UIEdgeInsetsInsetRect(sectionRect, UIEdgeInsets(top: sectionRect.height, left: 0, bottom: 0, right: 0))
    }
    
}
