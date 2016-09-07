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
    
    internal func createSnapshotViewForCellAtIndexPath(indexPath: NSIndexPath) {
        removeSnapshotView()
        self.tableView?.reloadData()
        
        guard let cell = tableView?.cellForRowAtIndexPath(indexPath) else { return }
        
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
    
    internal func removeSnapshotView() {
        snapshotView?.removeFromSuperview()
        snapshotView = nil
    }
    
    internal func animateSnapshotViewIn() {
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
    
    internal func animateSnapshotViewOut() {
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

}
