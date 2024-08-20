/**
 * @file	UTDegree.swift
 * @brief	Define test function for CNDegree
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import CoconutData
import CoconutModel
import Foundation

public func testDegree(console cons: CNConsole) -> Bool
{
	cons.print(string: "**** testDegree\n")
	let res0 = convertDegree(source:
		CNDegree(isPositive: true, degree: 35, minute: 40, second: 12),
		console: cons)
	let res1 = convertDegree(source:
		CNDegree(isPositive: false, degree: 35, minute: 40, second: 12),
		console: cons)
	return res0 && res1
}

private func convertDegree(source src: CNDegree, console cons: CNConsole) -> Bool
{
	let rad = src.toRadian()
	let deg = rad * 360.0 / (2.0 * Double.pi)
	let rev = CNDegree.from(radian: rad)
	cons.print(string: "src(\(src.isPositive), \(src.degree), \(src.minute), \(src.second) -> ")
	cons.print(string: "raduan:\(rad) -> degree(\(deg)) -> ")
	cons.print(string: "rev(\(rev.isPositive), \(rev.degree), \(rev.minute), \(rev.second)\n")
	return true
}

