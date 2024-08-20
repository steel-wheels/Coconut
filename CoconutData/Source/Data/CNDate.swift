/*
 * @file	CNDate.swift
 * @brief	Define CNDate class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import Foundation
#if os(OSX)
import AppKit
#else
import UIKit
#endif

public extension Date {
	static let InterfaceName = "DateIF"

	static func allocateInterfaceType(sizeIF szif: CNInterfaceType) -> CNInterfaceType {
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: "toString",	type: .functionType(.stringType, [])),
			M(name: "year",		type: .numberType),
			M(name: "month",	type: .numberType),
			M(name: "day",		type: .numberType)
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	func toString() -> String {
		return self.description
	}

	var year: Int { get {
		return Calendar.current.component(.year, from: self)
	}}

	var month: Int { get {
		return Calendar.current.component(.month, from: self)
	}}

	var day: Int { get {
		return Calendar.current.component(.day, from: self)
	}}
}
