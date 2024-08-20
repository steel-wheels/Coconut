/**
 * @file	CNRecord.swift
 * @brief	Define CNRecord protocol
 * @par Copyright
 *   Copyright (C) 2021-2022 Steel Wheels Project
 */

import Foundation

public protocol CNRecord
{
	var type: CNInterfaceType { get }

	var fieldCount: Int { get }
	var fieldNames: Array<String> { get }

	func value(ofField name: String) -> CNValue?
	func setValue(value val: CNValue, forField name: String) -> Bool

	func load(value val: Dictionary<String, CNValue>, from filename: String?) -> NSError?
}

public extension CNRecord
{
	var description: String { get {
		let val: CNValue = .dictionaryValue(self.toValue())
		return val.description
	}}

	func toValue() -> Dictionary<String, CNValue> {
		var result: Dictionary<String, CNValue> = [:]
		let fnames = self.type.members.map{ $0.name }
		for name in fnames {
			if let val = self.value(ofField: name) {
				result[name] = val
			}
		}
		return result
	}
}


