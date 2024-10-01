/**
 * @file	CNColor.swift
 * @brief	Define CNColor class
 * @par Copyright
 *   Copyright (C) 2015-2021 Steel Wheels Project
 */

import Foundation

#if os(OSX)
import AppKit
public typealias CNColor = NSColor
//import Darwin.ncurses
#else
import UIKit
public typealias CNColor = UIColor
#endif

public class CNColors
{
	static let InterfaceName = "ColorsIF"

	static func allocateInterfaceType(colorIF colif: CNInterfaceType) -> CNInterfaceType {
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: "black",		type: .interfaceType(colif)),
			M(name: "red", 			type: .interfaceType(colif)),
			M(name: "green",		type: .interfaceType(colif)),
			M(name: "yellow",		type: .interfaceType(colif)),
			M(name: "blue",			type: .interfaceType(colif)),
			M(name: "magenta",		type: .interfaceType(colif)),
			M(name: "cyan",			type: .interfaceType(colif)),
			M(name: "white",		type: .interfaceType(colif)),
			M(name: "availableColorNames",	type: .arrayType(.stringType))
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	public static var black: 	CNColor { get { return CNColor.black		}}
	public static var red:		CNColor { get { return CNColor.red		}}
	public static var green:	CNColor { get { return CNColor.green		}}
	public static var yellow:	CNColor { get { return CNColor.yellow		}}
	public static var blue:		CNColor { get { return CNColor.blue		}}
	public static var magenta:	CNColor { get { return CNColor.magenta		}}
	public static var cyan:		CNColor { get { return CNColor.cyan		}}
	public static var white:	CNColor { get { return CNColor.white		}}
	public static var availableColorNames: Array<String> { get {
		var result: Array<String> = []
		#if os(OSX)
		for list in NSColorList.availableColorLists {
			if let name = list.name {
				result.append(name)
			}
		}
		#endif // os(OSX)
		return result
	}}
}

public protocol CNColorProtocol
{
	func toObject() -> NSObject
	static func from(object obj: NSObject) -> AnyObject?
}

public extension CNColor
{
	static let InterfaceName = "ColorIF"

	static func allocateInterfaceType() -> CNInterfaceType {
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: "r", type: .numberType),
			M(name: "g", type: .numberType),
			M(name: "b", type: .numberType),
			M(name: "a", type: .numberType)
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	static func color(withEscapeCode code: Int32) -> CNColor? {
		let result: CNColor?
		switch code {
		case 0:		result = CNColor.black
		case 1:		result = CNColor.red
		case 2:		result = CNColor.green
		case 3:		result = CNColor.yellow
		case 4:		result = CNColor.blue
		case 5:		result = CNColor.magenta
		case 6:		result = CNColor.cyan
		case 7:		result = CNColor.white
		default:
			CNLog(logLevel: .error, message: "Invalid escape color code: \(code)")
			result = nil
		}
		return result
	}

	var isClear: Bool {
		get { return self.alphaComponent == 0.0 }
	}

	func escapeCode() -> Int32 {
		let (red, green, blue, _) = self.toRGBA()
		let rbit : Int32 = red   >= 0.5 ? 1 : 0
		let gbit : Int32 = green >= 0.5 ? 1 : 0
		let bbit : Int32 = blue  >= 0.5 ? 1 : 0
		let rgb  : Int32 = (bbit << 2) | (gbit << 1) | rbit
		return rgb
	}

	#if os(iOS)
	var redComponent: CGFloat {
		get {
			let (red, _, _, _) = self.toRGBA()
			return red
		}
	}
	var greenComponent: CGFloat {
		get {
			let (_, green, _, _) = self.toRGBA()
			return green
		}
	}
	var blueComponent: CGFloat {
		get {
			let (_, _, blue, _) = self.toRGBA()
			return blue
		}
	}
	var alphaComponent: CGFloat {
		get {
			let (_, _, _, alpha) = self.toRGBA()
			return alpha
		}
	}
	#endif

