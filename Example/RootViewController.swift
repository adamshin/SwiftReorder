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

class RootViewController: UITableViewController {
    
    enum Row: Int {
        case Basic = 0
        case Grouped
        case LongList
        case DynamicHeight
        case NonMovable
        case Effects
        
        case Count
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(style: .Grouped)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "SwiftReorder"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
}

extension RootViewController {

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Row.Count.rawValue
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        switch Row(rawValue: indexPath.row) ?? .Count {
        case .Basic:
            cell.textLabel?.text = "Basic"
        case .Grouped:
            cell.textLabel?.text = "Grouped"
        case .LongList:
            cell.textLabel?.text = "Long List"
        case .DynamicHeight:
            cell.textLabel?.text = "Dynamic Height"
        case .NonMovable:
            cell.textLabel?.text = "Non-Movable"
        case .Effects:
            cell.textLabel?.text = "Effects"
        case .Count:
            break
        }
        
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch Row(rawValue: indexPath.row) ?? .Count {
        case .Basic:
            navigationController?.pushViewController(BasicViewController(), animated: true)
        case .Grouped:
            navigationController?.pushViewController(GroupedViewController(), animated: true)
        case .LongList:
            navigationController?.pushViewController(LongListViewController(), animated: true)
        case .DynamicHeight:
            navigationController?.pushViewController(DynamicHeightViewController(), animated: true)
        case .NonMovable:
            navigationController?.pushViewController(NonMovableViewController(), animated: true)
        case .Effects:
            navigationController?.pushViewController(EffectsViewController(), animated: true)
        case .Count:
            break
        }
    }
    
}
