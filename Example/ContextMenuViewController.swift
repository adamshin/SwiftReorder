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

class ContextMenuViewController: UITableViewController, UIContextMenuInteractionDelegate {
    
    var items = (1...10).map { "Item \($0)" }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(style: .plain)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Basic"

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.allowsSelection = false
        tableView.reorder.delegate = self
    }
    
    @available(iOS 13.0, *)
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            return self.makeContextMenu()
        })
    }
    
    @available(iOS 13.0, *)
    private func makeContextMenu() -> UIMenu {
        
        // More extensive than it needs to be, but helpful for showing options.

        let rename = UIAction(title: "Rename", image: UIImage(systemName: "square.and.pencil")) { action in
            // Show rename UI
        }

        // Here we specify the "destructive" attribute to show that it’s destructive in nature
        let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
            // Delete this photo 😢
        }

        // The "title" will show up as an action for opening this menu
        let edit = UIMenu(title: "Edit...", children: [rename, delete])
        
        // Create a UIAction for sharing
        let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { action in
            // Show system share sheet
        }

        // Create our menu with both the edit menu and the share action
        return UIMenu(title: "Main Menu", children: [edit, share])
    }

}

extension ContextMenuViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
            return spacer
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        
        
        if #available(iOS 13.0, *) {
            let interaction = UIContextMenuInteraction(delegate: self)
            cell.addInteraction(interaction)
        } else {
            // Fallback on earlier versions -- Do Nothing
        }
        
        return cell
    }
    
}

extension ContextMenuViewController: TableViewReorderDelegate {

    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = items[sourceIndexPath.row]
        items.remove(at: sourceIndexPath.row)
        items.insert(item, at: destinationIndexPath.row)
    }
    
}
