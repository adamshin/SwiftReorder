//
//  ReorderController+State.swift
//  SwiftReorder
//
//  Created by Adam Shin on 1/31/18.
//  Copyright © 2018 Adam Shin. All rights reserved.
//

import UIKit

extension ReorderController {
    
    func beginReorder(touchPosition: CGPoint) {
        guard reorderContext == nil else { return }

        guard let tableView = tableView else { return }
        
        guard let sourceRow = tableView.indexPathForRow(at: touchPosition),
            let sourceCell = tableView.cellForRow(at: sourceRow)
        else { return }
        
        // Create proxy view for selected cell
        let selectedCellProxy = proxyViewForCell(sourceCell)
        tableView.addSubview(selectedCellProxy)
        
        self.selectedCellProxy = selectedCellProxy
        selectedCellProxy.layer.masksToBounds = false
        selectedCellProxy.layer.shadowColor = shadowColor.cgColor
        selectedCellProxy.layer.shadowOpacity = Float(shadowOpacity)
        selectedCellProxy.layer.shadowRadius = shadowRadius
        selectedCellProxy.layer.shadowOffset = shadowOffset
        
        let selectedCellTouchOffset = selectedCellProxy.frame.origin.y - touchPosition.y
        
        // Create proxy view for unselected cells
        for indexPath in tableView.indexPathsForVisibleRows ?? [] where indexPath != sourceRow {
            guard let cell = tableView.cellForRow(at: indexPath) else { continue }
            
            addProxyViewForCell(cell, at: indexPath, below: selectedCellProxy)
        }
        
        // Hide the actual cells now
        hideVisibleCells()

        // TODO: Animate selected cell proxy to selected state
        
        // We're officially reordering now
        reorderContext = ReorderContext(
            sourceRow: sourceRow,
            destinationRow: sourceRow,
            selectedCellTouchOffset: selectedCellTouchOffset
        )
        activateAutoScrollDisplayLink()
    }
    
    func updateReorder(touchPosition: CGPoint) {
        guard let reorderContext = reorderContext else { return }
        
        // Update selected cell proxy position
        selectedCellProxy?.frame.origin.y = touchPosition.y + reorderContext.selectedCellTouchOffset
        
        // Update destination row
        updateDestinationRow()
    }
    
    func endReorder() {
        guard let reorderContext = reorderContext, let tableView = tableView else { return }
        
        self.reorderContext = nil
        clearAutoScrollDisplayLink()
        
        // TODO: Animate out
        
        delegate?.tableView(tableView, reorderRowAt: reorderContext.sourceRow, to: reorderContext.destinationRow)
        tableView.reloadData()
        
        // Remove all the proxy views
        selectedCellProxy?.removeFromSuperview()
        selectedCellProxy = nil
        
        cellProxies.values.forEach { $0.removeFromSuperview() }
        cellProxies = [:]
    }
    
}
