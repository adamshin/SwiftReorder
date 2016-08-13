//
//  GroupedViewController.swift
//  SwiftReorder
//
//  Created by Adam Shin on 6/18/16.
//  Copyright © 2016 Adam Shin. All rights reserved.
//

import UIKit

class GroupedViewController: UITableViewController {
    
    var sectionedItems: [(title: String, items: [String])] = [
        ("Foo", (1...5).map { "Foo \($0)" }),
        ("Bar", (1...5).map { "Bar \($0)" })
    ]
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(style: .Grouped)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Grouped"
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.allowsSelection = false
        tableView.reorderDelegate = self
    }
    
}

extension GroupedViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionedItems.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionedItems[section].items.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionedItems[section].title
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let spacer = tableView.spacerCellForIndexPath(indexPath) {
            return spacer
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.backgroundColor = .whiteColor()
        cell.textLabel?.text = sectionedItems[indexPath.section].items[indexPath.row]
        
        return cell
    }
    
}

extension GroupedViewController: TableViewReorderDelegate {
    
    func tableView(tableView: UITableView, reorderRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let item = sectionedItems[sourceIndexPath.section].items[sourceIndexPath.row]
        sectionedItems[sourceIndexPath.section].items.removeAtIndex(sourceIndexPath.row)
        sectionedItems[destinationIndexPath.section].items.insert(item, atIndex: destinationIndexPath.row)
    }
    
}
