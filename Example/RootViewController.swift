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
        case basic = 0
        case grouped
        case longList
        case nonMovable
        case effects
        case customCells
        
        case count
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(style: .grouped)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "SwiftReorder"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
}

extension RootViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Row.count.rawValue
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        switch Row(rawValue: indexPath.row) ?? .count {
        case .basic:
            cell.textLabel?.text = "Basic"
        case .grouped:
            cell.textLabel?.text = "Grouped"
        case .longList:
            cell.textLabel?.text = "Long List"
        case .nonMovable:
            cell.textLabel?.text = "Non-Movable"
        case .effects:
            cell.textLabel?.text = "Effects"
        case .customCells:
            cell.textLabel?.text = "Custom Cells"
        case .count:
            break
        }
        
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Row(rawValue: indexPath.row) ?? .count {
        case .basic:
            navigationController?.pushViewController(BasicViewController(), animated: true)
        case .grouped:
            navigationController?.pushViewController(GroupedViewController(), animated: true)
        case .longList:
            navigationController?.pushViewController(LongListViewController(), animated: true)
        case .nonMovable:
            navigationController?.pushViewController(NonMovableViewController(), animated: true)
        case .effects:
            navigationController?.pushViewController(EffectsViewController(), animated: true)
        case .customCells:
            navigationController?.pushViewController(CustomCellsController(), animated: true)
        case .count:
            break
        }
    }
    
}
