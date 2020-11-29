// The MIT License (MIT)
//
// Copyright (c) 2020 Alexander Grebenyuk (github.com/kean).

import XCTest
import Formatting

class FormattingsTests: XCTestCase {

    func testBodyFont() throws {
        // GIVEN
        let style = FormattedStringStyle(attributes: [
            "body": [.font: UIFont(name: "HelveticaNeue-Light", size: 20)!]
        ])

        // WHEN
        let input = "Hello"
        let output = NSAttributedString(formatting: input, style: style)

        // THEN
        let allAttributes = output.attributes
        XCTAssertEqual(allAttributes.count, 1)

        do {
            let body = try XCTUnwrap(allAttributes.first { $0.range == NSRange(0..<5) }?.attributes)
            XCTAssertEqual(body.count, 1)

            let font = try XCTUnwrap(body[.font] as? UIFont)
            XCTAssertEqual(font.fontName, "HelveticaNeue-Light")
            XCTAssertEqual(font.pointSize, 20)
        }
    }

    func testBoldFont() throws {
        // GIVEN
        let style = FormattedStringStyle(attributes: [
            "body": [.font: UIFont(name: "HelveticaNeue-Light", size: 20)!],
            "b": [.font: UIFont(name: "HelveticaNeue-Medium", size: 20)!]
        ])

        // WHEN
        let input = "Hello <b>World</b>"
        let output = NSAttributedString(formatting: input, style: style)

        // THEN
        let allAttributes = output.attributes
        XCTAssertEqual(allAttributes.count, 2)

        do {
            let body = try XCTUnwrap(allAttributes.first { $0.range == NSRange(0..<6) }?.attributes)
            XCTAssertEqual(body.count, 1)

            let font = try XCTUnwrap(body[.font] as? UIFont)
            XCTAssertEqual(font.fontName, "HelveticaNeue-Light")
            XCTAssertEqual(font.pointSize, 20)
        }

        do {
            let bold = try XCTUnwrap(allAttributes.first { $0.range == NSRange(6..<11) }?.attributes)
            XCTAssertEqual(bold.count, 1)

            let font = try XCTUnwrap(bold[.font] as? UIFont)
            XCTAssertEqual(font.fontName, "HelveticaNeue-Medium")
            XCTAssertEqual(font.pointSize, 20)
        }
    }

    func testLink() throws {
        // GIVEN
        let style = FormattedStringStyle(attributes: [
            "body": [.font: UIFont(name: "HelveticaNeue-Light", size: 20)!]
        ])

        // WHEN
        let input = "Tap <a href=\"https://google.com\">this</a>"
        let output = NSAttributedString(formatting: input, style: style)

        // THEN
        let allAttributes = output.attributes
        XCTAssertEqual(allAttributes.count, 2)

        do {
            let body = try XCTUnwrap(allAttributes.first { $0.range == NSRange(0..<4) }?.attributes)
            XCTAssertEqual(body.count, 1)

            let font = try XCTUnwrap(body[.font] as? UIFont)
            XCTAssertEqual(font.fontName, "HelveticaNeue-Light")
            XCTAssertEqual(font.pointSize, 20)
        }

        do {
            let link = try XCTUnwrap(allAttributes.first { $0.range == NSRange(4..<8) }?.attributes)
            XCTAssertEqual(link.count, 2)

            let url = try XCTUnwrap(link[.link] as? URL)
            XCTAssertEqual(url.absoluteString, "https://google.com")

            let font = try XCTUnwrap(link[.font] as? UIFont)
            XCTAssertEqual(font.fontName, "HelveticaNeue-Light")
            XCTAssertEqual(font.pointSize, 20)
        }
    }
}

private extension NSAttributedString {
    var attributes: [(range: NSRange, attributes: [NSAttributedString.Key: Any])] {
        var output = [(NSRange, [NSAttributedString.Key: Any])]()
        var range = NSRange()
        var index = 0

        while index < length {
            let attributes = self.attributes(at: index, effectiveRange: &range)
            output.append((range, attributes))
            index = max(index + 1, Range(range)?.endIndex ?? 0)
        }
        return output
    }
}
