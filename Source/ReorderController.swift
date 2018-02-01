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

struct ReorderContext {
    var sourceRow: IndexPath
    var destinationRow: IndexPath
 
    var selectedCellTouchOffset: CGFloat
}

/**
 An object that manages drag-and-drop reordering of table view cells.
 */
public class ReorderController: NSObject {
    
    // MARK: - Public interface
    
    /// The delegate of the reorder controller.
    public weak var delegate: TableViewReorderDelegate?
    
    /// Whether reordering is enabled.
    public var isEnabled: Bool = true {
        didSet { reorderGestureRecognizer.isEnabled = isEnabled }
    }
    
    public var longPressDuration: TimeInterval = 0.3 {
        didSet { reorderGestureRecognizer.minimumPressDuration = longPressDuration }
    }
    
    /// The duration of the cell selection animation.
    public var animationDuration: TimeInterval = 0.2
    
    /// The opacity of the selected cell.
    public var cellOpacity: CGFloat = 1
    
    /// The scale factor for the selected cell.
    public var cellScale: CGFloat = 1
    
    /// The shadow color for the selected cell.
    public var shadowColor: UIColor = .black
    
    /// The shadow opacity for the selected cell.
    public var shadowOpacity: CGFloat = 0.3
    
    /// The shadow radius for the selected cell.
    public var shadowRadius: CGFloat = 10
    
    /// The shadow offset for the selected cell.
    public var shadowOffset = CGSize(width: 0, height: 3)
    
    /// Whether or not autoscrolling is enabled
    public var isAutoScrollEnabled = true
    
    // MARK: - Internal state
    
    weak var tableView: UITableView?
    
    var reorderContext: ReorderContext?
    
    var selectedCellProxy: UIView?
    var cellProxies = [IndexPath: UIView]()
    
    var autoScrollDisplayLink: CADisplayLink?
    var lastAutoScrollTimeStamp: CFTimeInterval?
    
    lazy var reorderGestureRecognizer: UILongPressGestureRecognizer = {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleReorderGesture))
        gestureRecognizer.minimumPressDuration = self.longPressDuration
        return gestureRecognizer
    }()
    
    // MARK: - Initializer
    
    init(tableView: UITableView) {
        super.init()
        
        self.tableView = tableView
        tableView.addGestureRecognizer(reorderGestureRecognizer)
    }
    
}
