/**
 * @file	CNValueFile.swift
 * @brief	Define CNValueFile class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import Foundation

public class CNValueFile
{
	public static let TypeSectionName  = "type"
	public static let ValueSectionName = "value"

	public static func load(from url: URL) -> Result<Dictionary<String, CNValue>, NSError> {
		switch url.loadValue() {
		case .success(let val):
			if let dict = val.toDictionary() {
				return .success(dict)
			} else {
				let err = NSError.fileError(message: "The value file named \(url.path) must have dictionary")
				return .failure(err)
			}
		case .failure(let err):
			return .failure(err)
		}
	}

	public static func load(from url: URL, forClassName name: String) -> Result<Dictionary<String, CNValue>, NSError> {
		switch load(from: url) {
		case .success(let dict):
			if CNValue.hasClassName(inValue: dict, className: CNValueProperties.ClassName) {
				return .success(dict)
			} else {
				let err = NSError.fileError(message: "The value file does not not have \"\(name)\" class property")
				return .failure(err)
			}
		case .failure(let err):
			return .failure(err)
		}
	}
}

