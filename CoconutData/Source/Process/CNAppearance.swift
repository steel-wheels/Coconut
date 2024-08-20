/**
 * @file	CNAppearance.swift
 * @brief	Define CNAppearance class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

#if os(OSX)
import AppKit
#else
import UIKit
#endif

public enum CNInterfaceStyle: Int {
	public static let TypeName = "InterfaceStyle"

	case light              = 0
	case dark               = 1

	public var description: String {
		let result: String
		switch self {
		case .dark:	result = "dark"
		case .light:	result = "light"
		}
		return result
	}

	public static func allocateEnumType() -> CNEnumType {
		let style = CNEnumType(typeName: CNInterfaceStyle.TypeName)
		style.add(members: [
			"dark":		.intValue(CNInterfaceStyle.dark.rawValue),
			"light":	.intValue(CNInterfaceStyle.light.rawValue)
		])
		return style
	}

	public static func decode(name nm: String) -> CNInterfaceStyle? {
		let style: CNInterfaceStyle?
		switch nm {
		case "dark":	style = .dark
		case "light":	style = .light
		default:	style = nil
		}
		return style
	}

	public func toObject() -> NSNumber {
		return NSNumber(integerLiteral: self.rawValue)
	}

	public static func from(object obj: NSObject) -> CNInterfaceStyle? {
		if let num = obj as? NSNumber {
			if let style = CNInterfaceStyle(rawValue: num.intValue) {
				return style
			}
		}
		return nil
	}
}


