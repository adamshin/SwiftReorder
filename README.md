# SwiftReorder
SwiftReorder adds drag-and-drop reordering to any table view with just a few lines of code. It's robust, lightweight, and completely customizable.

## Installation
Copy the contents of the `Source` folder into your project.

## Usage
Add the following line to your table view setup.
```swift
tableView.reorderDelegate = self
```
Add this code to the beginning of your `tableView(_:cellForRowAtIndexPath:)`.
```swift
if let spacer = tableView.spacerCellForIndexPath(indexPath) {
    return spacer
}
```
Implement this `TableViewReorderDelegate` method, and others as necessary.
```swift
tableView(_:reorderRowAtIndexPath:toIndexPath:)
```

## Customization
SwiftReorder exposes several properties on `UITableView` for adjusting the style of the reordering effect. For example, you can add a scaling effect to the selected cell:
```swift
tableView.reorderCellScale = 1.05
```
Or adjust the shadow:
```swift
tableView.reorderShadowOpacity = 0.5
tableView.reorderShadowRadius = 20
```
