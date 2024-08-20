/**
 * @file	CNSize.swift
 * @brief	Extend CGSize class
 * @par Copyright
 *   Copyright (C) 2016-2021 Steel Wheels Project
 */

#if os(OSX)
import AppKit
#else
import UIKit
#endif
import CoreGraphics

public extension CGSize
{
	static let InterfaceName = "SizeIF"

	static func allocateInterfaceType() -> CNInterfaceType {
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: "width",  type: .numberType),
			M(name: "height", type: .numberType)
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	static func fromValue(value val: CNInterfaceValue) -> CGSize? {
		guard val.type.name == InterfaceName else {
			return nil
		}
		if let wval = val.get(name: "width"), let hval = val.get(name: "height") {
			if let wnum = wval.toNumber(), let hnum = hval.toNumber() {
				let width  : CGFloat = CGFloat(wnum.doubleValue)
				let height : CGFloat = CGFloat(hnum.doubleValue)
				return CGSize(width: width, height: height)
			}
		}
		return nil
	}

	func toValue() -> CNInterfaceValue {
		let wnum = NSNumber(floatLiteral: Double(self.width))
		let hnum = NSNumber(floatLiteral: Double(self.height))
		let ptypes: Dictionary<String, CNValue> = [
			"width":  .numberValue(wnum),
			"height": .numberValue(hnum)
		]
		return CNInterfaceValue(types: CGSize.allocateInterfaceType(), values: ptypes)
	}

	func resizeWithKeepingAscpect(inWidth dstwidth: CGFloat) -> CGSize {
		guard dstwidth > 0.0 && self.width > 0.0 && self.height > 0.0 else {
			CNLog(logLevel: .error, message: "Invalid size", atFunction: #function, inFile: #file)
			return self
		}
		let ratio = self.width / self.height
		let newwidth  = dstwidth
		let newheight = dstwidth / ratio
		return CGSize(width: newwidth, height: newheight)
	}

	func resizeWithKeepingAscpect(inSize dst: CGSize) -> CGSize {
		guard dst.width > 0.0 && dst.height > 0.0 else {
			CNLog(logLevel: .error, message: "Invalid size", atFunction: #function, inFile: #file)
			return self
		}
		let reswidth, resheight: CGFloat
		let ratio = self.width / self.height
		if ratio >= 1.0 {
			/* width >= height */
			reswidth  = dst.width
			resheight = dst.width / ratio
		} else {
			/* width < height */
			reswidth  = dst.height * ratio
			resheight = dst.height
		}
		return CGSize(width: reswidth, height: resheight)
	}

	var description: String {
		get {
			let wstr = NSString(format: "%.2lf", self.width)
			let hstr = NSString(format: "%.2lf", self.height)
			return "{width:\(wstr), height:\(hstr)}"
		}
	}

    static func isSame(_ s0: CGSize, _ s1: CGSize) -> Bool {
        return (s0.width == s1.width) && (s0.height == s1.height)
    }

	static func maxSize(_ s0: CGSize, _ s1: CGSize) -> CGSize {
		let width  = max(s0.width,  s1.width)
		let height = max(s0.height, s1.height)
		return CGSize(width: width, height: height)
	}

	static func minSize(_ s0: CGSize, _ s1: CGSize) -> CGSize {
		let width  = max(min(s0.width,  s1.width),  0.0)
		let height = max(min(s0.height, s1.height), 0.0)
		return CGSize(width: width, height: height)
	}
}

public func CNIsSameSize(_ a: CGSize, _ b: CGSize) -> Bool {
	return (a.width == b.width) && (a.height == b.height)
}

public func CNExpandSize(_ sz: CGSize, byInsets insets: CNEdgeInsets) -> CGSize {
	let width  = insets.left + sz.width  + insets.right
	let height = insets.top  + sz.height + insets.bottom
	return CGSize(width: width, height: height)
}

public func CNExpandSize(_ sz: CGSize, space spc: CGFloat) -> CGSize {
	let width  = sz.width  + spc * 2.0
	let height = sz.height + spc * 2.0
	return CGSize(width: width, height: height)
}

public func CNScaledSize(size sz: CGSize, scale scl: CGFloat) -> CGSize {
	return CGSize(width: sz.width * scl, height: sz.height * scl)
}

public func CNShrinkSize(size sz: CGSize, delta dlt: CGFloat) -> CGSize {
	let width  = max(sz.width  - dlt * 2.0, 0.0)
	let height = max(sz.height - dlt * 2.0, 0.0)
	return CGSize(width: width, height: height)
}

public func CNUnionSize(_ a: CGSize, _ b: CGSize, doVertical vert: Bool, spacing space: CGFloat) -> CGSize
{
	if vert {
		let width  = max(a.width, b.width)
		let height = a.height + b.height + space
		return CGSize(width: width, height: height)
	} else {
		let width  = a.width + b.width + space
		let height = max(a.height, b.height)
		return CGSize(width: width, height: height)
	}
}


