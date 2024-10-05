/*
 * @file	CNGraphicsType.swift
 * @brief	Define data type for graphics
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public enum CNAxis: Int
{
	case horizontal
	case vertical

	public static let TypeName = "Axis"

	public var description: String {
		let result: String
		switch self {
		case .horizontal:	result = "horizontal"
		case .vertical:		result = "vertical"
		}
		return result
	}

	public static func allocateEnumType() -> CNEnumType {
		let axis = CNEnumType(typeName: CNAxis.TypeName)
		axis.add(members: [
			"horizontal":		.intValue(CNAxis.horizontal.rawValue),
			"vertical":		.intValue(CNAxis.vertical.rawValue)
		])
		return axis
	}
}

public enum CNAlignment: Int {
	case leading
	case trailing
	case fill
	case center

	public static let TypeName = "Alignment"

	public static func allocateEnumType() -> CNEnumType {
		let alignment = CNEnumType(typeName: CNAlignment.TypeName)
		alignment.add(members: [
			"leading": 		.intValue(CNAlignment.leading.rawValue),
			"trailing": 		.intValue(CNAlignment.trailing.rawValue),
			"fill": 		.intValue(CNAlignment.fill.rawValue),
			"center": 		.intValue(CNAlignment.center.rawValue)
		])
		return alignment
	}

	public var description: String {
		let result: String
		switch self {
		case .leading:		result = "leading"
		case .trailing:		result = "trailing"
		case .fill:		result = "fill"
		case .center:		result = "center"
		}
		return result
	}
}

public enum CNVerticalPosition {
	case top
	case middle
	case bottom
}

public enum CNHorizontalPosition {
	case left
	case center
	case right
}

public enum CNButtonState: Int
{
	case hidden	= 0
	case disable	= 1
	case off	= 2
	case on		= 3

	public static let TypeName = "ButtonState"

	public static func allocateEnumType() -> CNEnumType {
		let btnstate = CNEnumType(typeName: CNButtonState.TypeName)
		btnstate.add(members: [
			"hidden":	.intValue(CNButtonState.hidden.rawValue),
			"disable":	.intValue(CNButtonState.disable.rawValue),
			"off":		.intValue(CNButtonState.off.rawValue),
			"on":		.intValue(CNButtonState.on.rawValue)
		])
		return btnstate
	}

	public var description: String { get {
		let result: String
		switch self {
		case .hidden:	result = "hidden"
		case .disable:	result = "disable"
		case .off:	result = "off"
		case .on:	result = "on"
		}
		return result
	}}
}

public struct CNPosition {
	public var 	horizontal:	CNHorizontalPosition
	public var	vertical:	CNVerticalPosition

	public init(){
		vertical	= .middle
		horizontal	= .center
	}

	public init(horizontal hpos: CNHorizontalPosition, vertical vpos: CNVerticalPosition){
		vertical	= vpos
		horizontal	= hpos
	}
}

/* OSX: NSStackView.Distribution */
public enum CNDistribution: Int {
	case fill
	case fillProportinally
	case fillEqually
	case equalSpacing

	public static let TypeName = "Distribution"

	public static func allocateEnumType() -> CNEnumType {
		let distribution = CNEnumType(typeName: CNDistribution.TypeName)
		distribution.add(members: [
			"fill":			.intValue(CNDistribution.fill.rawValue),
			"fillProportinally":	.intValue(CNDistribution.fillProportinally.rawValue),
			"fillEqually":		.intValue(CNDistribution.fillEqually.rawValue),
			"equalSpacing":		.intValue(CNDistribution.equalSpacing.rawValue)
		])
		return distribution
	}

	public var description: String {
		let result: String
		switch self {
		case .fill:			result = "fill"
		case .fillProportinally:	result = "fillProportionally"
		case .fillEqually:		result = "fillEqually"
		case .equalSpacing:		result = "equalSpacing"
		}
		return result
	}
}

public enum CNAnimationState: Int {
	case	idle
	case	run
	case	pause

	public static let TypeName = "AnimationState"

	public static func allocateEnumType() -> CNEnumType {
		let animstate = CNEnumType(typeName: CNAnimationState.TypeName)
		animstate.add(members: [
			"idle":			.intValue(CNAnimationState.idle.rawValue),
			"run":			.intValue(CNAnimationState.run.rawValue),
			"pause":		.intValue(CNAnimationState.pause.rawValue)
		])
		return animstate
	}

	public var description: String {
		get {
			let result: String
			switch self {
			case .idle:	result = "idle"
			case .run:	result = "run"
			case .pause:	result = "pause"
			}
			return result
		}
	}
}
