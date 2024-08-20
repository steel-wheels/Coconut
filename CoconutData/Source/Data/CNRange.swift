/**
 * @file	CNRange.swift
 * @brief	Define CNRange class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public extension NSRange
{
	static let InterfaceName = "RangeIF"

	static func allocateInterfaceType() -> CNInterfaceType {
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: "location",	type: .numberType),
			M(name: "length",	type: .numberType)
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	static func fromValue(value val: CNInterfaceValue) -> NSRange? {
		guard val.type.name == InterfaceName else {
			return nil
		}
		if let locval = val.get(name: "location"), let lenval = val.get(name: "length") {
			if let locnum = locval.toNumber(), let lennum = lenval.toNumber() {
				let loc = locnum.intValue
				let len = lennum.intValue
				return NSRange(location: loc, length: len)
			}
		}
		return nil
	}

	func toValue() -> CNInterfaceValue {
		let locnum = NSNumber(integerLiteral: self.location)
		let lennum = NSNumber(integerLiteral: self.length)
		let ptypes: Dictionary<String, CNValue> = [
			"location" : .numberValue(locnum),
			"length"   : .numberValue(lennum)
		]
		return CNInterfaceValue(types: NSRange.allocateInterfaceType(), values: ptypes)
	}
}

