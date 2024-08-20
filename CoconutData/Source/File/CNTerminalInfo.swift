/**
 * @file	CNTerminalInfoi.swift
 * @brief	Define CNTerminalInfo class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

#if os(OSX)
import AppKit
#else
import UIKit
#endif

public class CNTerminalInfo
{
	public var	isAlternative	: Bool

	public var 	width		: Int
	public var	height		: Int

	public var	foregroundColor	: CNColor
	public var	backgroundColor	: CNColor

	public var	doBold		: Bool
	public var	doItalic	: Bool
	public var	doUnderline	: Bool
	public var 	doBlink		: Bool
	public var	doReverse	: Bool

	public var defaultForegroundColor: CNColor { get {
		let tpref = CNPreference.shared.viewPreference
		return tpref.textColor(status: .normal)
	}}

	public var defaultBackgroundColor: CNColor { get {
		let tpref = CNPreference.shared.viewPreference
        return tpref.terminalBackgroundColor()
	}}

	public init(width widthval: Int, height heightval: Int) {
		isAlternative		= false
		width			= widthval
		height			= heightval

		let vpref = CNPreference.shared.viewPreference
		foregroundColor		= vpref.terminalForegroundColor()
		backgroundColor		= vpref.terminalBackgroundColor()
		doBold			= false
		doItalic		= false
		doUnderline		= false
		doBlink			= false
		doReverse		= false
	}

	public func reset() {
		let vpref = CNPreference.shared.viewPreference
        foregroundColor		= vpref.terminalForegroundColor()
        backgroundColor		= vpref.terminalBackgroundColor()
		doBold			= false
		doItalic		= false
		doUnderline		= false
		doBlink			= false
		doReverse		= false
	}
}
