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

private let autoScrollThreshold: CGFloat = 30
private let autoScrollMinVelocity: CGFloat = 60
private let autoScrollMaxVelocity: CGFloat = 280

private func mapValue(_ value: CGFloat, in rangeA: (min: CGFloat, max: CGFloat), to rangeB: (min: CGFloat, max: CGFloat)) -> CGFloat {
    let rangeASize = rangeA.max - rangeA.min
    let rangeBSize = rangeB.max - rangeB.min
    
    return rangeB.min + (rangeBSize * (value - rangeA.min) / rangeASize)
}

extension ReorderController {
    
    func autoScrollVelocity() -> CGFloat {
        guard isAutoScrollEnabled,
            let tableView = tableView,
            let cellProxy = selectedCellProxy
        else { return 0 }
        
        let safeAreaFrame: CGRect
        if #available(iOS 11, *) {
            safeAreaFrame = UIEdgeInsetsInsetRect(tableView.frame, tableView.safeAreaInsets)
        } else {
            safeAreaFrame = UIEdgeInsetsInsetRect(tableView.frame, tableView.scrollIndicatorInsets)
        }
        
        let distanceToTop = max(cellProxy.frame.minY - safeAreaFrame.minY, 0)
        let distanceToBottom = max(safeAreaFrame.maxY - cellProxy.frame.maxY, 0)
        
        if distanceToTop < autoScrollThreshold {
            return mapValue(distanceToTop, in: (autoScrollThreshold, 0), to: (-autoScrollMinVelocity, -autoScrollMaxVelocity))
        }
        if distanceToBottom < autoScrollThreshold {
            return mapValue(distanceToBottom, in: (autoScrollThreshold, 0), to: (autoScrollMinVelocity, autoScrollMaxVelocity))
        }
        return 0
    }

    func activateAutoScrollDisplayLink() {
        autoScrollDisplayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLinkUpdate))
        autoScrollDisplayLink?.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        lastAutoScrollTimeStamp = nil
    }

    func clearAutoScrollDisplayLink() {
        autoScrollDisplayLink?.invalidate()
        autoScrollDisplayLink = nil
        lastAutoScrollTimeStamp = nil
    }

    @objc func handleDisplayLinkUpdate(_ displayLink: CADisplayLink) {
        guard let tableView = tableView else { return }
        
        if let lastAutoScrollTimeStamp = lastAutoScrollTimeStamp {
            let scrollVelocity = autoScrollVelocity()
            
            if scrollVelocity != 0 {
                let elapsedTime = displayLink.timestamp - lastAutoScrollTimeStamp
                let scrollDelta = CGFloat(elapsedTime) * scrollVelocity
                
                let contentOffset = tableView.contentOffset
                tableView.contentOffset = CGPoint(x: contentOffset.x, y: contentOffset.y + CGFloat(scrollDelta))
                
                let contentInset: UIEdgeInsets
                if #available(iOS 11, *) {
                    contentInset = tableView.adjustedContentInset
                } else {
                    contentInset = tableView.contentInset
                }
                
                let minContentOffset = -contentInset.top
                let maxContentOffset = tableView.contentSize.height - tableView.bounds.height + contentInset.bottom
                
                tableView.contentOffset.y = min(tableView.contentOffset.y, maxContentOffset)
                tableView.contentOffset.y = max(tableView.contentOffset.y, minContentOffset)
                
                // Don't think we need this here after all, now that the snapshot view is added to the table view's superview.
//                updateSnapshotViewPosition()
                updateDestinationRow()
            }
        }
        lastAutoScrollTimeStamp = displayLink.timestamp
    }
    
}
