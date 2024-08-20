/**
 * @file	maiin.swift
 * @brief	Define main function
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import CoconutData
import CoconutModel
import Foundation

public func main(arguments args: Array<String>)
{
	let console = CNFileConsole()

	console.print(string: "**** main\n")
	let res0 = testDegree(console: console)
	let res1 = testDms(console: console)

	let result = res0 && res1
	if result {
		console.print(string: "SUMMARY ... OK\n")
	} else {
		console.print(string: "SUMMARY ... NG\n")
	}
}

main(arguments: [])

