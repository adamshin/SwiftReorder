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
import SwiftReorder

class DeletableViewController: UIViewController {
    
    var items = (1...10).map { "Item \($0)" }
    private var tableView: UITableView!
    private var deleteButton: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Deletable"
        
        tableView = UITableView(frame: view.frame, style: .grouped)
        tableView.dataSource = self
        view.addSubview(tableView)
        view.backgroundColor = .white
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.allowsSelection = false
        tableView.reorder.delegate = self
    }
    
    private func showDeleteButton() {
        let button = UIView()
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        let bottomAnchor: NSLayoutYAxisAnchor
        if #available(iOS 11, *) {
            bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
        } else {
            bottomAnchor = view.bottomAnchor
        }
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            button.heightAnchor.constraint(equalToConstant: 50),
            button.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        
        let label = UILabel()
        label.text = "💣"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: 50),
            label.heightAnchor.constraint(equalToConstant: 50),
            label.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: button.centerYAnchor)
            ])
        
        deleteButton = button
        
        if let snapshot = tableView.reorder.snapshotView {
            snapshot.superview?.bringSubviewToFront(snapshot)
        }
    }
    
    private func removeDeleteButton() {
        deleteButton?.removeFromSuperview()
    }
    
    private func handleCellMove(with gestureRecognizer: UIGestureRecognizer) {
        guard let deletionRatio = getDeletionRatio(from: gestureRecognizer),
            let snapshot = tableView.reorder.snapshotView else {
                return
        }
        
        if deletionRatio > 0 {
            snapshot.alpha = 1 - deletionRatio
        } else {
            snapshot.alpha = 1
        }
    }
    
    private func getDeletionRatio(from gestureRecognizer: UIGestureRecognizer) -> CGFloat? {
        guard let deleteButton = deleteButton else {
            return nil
        }
        let position = gestureRecognizer.location(in: deleteButton).y
        let targetPosition = deleteButton.frame.height / 2
        let targetSize = deleteButton.frame.height
        let deletionRatio = max(1 - abs(position - targetPosition) / targetSize, 0)
        return deletionRatio
    }
}

extension DeletableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
            return spacer
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        
        return cell
    }
    
}

extension DeletableViewController: TableViewReorderDelegate {
    
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = items[sourceIndexPath.row]
        items.remove(at: sourceIndexPath.row)
        items.insert(item, at: destinationIndexPath.row)
    }
    
    func tableViewDidBeginReordering(_ tableView: UITableView, at indexPath: IndexPath) {
        showDeleteButton()
    }
    
    func tableViewShouldRemoveCell(_ tableView: UITableView, from initialSourceIndexPath: IndexPath, to finalDestinationIndexPath: IndexPath, with gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let deletionRatio = getDeletionRatio(from: gestureRecognizer) else {
            return false
        }
        if deletionRatio > 0.5 {
            return true
        }
        return false
    }
    
    func tableViewDidMoveCell(_ tableView: UITableView, with gestureRecognizer: UIGestureRecognizer) {
        handleCellMove(with: gestureRecognizer)
    }
    
    func tableViewDidFinishReordering(_ tableView: UITableView, from initialSourceIndexPath: IndexPath, to finalDestinationIndexPath: IndexPath) {
        removeDeleteButton()
    }
    
    func tableViewDidFinishReorderingWithDeletion(_ tableView: UITableView, from initialSourceIndexPath: IndexPath, last lastIndexPath: IndexPath) {
        items.remove(at: finalDestinationIndexPath.row)
        removeDeleteButton()
    }
}
