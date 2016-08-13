//
//  DynamicHeightViewController.swift
//  SwiftReorder
//
//  Created by Adam Shin on 6/18/16.
//  Copyright © 2016 Adam Shin. All rights reserved.
//

import UIKit

class DynamicHeightCell: UITableViewCell {
    
    let label = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFontOfSize(15)
        label.numberOfLines = 0
        contentView.addSubview(label)
        
        let views = ["label": label]
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[label]-20-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[label]-10-|", options: [], metrics: nil, views: views))
    }
    
}

class DynamicHeightViewController: UITableViewController {
    
    var items = [
        "Here's to the crazy ones.",
        "The misfits. The rebels. The troublemakers. The round pegs in the square holes. The ones who see things differently.",
        "They're not fond of rules. And they have no respect for the status quo.",
        "You can quote them, disagree with them, glorify or vilify them. About the only thing you can't do is ignore them. Because they change things. They push the human race forward.",
        "And while some may see them as the crazy ones, we see genius.",
        "Because the people who are crazy enough to think they can change the world, are the ones who do."
    ]
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(style: .Grouped)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Dynamic Height"
        
        tableView.registerClass(DynamicHeightCell.self, forCellReuseIdentifier: "cell")
        tableView.allowsSelection = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.reorderDelegate = self
    }
    
}

extension DynamicHeightViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let spacer = tableView.spacerCellForIndexPath(indexPath) {
            return spacer
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! DynamicHeightCell
        cell.label.text = items[indexPath.row]
        
        return cell
    }
    
}

extension DynamicHeightViewController: TableViewReorderDelegate {
    
    func tableView(tableView: UITableView, reorderRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let item = items[sourceIndexPath.row]
        items.removeAtIndex(sourceIndexPath.row)
        items.insert(item, atIndex: destinationIndexPath.row)
    }
    
}
