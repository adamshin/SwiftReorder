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

private func mapValue(value: CGFloat, inRangeWithMin minA: CGFloat, max maxA: CGFloat, toRangeWithMin minB: CGFloat, max maxB: CGFloat) -> CGFloat {
    return (value - minA) * (maxB - minB) / (maxA - minA) + minB
}

extension ReorderController {
    
    internal func autoScrollVelocity() -> CGFloat {
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

    internal func activateAutoScrollDisplayLink() {
        autoScrollDisplayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLinkUpdate))
        autoScrollDisplayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        lastAutoScrollTimeStamp = nil
    }

    internal func clearAutoScrollDisplayLink() {
        autoScrollDisplayLink?.invalidate()
        autoScrollDisplayLink = nil
        lastAutoScrollTimeStamp = nil
    }

    @objc internal func handleDisplayLinkUpdate(displayLink: CADisplayLink) {
        guard let tableView = tableView, snapshotView = snapshotView else { return }
        
        if let lastAutoScrollTimeStamp = lastAutoScrollTimeStamp {
            let scrollVelocity = autoScrollVelocity()
            
            if scrollVelocity != 0 {
                let elapsedTime = displayLink.timestamp - lastAutoScrollTimeStamp
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
        lastAutoScrollTimeStamp = displayLink.timestamp
    }
    
}
