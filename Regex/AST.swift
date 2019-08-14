// The MIT License (MIT)
//
// Copyright (c) 2019 Alexander Grebenyuk (github.com/kean).

import Foundation

// MARK: - AST (Protocols)

/// An AST unit, marker protocol.
protocol Unit: Traceable {}

/// A terminal unit, can't contain other units (subexpressions).
protocol Terminal: Unit {}

/// An AST unit consisting of multiple units.
protocol CompoundUnit: Unit {
    var children: [Unit] { get }
}

/// Can be traced backed to the source in the pattern.
protocol Traceable {
    var source: Range<Int> { get }
}

// MARK: - AST (Components)

struct AST {
    let expression: Unit
    let pattern: String

    struct Expression: CompoundUnit {
        let children: [Unit]
        let source: Range<Int>
    }

    // "(ab)"
    struct Group: CompoundUnit {
        let index: Int
        let isCapturing: Bool
        let children: [Unit]
        let source: Range<Int>
    }

    // "a|bc"
    struct Alternation: CompoundUnit {
        let children: [Unit]
        let source: Range<Int>
    }

    // "(a)\1"
    struct Backreference: Terminal {
        let index: Int
        let source: Range<Int>
    }

    // "$", "\b", etc
    struct Anchor: Terminal {
        let type: AnchorType
        let source: Range<Int>
    }

    enum AnchorType {
        case startOfString
        case endOfString
        case wordBoundary
        case nonWordBoundary
        case startOfStringOnly
        case endOfStringOnly
        case endOfStringOnlyNotNewline
        case previousMatchEnd
    }

    struct Match: Terminal {
        let type: MatchType
        let source: Range<Int>
    }

    enum MatchType {
        case character(Character)
        case anyCharacter(includingNewline: Bool)
        case characterSet(CharacterSet)
    }

    struct QuantifiedExpression: CompoundUnit {
        let type: Quantifier
        let expression: Unit
        let source: Range<Int>

        var children: [Unit] { return [expression] }
    }

    // "a*", "a?", etc
    enum Quantifier {
        case zeroOrMore
        case oneOrMore
        case zeroOrOne
        case range(ClosedRange<Int>)
    }
}

// MARK: - AST (Description)

extension AST.Expression: CustomStringConvertible {
    var description: String {
        return "Expression"
    }
}

extension AST.Match: CustomStringConvertible {
    var description: String {
        switch type {
        case let .character(character): return "Character(\"\(character)\")"
        case let .characterSet(set): return "CharacterSet(\"\(set)\")"
        case let .anyCharacter(includingNewline): return includingNewline ?  "AnyCharacter(includingNewline: true)" : "AnyCharacter"
        }
    }
}

extension AST.Group: CustomStringConvertible {
    var description: String {
        if isCapturing {
            return "Group(index: \(index))"
        } else {
            return "Group(index: \(index), isCapturing: false)"
        }
    }
}

extension AST.Alternation: CustomStringConvertible {
    var description: String {
        return "Alternation"
    }
}

extension AST.Anchor: CustomStringConvertible {
    var description: String {
        return "Anchor.\(type)"
    }
}

extension AST.Backreference: CustomStringConvertible {
    var description: String {
        return "Backreference(index: \(index))"
    }
}

extension AST.QuantifiedExpression: CustomStringConvertible {
    var description: String {
        return "Quantifier.\(type)"
    }
}

extension AST: CustomStringConvertible {
    /// Returns a nicely formatted description of the unit.
    var description: String {
        var output = ""
        visit(expression, 0) { unit, level in
            let s = String(repeating: " ", count: level * 2) + "– " + description(for: unit)
            output.append(s)
            output.append("\n")
        }
        return output
    }

    func description(for unit: Unit) -> String {
        return "\(unit)" + " [\"\(pattern.substring(unit.source))\", \(unit.source)]"
    }

    func printRecursiveDescription() {
        print(description)
    }
}

// MARK: - AST (Visitor)

extension AST {
    /// Recursively visits all nodes.
    func visit(_ closure: (Unit) -> Void) {
        visit(expression, 0) { unit, _ in closure(unit) }
    }

    /// Recursively visits all nodes.
    private func visit(_ unit: Unit, _ level: Int, _ closure: (Unit, Int) -> Void) {
        closure(unit, level)
        if let children = (unit as? CompoundUnit)?.children {
            for child in children {
                visit(child, level + 1, closure)
            }
        }
    }
}
