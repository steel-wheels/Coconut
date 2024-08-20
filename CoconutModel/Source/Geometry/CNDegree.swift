/**
 * @file	CNDegree.swift
 * @brief	Define CNDegree  class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import Foundation

public struct CNDegree
{
	public var isPositive:	Bool
	public var degree:	UInt
	public var minute:	UInt
	public var second:	UInt

	public static let degreeUnit	= 2.0 * Double.pi /  360
	public static let minuteUnit	= 2.0 * Double.pi /  (360 * 60)
	public static let secondUnit	= 2.0 * Double.pi /  (360 * 60 * 60)

	public init(isPositive pos: Bool, degree deg: UInt, minute min: UInt, second sec: UInt) {
		self.isPositive	= pos
		self.degree	= deg
		self.minute	= min
		self.second	= sec
	}

	public func toRadian() -> Double {
		let dr  = Double(degree) * CNDegree.degreeUnit
		let mr  = Double(minute) * CNDegree.minuteUnit
		let sr  = Double(second) * CNDegree.secondUnit
		let sum = dr + mr + sr
		return isPositive ? sum : -sum
	}

	public static func from(radian rad: Double) -> CNDegree {
		let rad0 = CNNormalizeRadian(source: rad)

		let dval = rad0 / degreeUnit
		let dint = dval.rounded(.down)
		let rad1 = rad0 - (dint * degreeUnit)

		let mval = rad1 / minuteUnit
		let mint = mval.rounded(.down)
		let rad2 = rad1 - (mint * minuteUnit)

		let sval = rad2 / secondUnit
		let sint = sval.rounded(.down)
		return CNDegree(isPositive: true, degree: UInt(dint), minute: UInt(mint), second: UInt(sint))
	}
}

public func CNNormalizeRadian(source src: Double) -> Double
{
	var val = src
	let pi2 = Double.pi * 2.0
	while val > pi2 {
		val = val - pi2
	}
	while 0.0 > val {
		val = val + pi2
	}
	return val
}


