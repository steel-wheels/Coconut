/**
 * @file	UTDMS.swift
 * @brief	Define test function for CNDMS
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import CoconutData
import CoconutModel
import Foundation

public func testDms(console cons: CNConsole) -> Bool
{
	cons.print(string: "**** testDMS\n")
	var result = true

	let dms0 = CNDMS(hour: 0, minute: 0, second: 0)
	result = convertDms(source: dms0, console: cons) && result

	let dms1 = CNDMS(hour: 12, minute: 0, second: 0)
	result = convertDms(source: dms1, console: cons) && result

	return true
}

private func convertDms(source src: CNDMS, console cons: CNConsole) -> Bool
{
	let rad = src.toRadian()
	let rev = CNDMS.from(radian: rad)

	let nrad = rad / Double.pi
	cons.print(string: "src(h:\(src.hour), m:\(src.minute), s:\(src.second)) -> rad:\(nrad) pi -> ")
	cons.print(string: "rev(h:\(rev.hour), m:\(rev.minute), s:\(rev.second))\n")

	return true
}
