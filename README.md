# Formatting

An example how to implement basic string formatting using XML tags. 

```swift
let input = "M1 delivers up to <b>2.8x faster</b> processing performance than the <a href='%@'>previous generation.</a>"
let text = String(format: input, "https://support.apple.com/kb/SP799")
let style = FormattedStringStyle(attributes: [
    "body": [.font: UIFont.systemFont(ofSize: 15)],
    "b": [.font: UIFont.boldSystemFont(ofSize: 15)],
    "a": [.underlineColor: UIColor.clear]
])
label.attributedText = NSAttributedString(formatting: text, style: style)
```

![example](https://user-images.githubusercontent.com/1567433/100555152-9d7a7280-3267-11eb-82ea-57ee43352468.png)

# License

Formatting is available under the MIT license. See the LICENSE file for more info.
