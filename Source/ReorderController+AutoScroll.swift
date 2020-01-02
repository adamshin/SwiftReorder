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

private func mapValue(_ value: CGFloat, inRangeWithMin minA: CGFloat, max maxA: CGFloat, toRangeWithMin minB: CGFloat, max maxB: CGFloat) -> CGFloat {
    return (value - minA) * (maxB - minB) / (maxA - minA) + minB
}

extension ReorderController {
    
    func autoScrollVelocity() -> CGFloat {
        guard let scrollSource = scrollSource, let snapshotView = snapshotView else { return 0 }
        guard autoScrollEnabled else { return 0 }
        
        let safeAreaFrame: CGRect
        if #available(iOS 11, *) {
            safeAreaFrame = scrollSource.frame.inset(by: scrollSource.adjustedContentInset)
        } else {
            safeAreaFrame = scrollSource.frame.inset(by: scrollSource.scrollIndicatorInsets)
        }
        
        let distanceToTop = max(snapshotView.frame.minY - safeAreaFrame.minY, 0)
        let distanceToBottom = max(safeAreaFrame.maxY - snapshotView.frame.maxY, 0)
        
        if distanceToTop < autoScrollThreshold {
            return mapValue(distanceToTop, inRangeWithMin: autoScrollThreshold, max: 0, toRangeWithMin: -autoScrollMinVelocity, max: -autoScrollMaxVelocity)
        }
        if distanceToBottom < autoScrollThreshold {
            return mapValue(distanceToBottom, inRangeWithMin: autoScrollThreshold, max: 0, toRangeWithMin: autoScrollMinVelocity, max: autoScrollMaxVelocity)
        }
        return 0
    }

    func activateAutoScrollDisplayLink() {
        autoScrollDisplayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLinkUpdate))
        autoScrollDisplayLink?.add(to: .main, forMode: .default)
        lastAutoScrollTimeStamp = nil
    }

    func clearAutoScrollDisplayLink() {
        autoScrollDisplayLink?.invalidate()
        autoScrollDisplayLink = nil
        lastAutoScrollTimeStamp = nil
    }

    @objc func handleDisplayLinkUpdate(_ displayLink: CADisplayLink) {
        guard let scrollSource = scrollSource else { return }
        
        if let lastAutoScrollTimeStamp = lastAutoScrollTimeStamp {
            let scrollVelocity = autoScrollVelocity()
            
            if scrollVelocity != 0 {
                let elapsedTime = displayLink.timestamp - lastAutoScrollTimeStamp
                let scrollDelta = CGFloat(elapsedTime) * scrollVelocity
                
                let contentOffset = scrollSource.contentOffset
                scrollSource.contentOffset = CGPoint(x: contentOffset.x, y: contentOffset.y + CGFloat(scrollDelta))
                
                let contentInset: UIEdgeInsets
                if #available(iOS 11, *) {
                    contentInset = scrollSource.adjustedContentInset
                } else {
                    contentInset = scrollSource.contentInset
                }
                
                let minContentOffset = -contentInset.top
                let maxContentOffset = scrollSource.contentSize.height - scrollSource.bounds.height + contentInset.bottom
                
                scrollSource.contentOffset.y = min(scrollSource.contentOffset.y, maxContentOffset)
                scrollSource.contentOffset.y = max(scrollSource.contentOffset.y, minContentOffset)
                
                updateSnapshotViewPosition()
                updateDestinationRow()
            }
        }
        lastAutoScrollTimeStamp = displayLink.timestamp
    }
    
}
