/**
 * @file	CNDMS.swift
 * @brief	Define CNDMS  class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import Foundation

/*
 * Degrees, Minutes, Seconds System
 */
public struct CNDMS
{
	public var hour:	Int
	public var minute:	Int
	public var second:	Int

	public static let hourUnit	= 2.0 * Double.pi /  24.0
	public static let minuteUnit	= 2.0 * Double.pi / (24.0 * 60.0)
	public static let secondUnit	= 2.0 * Double.pi / (24.0 * 60.0 * 60.0)

	public init(hour h: Int, minute m: Int, second s: Int) {
		self.hour   = h
		self.minute = m
		self.second = s
	}

	public func toRadian() -> Double {
		let hval = Double(self.hour)   * CNDMS.hourUnit
		let mval = Double(self.minute) * CNDMS.minuteUnit
		let sval = Double(self.second) * CNDMS.secondUnit
		return hval + mval + sval
	}

	public static func from(radian rad: Double) -> CNDMS {
		let rad0 = CNNormalizeRadian(source: rad)

		let hval = rad0 / hourUnit
		let hint = hval.rounded(.down)
		let rad1 = rad0 - (hint * hourUnit)

		let mval = rad1 / minuteUnit
		let mint = mval.rounded(.down)
		let rad2 = rad1 - (mint * minuteUnit)

		let sval = rad2 / secondUnit
		let sint = sval.rounded(.down)
		return CNDMS(hour: Int(hint), minute: Int(mint), second: Int(sint))
	}

}

