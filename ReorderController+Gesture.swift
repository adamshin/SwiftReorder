//
//  ReorderController+Gesture.swift
//  SwiftReorder
//
//  Created by Adam Shin on 1/31/18.
//  Copyright © 2018 Adam Shin. All rights reserved.
//

import UIKit

extension ReorderController {
    
    @objc func handleReorderGesture(_ gestureRecognizer: UIGestureRecognizer) {
        guard let tableView = tableView else { return }
        
        let touchPosition = gestureRecognizer.location(in: tableView)
        
        switch gestureRecognizer.state {
        case .began:
            beginReorder(touchPosition: touchPosition)
            
        case .changed:
            updateReorder(touchPosition: touchPosition)
            
        case .ended, .cancelled, .failed, .possible:
            endReorder()
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

