/**
 * @file    CNIcon.swift
 * @brief    Define CNIcon class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import Foundation

public struct CNIcon
{
    public static let InterfaceName    = "IconIF"

    public var  tag:        Int
    public var  symbol:     CNSymbol
    public var  title:      String

    public init(tag: Int, symbol: CNSymbol, title: String) {
        self.tag        = tag
        self.symbol     = symbol
        self.title      = title
    }

    public static func allocateInterfaceType(symbolIF symif: CNInterfaceType) -> CNInterfaceType {
        typealias M = CNInterfaceType.Member
        let members: Array<M> = [
            M(name: "tag",      type: .numberType),
            M(name: "symbol",   type: .interfaceType(symif)),
            M(name: "title",    type: .stringType)
        ]
        return CNInterfaceType(name: InterfaceName, base: nil, members: members)
    }

    public func toText() -> CNText {
        let result = CNTextSection()
        result.header = "{" ; result.footer = "}"
        let line = CNTextLine(string: "tag=\(self.tag), symbol=\(self.symbol.identifier), title=\(self.title)")
        result.add(text: line)
        return result
    }
}
