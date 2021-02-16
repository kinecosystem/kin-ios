# <img src="../assets/kin-logo.png" height="32" alt="Kin Logo"> Kin Design

The Design library contains the UI components that are used in our full screen experiences like the KinUX module.
The documented components below are endorsed for external use as well and will be supported in a backwards compatible way (as much as possible) between versions. However, other view components not listed here contained in this module are subject to change or disappear version to version.

This library will improve and contain more items over time.

All of these components can be tested out and browsed in the [sample app](../KinSampleApp) which you can compile and run yourself.

## Installation
Add the following to your project's Podfile.
```
pod 'KinDesign', '~> 0.4.5'
```

### Primary Button
![](../assets/widget-primarybutton.png)
```swift
let button = PrimaryButton(frame: .zero)
button.setTitle("Pay Now", for: .normal)
button.sizeToFit()
```

### Inline Action Button
![](../assets/widget-standardbutton-inline.png)
```swift
let button = InlineActionButton(frame: .zero)
button.setTitle("Cancel", for: .normal)
button.sizeToFit()
```

### Negative Action Button
![](../assets/widget-standardbutton-negative.png)
```swift
let button = NegativeActionButton(frame: .zero)
button.setTitle("Cancel", for: .normal)
button.sizeToFit()
```

### Positive Action Button
![](../assets/widget-standardbutton-positive.png)
```swift
let button = PositiveActionButton(frame: .zero)
button.setTitle("Confirm", for: .normal)
button.sizeToFit()
```

### KinAmountView (Negative)
![](../assets/widget-kinamountview-negative.png)
```swift
let kinAmountView = KinAmountView(frame: .zero)
kinAmountView.size = .large
kinAmountView.amount = Decimal(floatLiteral: 200000.12345)
kinAmountView.sign = .negative
```

### KinAmountView (Positive)
![](../assets/widget-kinamountview-positive.png)
```swift
let kinAmountView = KinAmountView(frame: .zero)
kinAmountView.size = .medium
kinAmountView.amount = Decimal(floatLiteral: 200000.12345)
kinAmountView.sign = .positive
```

### InvoiceTableViewController
![](../assets/widget-invoicerenderer.png)
```swift
var invoice: InvoiceDisplayable = {
        var lineItems = [InvoiceDisplayable.LineItemDisplayable]()
        let lineItem1 = InvoiceDisplayable.LineItemDisplayable(title: "First Item",
                                                               description: "Lorem ipsum one line description",
                                                               amount: Decimal(integerLiteral: 10))
        let lineItem2 = InvoiceDisplayable.LineItemDisplayable(title: "Second Item",
                                                               description: "Lorem ipsum one line description",
                                                               amount: Decimal(integerLiteral: 25))
        let lineItem3 = InvoiceDisplayable.LineItemDisplayable(title: "Third Item",
                                                               description: "Lorem ipsum two line description if needed but no more than two.",
                                                               amount: Decimal(integerLiteral: 25))
        lineItems = [lineItem1, lineItem2, lineItem3]

        return InvoiceDisplayable(lineItems: lineItems, fee: Decimal(0.001))
    }()

lazy var tableViewController: InvoiceTableViewController = {
    let table = InvoiceTableViewController()
    table.invoice = self.invoice
    table.delegate = self
    return table
}()

override func viewDidLoad() {
    super.viewDidLoad()
    ...
    addChild(tableViewController)
    view.addSubview(tableViewController.view)
}
```

