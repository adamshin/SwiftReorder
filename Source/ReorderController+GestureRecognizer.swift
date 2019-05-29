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

    @objc internal func handleReorderGesture(_ gestureRecognizer: UIGestureRecognizer) {
        guard let superview = tableView?.superview else { return }
        
        let touchPosition = gestureRecognizer.location(in: superview)
        
        switch gestureRecognizer.state {
        case .began:
            beginReorder(touchPosition: touchPosition)
            
        case .changed:
            updateReorder(touchPosition: touchPosition, gestureRecognizer: gestureRecognizer)
            
        case .ended, .cancelled, .failed, .possible:
            endReorder(gestureRecognizer: gestureRecognizer)
        @unknown default: break
        }
    }
    
}

extension ReorderController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let tableView = tableView else { return false }
        
        let gestureLocation = gestureRecognizer.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: gestureLocation) else { return false }
        
        return delegate?.tableView(tableView, canReorderRowAt: indexPath) ?? true
    }
    
}
