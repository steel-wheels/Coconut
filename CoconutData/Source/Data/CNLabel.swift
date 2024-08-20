/**
 * @file	CNLabel.swift
 * @brief	Define CNLabel class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import Foundation

public class CNMenuItem
{
	public static let InterfaceName = "MenuItemIF"

	public var title:	String
	public var value:	Int

	public init(title ttl: String, value val: Int) {
		self.title = ttl
		self.value = val
	}

	public static var empty: CNMenuItem { get {
		return CNMenuItem(title: "", value: -1)
	}}

	static func allocateInterfaceType() -> CNInterfaceType {
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: "title",	type: .stringType),
			M(name: "value",	type: .numberType)
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}
}

