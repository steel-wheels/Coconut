/**
 * @file	CNCharacter.h
 * @brief	Extend character class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import Foundation

public extension Character
{
	static let InterfaceName = "CharIF"

	static func allocateInterfaceType() -> CNInterfaceType {
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: "etx", 	type: .stringType),
			M(name: "eot",	type: .stringType),
			M(name: "bel",	type: .stringType),
			M(name: "bs",	type: .stringType),
			M(name: "tab",	type: .stringType),
			M(name: "lf",	type: .stringType),
			M(name: "vt",	type: .stringType),
			M(name: "cr",	type: .stringType),
			M(name: "esc",	type: .stringType),
			M(name: "del",	type: .stringType),
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	/* Reference: http://jkorpela.fi/chars/c0.html */
	static let ETX		= Character("\u{03}")
	static let EOT		= Character("\u{04}")
	static let BEL		= Character("\u{07}")
	static let BS		= Character("\u{08}")
	static let TAB		= Character("\u{09}")
	static let LF		= Character("\u{0a}")
	static let VT		= Character("\u{0b}")
	static let CR		= Character("\u{0d}")
	static let ESC		= Character("\u{1b}")
	static let DEL		= Character("\u{7f}")

	var isLetterOrNumber: Bool {
		get { return self.isLetter || self.isNumber }
	}

	var isIdentifier: Bool { get {
		return self.isLetter || self.isNumber || (self == "_")
	}}

	func toInt() -> UInt32? {
		if self.isNumber {
			return self.unicodeScalars.first!.value - Unicode.Scalar("0").value
		}
		return nil
	}

	/* reference: http://www.asciitable.com */
	static func asciiCodeName(code value: Int) -> String? {
		let result: String?
		if 0x20 <= value && value <= 0x7E {
			/* Printable code */
			if let uval = UnicodeScalar(value) {
				result = "\(uval)"
			} else {
				result = nil
			}
		} else if value == 0x7f {
			result = "DEL"
		} else if 0x00 <= value && value <= 0x1f {
			/* Control code */
			switch value {
			case 0x00:	result = "NUL"		// Null
			case 0x01:	result = "SOH"		// Start of heading
			case 0x02:	result = "STX"		// Start of text
			case 0x03:	result = "ETX"		// End of text
			case 0x04:	result = "EOT"		// End of transmission
			case 0x05:	result = "ENQ"		// Enquiry
			case 0x06:	result = "ACK"		// Acknowledge
			case 0x07:	result = "BEL"		// Bell
			case 0x08:	result = "BS"		// Backspace
			case 0x09:	result = "TAB"		// Holizontal tab
			case 0x0a:	result = "LF"		// Line feed
			case 0x0b:	result = "VT"		// Vertical tab
			case 0x0c:	result = "FF"		// Form feed
			case 0x0d:	result = "CR"		// Carriage return
			case 0x0e:	result = "SO"		// Shift out
			case 0x0f:	result = "SI"		// Shift in
			case 0x10:	result = "DLE"		// Data line escape
			case 0x11:	result = "DC1"		// Device control 1
			case 0x12:	result = "DC2"		// Device control 2
			case 0x13:	result = "DC3"		// Device control 3
			case 0x14:	result = "DC4"		// Device control 4
			case 0x15:	result = "NAK"		// Negative acknowledge
			case 0x16:	result = "SYN"		// Synchronous idle
			case 0x17:	result = "ETB"		// End of trans block
			case 0x18:	result = "CAN"		// Cancel
			case 0x19:	result = "EM"		// End of medium
			case 0x1a:	result = "SUB"		// Substitute
			case 0x1b:	result = "ESC"		// Escape
			case 0x1c:	result = "FS"		// File separator
			case 0x1d:	result = "GS"		// Group separator
			case 0x1e:	result = "RS"		// Record separator
			case 0x1f:	result = "US"		// Unit separator
			default:	result = nil
			}
		} else {
			result = nil
		}
		return result
	}
}

