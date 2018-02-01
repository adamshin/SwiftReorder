//
//  NewTestViewController.swift
//  SwiftReorder
//
//  Created by Adam Shin on 1/31/18.
//  Copyright © 2018 Adam Shin. All rights reserved.
//

import UIKit

class NewTestViewController: UIViewController {
    
    let tableView = UITableView(frame: .zero, style: .plain)
    
    var items = (1...50).map { "Item \($0)" }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "New Test"
        view.backgroundColor = .darkGray
        
        view.addSubview(tableView)
        tableView.frame = view.bounds.insetBy(dx: 0, dy: 100)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.allowsSelection = false
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reorder.delegate = self
    }
    
}

extension NewTestViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        
        return cell
    }
    
}

extension NewTestViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.reorder.prepare(cell, at: indexPath)
    }
    
}

extension NewTestViewController: TableViewReorderDelegate {
    
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = items[sourceIndexPath.row]
        items.remove(at: sourceIndexPath.row)
        items.insert(item, at: destinationIndexPath.row)
    }
    
}
