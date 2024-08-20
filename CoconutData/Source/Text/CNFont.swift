/**
 * @file	CNFont.swift
 * @brief	Define CNFont class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

#if os(OSX)
import AppKit
public typealias CNFont = NSFont
#else
import UIKit
public typealias CNFont = UIFont
#endif

public extension CNFont
{
	static let StyleName	= "FontStyle"
	static let SizeName	= "FontSize"

	enum Style: Int {
		case normal	= 0
		case monospace	= 1

		public static func allocateEnumType() -> CNEnumType {
			let fontstyle = CNEnumType(typeName: CNFont.StyleName)
			fontstyle.add(members: [
				"normal":	.intValue(CNFont.Style.normal.rawValue),
				"monospace":	.intValue(CNFont.Style.monospace.rawValue)
			])
			return fontstyle
		}
	}

	enum Size: Int {
		case small	= 0
		case regular	= 1
		case large	= 2

		public static func allocateEnumType() -> CNEnumType {
			let fontsize = CNEnumType(typeName: CNFont.SizeName)
			fontsize.add(members: [
				"small":		.intValue(CNFont.Size.small.rawValue),
				"regular":		.intValue(CNFont.Size.regular.rawValue),
				"large": 		.intValue(CNFont.Size.large.rawValue)
			])
			return fontsize
		}

		public func toSize() -> CGFloat {
			let result: CGFloat
			switch self {
			case .small:   result = CNFont.systemFontSize * 1.0
			case .regular: result = CNFont.systemFontSize * 2.0
			case .large:   result = CNFont.systemFontSize * 4.0
			}
			return result
		}
	}

	static func fromValue(value val: CNValue) -> CNFont? {
		if let dict = val.toDictionary() {
			return fromValue(value: dict)
		} else {
			return nil
		}
	}

	static func fromValue(value val: Dictionary<String, CNValue>) -> CNFont? {
		if let nameval = val["name"], let sizeval = val["size"] {
			if let namestr = nameval.toString(), let sizenum = sizeval.toNumber() {
				return CNFont(name: namestr, size: CGFloat(sizenum.doubleValue))
			}
		}
		return nil
	}

	func toValue() -> Dictionary<String, CNValue> {
		#if os(OSX)
		let name: String   = self.familyName ?? "system"
		#else
		let name: String   = self.familyName
		#endif
		let size: NSNumber = NSNumber(floatLiteral: Double(self.pointSize))
		let result: Dictionary<String, CNValue> = [
			"name":	.stringValue(name),
			"size": .numberValue(size)
		]
		return result
	}
}
