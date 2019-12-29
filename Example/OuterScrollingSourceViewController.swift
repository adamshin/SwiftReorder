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

private final class SelfResizableTableView: UITableView {
    
    // ******************************* MARK: - UIView Overrides
    
    override var contentSize: CGSize {
        didSet {
            guard oldValue != contentSize else { return }
            invalidateIntrinsicContentSize()
        }
    }
    
    override var contentInset: UIEdgeInsets {
        didSet {
            guard oldValue != contentInset else { return }
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        var intrinsicContentSize = contentSize
        intrinsicContentSize.height += contentInset.top
        intrinsicContentSize.height += contentInset.bottom
        intrinsicContentSize.width += contentInset.left
        intrinsicContentSize.width += contentInset.right
        
        return intrinsicContentSize
    }
}

private extension UIView {
    /// Creates constraints between self and provided view for top, bottom, leading and trailing sides.
    @available(iOS 9.0, *)
    func constraintSides(to view: UIView) {
        let constraints: [NSLayoutConstraint] = [
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor)
        ]
        
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints)
    }
}

class OuterScrollingSourceViewController: UIViewController {
    
    var items = (1...50).map { "Item \($0)" }
    
    private lazy var outerScrollingSource: UIScrollView = {
        let outerScrollingSource = UIScrollView()
        
        return outerScrollingSource
    }()
    
    private lazy var tableView: SelfResizableTableView = {
        let tableView = SelfResizableTableView()
        tableView.delegate = self
        tableView.dataSource = self
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Outer Scrolling Source"
        
        view.addSubview(outerScrollingSource)
        outerScrollingSource.constraintSides(to: view)
        
        outerScrollingSource.addSubview(tableView)
        tableView.constraintSides(to: outerScrollingSource)
        tableView.widthAnchor.constraint(equalTo: outerScrollingSource.widthAnchor).isActive = true
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.allowsSelection = false
        tableView.rowHeight = 44
        tableView.reorder.delegate = self
    }
    
}

extension OuterScrollingSourceViewController: UITableViewDelegate, UITableViewDataSource {
    
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

extension OuterScrollingSourceViewController: TableViewReorderDelegate {
    
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = items[sourceIndexPath.row]
        items.remove(at: sourceIndexPath.row)
        items.insert(item, at: destinationIndexPath.row)
    }

}
