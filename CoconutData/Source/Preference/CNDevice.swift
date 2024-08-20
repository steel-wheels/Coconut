/**
 * @file	CNDevice.swift
 * @brief	Define CNDevice class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

#if os(iOS)
import UIKit
#endif
import Foundation

public enum CNDevice: Int, Comparable
{
	public static  let TypeName = "Device"

	case mac
	case phone
	case ipad
	case tv
	case carPlay
	case vision

	public static func device() -> CNDevice {
		let result: CNDevice
		#if os(OSX)
		result = .mac
		#else
		switch UIDevice.current.userInterfaceIdiom {
		case .mac:
			result = .mac
		case .pad:
			result = .ipad
		case .phone:
			result = .phone
		case .carPlay:
			result = .carPlay
		case .tv:
			result = .tv
		case .unspecified:
			NSLog("[Error] Unspecified device")
			result = .phone
		case .vision:
			result = .vision
		@unknown default:
			NSLog("[Error] Unknown device")
			result = .phone
		}
		#endif
		return result
	}

	public static func allocateEnumType() -> CNEnumType {
		let devcode = CNEnumType(typeName: TypeName)
		devcode.add(members: [
			"mac":			.intValue(CNDevice.mac.rawValue),
			"phone":		.intValue(CNDevice.phone.rawValue),
			"ipad":			.intValue(CNDevice.ipad.rawValue),
			"tv":			.intValue(CNDevice.tv.rawValue),
			"carPlay":		.intValue(CNDevice.carPlay.rawValue)
		])
		return devcode
	}

	public static func < (lhs: CNDevice, rhs: CNDevice) -> Bool {
		return lhs.rawValue < rhs.rawValue
	}

	public static func > (lhs: CNDevice, rhs: CNDevice) -> Bool {
		return lhs.rawValue > rhs.rawValue
	}

	public static func == (lhs: CNDevice, rhs: CNDevice) -> Bool {
		return lhs.rawValue == rhs.rawValue
	}

	public static func != (lhs: CNDevice, rhs: CNDevice) -> Bool {
		return lhs.rawValue != rhs.rawValue
	}
}

