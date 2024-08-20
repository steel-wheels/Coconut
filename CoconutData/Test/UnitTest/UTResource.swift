/**
 * @file	UTResource.swift
 * @brief	Test function for CNResource class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testResource(console cons: CNConsole) -> Bool
{
	let baseurl  = URL(fileURLWithPath: "/tmp")
	let resource = CNResource(packageDirectory: baseurl)

	resource.allocate(category: "Identifiers", dataType: .string)
	resource.add(category: "Identifiers", identifier: "ident0", path: "a.json", withCache: false)

	var result = true
	if let path = resource.pathString(category: "Identifiers", identifier: "ident0", index: 0) {
		cons.print(string: "[Path] \(path)\n")
	} else {
		cons.print(string: "[Error] Can not get path string\n")
		result = false
	}

	/*
	if let res: NSNumber = resource.load(category: "Number", identifier: "number0", index: 0) {
		cons.print(string: "[OK] Loaded => \(res.doubleValue)\n")
	} else {
		cons.print(string: "[Error] Can not load resource0\n")
		result = false
	}*/
	if result {
		cons.print(string: "testResource .. OK\n")
	} else {
		cons.print(string: "testResource .. NG\n")
	}
	return result
}
