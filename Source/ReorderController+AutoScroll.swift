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

private func mapValue(_ value: CGFloat, in rangeA: (lower: CGFloat, upper: CGFloat), to rangeB: (lower: CGFloat, upper: CGFloat)) -> CGFloat {
    let rangeASize = rangeA.upper - rangeA.lower
    let rangeBSize = rangeB.upper - rangeB.lower
    
    return rangeB.lower + (rangeBSize * (value - rangeA.lower) / rangeASize)
}

private func clamp(_ value: CGFloat, to range: (lower: CGFloat, upper: CGFloat)) -> CGFloat {
    return min(max(value, range.lower), range.upper)
}

extension ReorderController {
    
    func autoScrollVelocity() -> CGFloat {
        guard isAutoScrollEnabled,
            let tableView = tableView,
            let selectedCellProxy = selectedCellProxy
        else { return 0 }
        
        let proxyRect = tableView.convert(selectedCellProxy.frame, to: tableView.superview)
        
        let safeAreaFrame: CGRect
        if #available(iOS 11, *) {
            safeAreaFrame = UIEdgeInsetsInsetRect(tableView.frame, tableView.safeAreaInsets)
        } else {
            safeAreaFrame = UIEdgeInsetsInsetRect(tableView.frame, tableView.scrollIndicatorInsets)
        }
        
        let distanceToTop = max(proxyRect.minY - safeAreaFrame.minY, 0)
        let distanceToBottom = max(safeAreaFrame.maxY - proxyRect.maxY, 0)
        
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
        guard let tableView = tableView, let selectedCellProxy = selectedCellProxy else { return }
        
        if let lastAutoScrollTimeStamp = lastAutoScrollTimeStamp {
            let scrollVelocity = autoScrollVelocity()
            
            if scrollVelocity != 0 {
                // Calculate scroll delta
                let elapsedTime = displayLink.timestamp - lastAutoScrollTimeStamp
                let scrollDelta = CGFloat(elapsedTime) * scrollVelocity
                
                // Calculate content offset bounds
                let contentInset: UIEdgeInsets
                if #available(iOS 11, *) {
                    contentInset = tableView.adjustedContentInset
                } else {
                    contentInset = tableView.contentInset
                }
                
                let minContentOffset = -contentInset.top
                let maxContentOffset = tableView.contentSize.height - tableView.bounds.height + contentInset.bottom
                
                // Calculate new content offset
                let oldContentOffsetY = tableView.contentOffset.y
                let newContentOffsetY = clamp(oldContentOffsetY + scrollDelta, to: (minContentOffset, maxContentOffset))
                
                // Scroll table view, maintaining position of selected cell proxy
                tableView.contentOffset.y = newContentOffsetY
                
                let clampedScrollDelta = newContentOffsetY - oldContentOffsetY
                selectedCellProxy.frame.origin.y += clampedScrollDelta
                
                // Recalculate destination row
                updateDestinationRow()
            }
        }
        lastAutoScrollTimeStamp = displayLink.timestamp
    }
    
}
