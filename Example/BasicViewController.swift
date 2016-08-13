//
//  BasicViewController.swift
//  SwiftReorder
//
//  Created by Adam Shin on 5/13/16.
//  Copyright © 2016 Adam Shin. All rights reserved.
//

import UIKit

class BasicViewController: UITableViewController {
    
    var items = (1...10).map { "Item \($0)" }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(style: .Plain)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Basic"

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.allowsSelection = false
        tableView.reorderDelegate = self
    }

}

extension BasicViewController {
    
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

extension BasicViewController: TableViewReorderDelegate {

    func tableView(tableView: UITableView, reorderRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let item = items[sourceIndexPath.row]
        items.removeAtIndex(sourceIndexPath.row)
        items.insert(item, atIndex: destinationIndexPath.row)
    }
    
}
