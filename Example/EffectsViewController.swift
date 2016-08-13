//
//  EffectsViewController.swift
//  SwiftReorder
//
//  Created by Adam Shin on 8/11/16.
//  Copyright © 2016 Adam Shin. All rights reserved.
//

import UIKit

class EffectsViewController: UITableViewController {
    
    var items = (1...5).map { "Item \($0)" }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(style: .Grouped)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Effects"
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.allowsSelection = false
        
        tableView.reorderDelegate = self
        tableView.reorderCellOpacity = 0.7
        tableView.reorderCellScale = 1.05
        tableView.reorderShadowOpacity = 0.5
        tableView.reorderShadowRadius = 20
        tableView.reorderShadowOffset = CGSize(width: 0, height: 10)
    }
    
}

extension EffectsViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let spacer = tableView.spacerCellForIndexPath(indexPath) {
            return spacer
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        
        return cell
    }
    
}

extension EffectsViewController: TableViewReorderDelegate {
    
    func tableView(tableView: UITableView, reorderRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let item = items[sourceIndexPath.row]
        items.removeAtIndex(sourceIndexPath.row)
        items.insert(item, atIndex: destinationIndexPath.row)
    }
    
}
