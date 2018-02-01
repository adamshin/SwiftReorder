//
//  ReorderController+ProxyViews.swift
//  SwiftReorder
//
//  Created by Adam Shin on 1/31/18.
//  Copyright © 2018 Adam Shin. All rights reserved.
//

import UIKit

extension ReorderController {
    
    // MARK: - Public Interface
    
    public func prepare(_ cell: UITableViewCell, at indexPath: IndexPath) {
        if let reorderContext = reorderContext {
            
            if indexPath != reorderContext.sourceRow, let selectedCellProxy = selectedCellProxy {
                addProxyViewForCell(cell, at: indexPath, below: selectedCellProxy)
            }
            hideCell(cell)
            
        } else {
            
            unhideCell(cell)
            
        }
    }
    
    // MARK: - Cell Hiding
    
    func hideVisibleCells() {
        for cell in tableView?.visibleCells ?? [] {
            hideCell(cell)
        }
    }
    
    func unhideVisibleCells() {
        for cell in tableView?.visibleCells ?? [] {
            hideCell(cell)
        }
    }
    
    func hideCell(_ cell: UITableViewCell) {
        cell.isHidden = true
    }
    
    func unhideCell(_ cell: UITableViewCell) {
        cell.isHidden = false
    }
    
    // MARK: - Proxy Views
    
    func proxyViewForCell(_ cell: UITableViewCell) -> UIView {
        let image = ReorderController.snapshotImage(for: cell)
        
        let proxy = UIImageView(image: image)
        proxy.frame = cell.frame
        
        return proxy
    }
    
    func addProxyViewForCell(_ cell: UITableViewCell, at indexPath: IndexPath, below topView: UIView) {
        if let oldProxy = cellProxies[indexPath] {
            oldProxy.removeFromSuperview()
        }
        
        let proxy = proxyViewForCell(cell)
        cellProxies[indexPath] = proxy
        
        tableView?.insertSubview(proxy, belowSubview: topView)
    }
    
    // TODO: We're only going to allow scrolling when it's edge scrolling.
    // Maybe we don't need to jump through as many hoops (checking constantly for offscreen cells)
    // because we'll control the scrolling manually.
    func removeProxyViewsForOffscreenCells() {
        let onscreenCellIndexPaths = tableView?.indexPathsForVisibleRows ?? []
        var onscreenCellProxies = [IndexPath: UIView]()
        
        for (indexPath, proxy) in cellProxies {
            if onscreenCellIndexPaths.contains(indexPath) {
                onscreenCellProxies[indexPath] = proxy
            } else {
                proxy.removeFromSuperview()
            }
        }
        
        cellProxies = onscreenCellProxies
    }
    
    // MARK: - Snapshot Image
    
    private class func snapshotImage(for view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
}
