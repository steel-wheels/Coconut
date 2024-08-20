/*
 * @file	UTEnumTable.swift
 * @brief	Test CNEnumTable class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import CoconutData
import Foundation

public func UTEnumTable() -> Bool
{
	NSLog("*** UTEnumTable")

	guard let srcfile = CNFilePath.URLForResourceFile(fileName: "enum", fileExtension: "json", subdirectory: "Data", forClass: ViewController.self) else {
		NSLog("Failed to allocate source url")
		return false
	}
	switch srcfile.loadValue() {
	case .success(let value):
		let vmgr = CNValueTypeManager.shared
		if let err = vmgr.load(fromValue: value) {
			NSLog("Failed to load value types: \(err.toString())")
			return false
		}
	case .failure(let err):
		NSLog("Failed to load source file: \(srcfile.path) \(err.toString())")
		return false
	}


	return true
}

