/**
 * @file	CNOval.swift
 * @brief	Define CNOval class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import CoreGraphics
import Foundation

public struct CNOval
{
	public static let InterfaceName = "OvalIF"

	private var mCenter:	CGPoint
	private var mRadius:	CGFloat

	static func allocateInterfaceType(pointIF ptif: CNInterfaceType) -> CNInterfaceType {
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: "center", type: .interfaceType(ptif)),
			M(name: "radius", type: .numberType)
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	public init(center ctr: CGPoint, radius rad: CGFloat){
		mCenter		= ctr
		mRadius		= rad
	}

	public static func fromValue(value val: CNInterfaceValue) -> CNOval? {
		guard val.type.name == InterfaceName else {
			return nil
		}
		if let centerval = val.get(name: "center"), let radval = val.get(name: "radius") {
			if let centerif = centerval.toInterface(interfaceName: CGPoint.InterfaceName),
			   let radius = radval.toNumber() {
				if let center = CGPoint.fromValue(value: centerif) {
					return CNOval(center: center, radius: CGFloat(radius.floatValue))
				}
			}
		}
		return nil
	}

	public func toValue() -> CNInterfaceValue {
		let iftype = CNOval.allocateInterfaceType(pointIF: CGPoint.allocateInterfaceType())
		let center = mCenter.toValue()
		let radius = NSNumber(floatLiteral: Double(mRadius))
		let ptypes: Dictionary<String, CNValue> = [
			"center"	: .interfaceValue(center),
			"radius"	: .numberValue(radius)
		]
		return CNInterfaceValue(types: iftype, values: ptypes)
	}

	public var center: CGPoint { get { return mCenter }}
	public var radius: CGFloat { get { return mRadius }}

	public var upperCenter: CGPoint { get {
		let result: CGPoint
		#if os(OSX)
			result = CGPoint(x: mCenter.x, y: mCenter.y + mRadius)
		#else
			result = CGPoint(x: mCenter.x, y: mCenter.y - mRadius)
		#endif
		return result
	}}

	public var lowerCenter: CGPoint { get {
		let result: CGPoint
		#if os(OSX)
			result = CGPoint(x: mCenter.x, y: mCenter.y - mRadius)
		#else
			result = CGPoint(x: mCenter.x, y: mCenter.y + mRadius)
		#endif
		return result
	}}

	public var middleLeft: CGPoint { get {
		return CGPoint(x: mCenter.x - mRadius, y: mCenter.y)
	}}

	public var middleRight: CGPoint { get {
		return CGPoint(x: mCenter.x + mRadius, y: mCenter.y)
	}}
}


