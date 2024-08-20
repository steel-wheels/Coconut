/**
 * @file	CNProperties.swift
 * @brief	Define CNProperties protocol
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import Foundation

public protocol CNProperties
{
	var type: CNInterfaceType { get }

	var count: Int { get }

	var properties: Dictionary<String, CNValue> { get }

	var  names: Array<String> {get }
	func name(at index: Int) -> String?

	func value(byName name: String) -> CNValue?

	func set(value val: CNValue, forName name: String)

	func load(value val: Dictionary<String, CNValue>, from filename: String?) -> NSError?
	func save(to url: URL) -> Bool

        func toText() -> CNText
}

public extension CNProperties
{
	func toValue() -> Dictionary<String, CNValue> {
		return self.properties
	}
}