	func toRGBA() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
		var red 	: CGFloat = 0.0
		var green	: CGFloat = 0.0
		var blue	: CGFloat = 0.0
		var alpha	: CGFloat = 0.0
		#if os(OSX)
			if let color = self.usingColorSpace(.deviceRGB) {
				color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
			} else {
				CNLog(logLevel: .error, message: "Failed to convert to rgb")
			}
		#else
			self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
		#endif
		return (red, green, blue, alpha)
	}

	static func fromValue(dictionary val: Dictionary<String, Any>) -> CNColor? {
		if let rnum = val["r"] as? NSNumber, let gnum = val["g"] as? NSNumber,
		   let bnum = val["b"] as? NSNumber, let anum = val["a"] as? NSNumber {
			return fromValue(r: rnum, g: gnum, b: bnum, a: anum)
		} else {
			return nil
		}
	}

	static func fromValue(value val: CNInterfaceValue) -> CNColor? {
		guard val.type.name == InterfaceName else {
			return nil
		}
		if let rval = val.get(name: "r"), let gval = val.get(name: "g"),
		   let bval = val.get(name: "b"), let aval = val.get(name: "a") {
			if let rnum = rval.toNumber(), let gnum = gval.toNumber(),
			   let bnum = bval.toNumber(), let anum = aval.toNumber() {
				return fromValue(r: rnum, g: gnum, b: bnum, a: anum)
			}
		}
		return nil
	}

	static func fromValue(r rnum: NSNumber, g gnum: NSNumber, b bnum: NSNumber, a anum: NSNumber) -> CNColor? {
		let r : CGFloat = CGFloat(rnum.floatValue)
		let g : CGFloat = CGFloat(gnum.floatValue)
		let b : CGFloat = CGFloat(bnum.floatValue)
		let a : CGFloat = CGFloat(anum.floatValue)
		#if os(OSX)
		return CNColor(calibratedRed: r, green: g, blue: b, alpha: a)
		#else
		return CNColor(red: r, green: g, blue: b, alpha: a)
		#endif
	}

	func toValue() -> CNInterfaceValue {
		let (r, g, b, a) = self.toRGBA()
		let ptypes: Dictionary<String, CNValue> = [
			"r":		.numberValue(NSNumber(floatLiteral: Double(r))),
			"g":		.numberValue(NSNumber(floatLiteral: Double(g))),
			"b":		.numberValue(NSNumber(floatLiteral: Double(b))),
			"a":		.numberValue(NSNumber(floatLiteral: Double(a)))
		]
		return CNInterfaceValue(types: CNColor.allocateInterfaceType(), values: ptypes)
	}

	func toData() -> Data? {
		do {
			return try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
		} catch {
			let err = error as NSError
			CNLog(logLevel: .error, message: "\(#file): \(err.description)")
		}
		return nil
	}

	static func decode(fromData data: Data) -> CNColor? {
		do {
			if let color = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [CNColor.self], from: data) as? CNColor {
				return color
			}
		} catch {
			let err = error as NSError
			CNLog(logLevel: .error, message: "\(#file): \(err.description)")
		}
		return nil
	}

	var rgbName: String {
		get {
			let result: String
			switch self.escapeCode() {
			case 0:		result = "black"
			case 1:		result = "red"
			case 2:		result = "green"
			case 3:		result = "yellow"
			case 4:		result = "blue"
			case 5:		result = "magenta"
			case 6:		result = "cyan"
			case 7:		result = "white"
			default:	result = "<UNKNOWN>"
			}
			return result
		}
	}
}

extension CNColor: CNColorProtocol
{
	public func toObject() -> NSObject {
		return self
	}

	public static func from(object obj: NSObject) -> AnyObject? {
		if let col = obj as? CNColor {
			return col
		} else {
			return nil
		}
	}
}

public class CNUIElementColors
{
        public struct AppearanceColor {
            var light:  CNColor
            var dark:   CNColor

            public init(light: CNColor, dark: CNColor) {
                self.light  = light
                self.dark   = dark
            }

            public func color(for style: CNInterfaceStyle) -> CNColor {
                switch style {
                case .light:    return self.light
                case .dark:     return self.dark
                }
            }
        }

        public static var rootBackgroundColor: AppearanceColor { get {
                return AppearanceColor(light: CNColor.white, dark: CNColor.black)
        }}

        public static var labelColor: AppearanceColor { get {
                return AppearanceColor(light: CNColor.blue,  dark: CNColor.cyan)
        }}

        public static var textColor: AppearanceColor { get {
                return labelColor
        }}

        public static var controlColor: AppearanceColor { get {
                return labelColor
        }}

        public static var controlBackgroundColor: AppearanceColor { get {
                return rootBackgroundColor
        }}

        public static var terminalForegroundColor: AppearanceColor { get {
                return labelColor
        }}

        public static var terminalBackgroundColor: AppearanceColor { get {
                return rootBackgroundColor
        }}

        public static var graphicsForegroundColor: AppearanceColor { get {
                return labelColor
        }}

        public static var graphicsBackgroundColor: AppearanceColor { get {
                return rootBackgroundColor
        }}
}

