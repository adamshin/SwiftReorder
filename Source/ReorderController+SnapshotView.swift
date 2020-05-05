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
    
    func createSnapshotViewForCell(at indexPath: IndexPath) {
        guard let tableView = tableView, let superview = tableView.superview else { return }
        
        removeSnapshotView()
        tableView.reloadRows(at: [indexPath], with: .none)
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.subviews.forEach { $0.layer.masksToBounds = true }
        let cellFrame = tableView.convert(cell.frame, to: superview)
        
        UIGraphicsBeginImageContextWithOptions(cell.bounds.size, false, 0)
        cell.layer.render(in: UIGraphicsGetCurrentContext()!)
        let cellImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let view = UIImageView(image: cellImage)
        view.frame = cellFrame
        
        view.layer.masksToBounds = false
        view.layer.opacity = Float(cellOpacity)
        view.layer.transform = CATransform3DMakeScale(cellScale, cellScale, 1)
        
        view.layer.shadowColor = shadowColor.cgColor
        view.layer.shadowOpacity = Float(shadowOpacity)
        view.layer.shadowRadius = shadowRadius
        view.layer.shadowOffset = shadowOffset
        
        superview.addSubview(view)
        snapshotView = view
    }
    
    func removeSnapshotView() {
        snapshotView?.removeFromSuperview()
        snapshotView = nil
    }
    
    func updateSnapshotViewPosition() {
        guard case .reordering(let context) = reorderState, let tableView = tableView else { return }
        
        var newCenterY = context.touchPosition.y + context.snapshotOffset
        
        let safeAreaFrame: CGRect
        if #available(iOS 11, *) {
            safeAreaFrame = tableView.frame.inset(by: tableView.safeAreaInsets)
        } else {
            safeAreaFrame = tableView.frame.inset(by: tableView.scrollIndicatorInsets)
        }
        
        newCenterY = min(newCenterY, safeAreaFrame.maxY)
        newCenterY = max(newCenterY, safeAreaFrame.minY)
        
        snapshotView?.center.y = newCenterY
    }
    
    func animateSnapshotViewIn() {
        guard let snapshotView = snapshotView else { return }
        
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
        transformAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        snapshotView.layer.add(opacityAnimation, forKey: nil)
        snapshotView.layer.add(shadowAnimation, forKey: nil)
        snapshotView.layer.add(transformAnimation, forKey: nil)
    }
    
    func animateSnapshotViewOut() {
        guard let snapshotView = snapshotView else { return }
        
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
        transformAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        snapshotView.layer.add(opacityAnimation, forKey: nil)
        snapshotView.layer.add(shadowAnimation, forKey: nil)
        snapshotView.layer.add(transformAnimation, forKey: nil)
        
        snapshotView.layer.opacity = 1
        snapshotView.layer.shadowOpacity = 0
        snapshotView.layer.transform = CATransform3DIdentity
    }

}
