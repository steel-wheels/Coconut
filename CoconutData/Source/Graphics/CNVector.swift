/**
 * @file	CNVector.swift
 * @brief	Extend CGVector structure
 * @par Copyright
 *   Copyright (C) 2023  Steel Wheels Project
 */

import CoreGraphics
import Foundation

public extension CGVector
{
	static let InterfaceName = "VectorIF"

	static func allocateInterfaceType() -> CNInterfaceType {
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: "dx",	type: .numberType),
			M(name: "dy",	type: .numberType)
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	static func fromValue(value val: CNInterfaceValue) -> CGVector? {
		if let dxval = val.get(name: "dx"),     let dyval = val.get(name: "dy") {
			if let dxnum = dxval.toNumber(), let dynum = dyval.toNumber() {
				let dx      : CGFloat = CGFloat(dxnum.doubleValue)
				let dy      : CGFloat = CGFloat(dynum.doubleValue)
				return CGVector(dx: dx, dy: dy)
			}
		}
		return nil
	}

	var description: String { get {
		let dxstr = NSString(format: "%.2lf", Double(self.dx))
		let dystr = NSString(format: "%.2lf", Double(self.dy))
		return "{dx:\(dxstr), dy:\(dystr)}"
	}}
}

