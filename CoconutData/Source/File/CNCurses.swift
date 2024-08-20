/**
 * @file	CNCurses.swift
 * @brief	Define CNCurses class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

#if os(OSX)
import AppKit
#else
import UIKit
#endif

public class CNCurses
{
	public static let InterfaceName = "CursesIF"

	private var mTerminalController:	CNFileTerminalController
	private var mEscapeCodes:		CNEscapeCodes
	private var mTerminalInfo:		CNTerminalInfo
	private var mBuffer:			String
	private var mOrgForegroundColor:	CNColor
	private var mOrgBackgroundColor:	CNColor
	private var mLock:			NSLock

	public var foregroundColor: CNColor {
		get { return mTerminalInfo.foregroundColor }
		set(newcol) 	{
			mTerminalInfo.foregroundColor = newcol
			mEscapeCodes.foregroundColor(newcol)
			mTerminalController.execute(escapeCodes: mEscapeCodes.codes)
			mEscapeCodes.clear()
		}
	}

	public var backgroundColor:	CNColor {
		get 		{ return mTerminalInfo.backgroundColor 		}
		set(newcol)	{
			mTerminalInfo.backgroundColor = newcol
			mEscapeCodes.backgroundColor(newcol)
			mTerminalController.execute(escapeCodes: mEscapeCodes.codes)
			mEscapeCodes.clear()
		}
	}

	public init(console cons: CNFileConsole) {
		mTerminalController	= CNFileTerminalController(console: cons)
		mEscapeCodes		= CNEscapeCodes()
		mTerminalInfo		= CNTerminalInfo(width: 80, height: 25)
		mBuffer			= ""
		mOrgForegroundColor	= mTerminalInfo.foregroundColor
		mOrgBackgroundColor	= mTerminalInfo.backgroundColor
		mLock			= NSLock()
	}

	static func allocateInterfaceType(colorIF colif: CNInterfaceType) -> CNInterfaceType {
		let coltype: CNValueType = .interfaceType(colif)
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: "begin",		type: .functionType(.voidType, [])),
			M(name: "end",			type: .functionType(.voidType, [])),
			M(name: "width", 		type: .numberType),
			M(name: "height", 		type: .numberType),
			M(name: "foregroundColor",	type: coltype),
			M(name: "backgroundColor",	type: coltype),
			M(name: "moveTo",		type: .functionType(.voidType, [.numberType, .numberType])),
			M(name: "put",			type: .functionType(.voidType, [.stringType])),
            M(name: "clear",        type: .functionType(.voidType, []))
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	public var width:  Int { get { return mTerminalInfo.width	}}
	public var height: Int { get { return mTerminalInfo.height	}}

	public func begin() {
		/* get terminal size */
		mEscapeCodes.requestScreenSize()
		mTerminalController.execute(escapeCodes: mEscapeCodes.codes)
		mEscapeCodes.clear()

		let (width, height) = mTerminalController.screenSize()
		mTerminalInfo.width  = width
		mTerminalInfo.height = height

		/* Keep original colors */
		mOrgForegroundColor = mTerminalInfo.foregroundColor
		mOrgBackgroundColor = mTerminalInfo.backgroundColor

		/* Select alternative screen and erace entire screen */
		mEscapeCodes.selectAltScreen(true)
		mEscapeCodes.eraceEntireBuffer()
		mTerminalController.execute(escapeCodes: mEscapeCodes.codes)
		mEscapeCodes.clear()
	}

	public func end() {
		/* Restore original colors */
		mEscapeCodes.defaultForegroundColor()
		mEscapeCodes.defaultBackgroundColor()
		mTerminalController.execute(escapeCodes: mEscapeCodes.codes)
		mEscapeCodes.clear()

		/* Restore original screen */
		mEscapeCodes.selectAltScreen(false)
		mTerminalController.execute(escapeCodes: mEscapeCodes.codes )
		mEscapeCodes.clear()
	}

	public func moveTo(x xpos: Int, y ypos: Int) {
		let col  = clip(value: xpos, min: 0, max: mTerminalInfo.width  - 1)
		let row  = clip(value: ypos, min: 0, max: mTerminalInfo.height - 1)
		mEscapeCodes.cursorPosition(row+1, col+1)
		mTerminalController.execute(escapeCodes: mEscapeCodes.codes)
		mEscapeCodes.clear()
	}

	public func put(string str: String) {
		mEscapeCodes.string(str)
		mTerminalController.execute(escapeCodes: mEscapeCodes.codes)
		mEscapeCodes.clear()
	}

    public func clear() {
        mEscapeCodes.eraceEntireBuffer()
        mTerminalController.execute(escapeCodes: mEscapeCodes.codes)
        mEscapeCodes.clear()
    }

	public func inkey() -> Character? {
		let result: Character?
		mLock.lock()
		if let str = mTerminalController.console.scan() {
			mBuffer += str
		}
		if let c = mBuffer.first {
			mBuffer.removeFirst()
			result  = c
		} else {
			result  = nil
		}
		mLock.unlock()
		return result
	}

	public func fill(x xpos: Int, y ypos: Int, width dwidth: Int, height dheight: Int, char c: Character) {
		let x0 = clip(value: xpos, min: 0, max: mTerminalInfo.width  - 1)
		let y0 = clip(value: ypos, min: 0, max: mTerminalInfo.height - 1)

		let x1 = clip(value: xpos + dwidth,  min: 0, max: mTerminalInfo.width)
		let y1 = clip(value: ypos + dheight, min: 0, max: mTerminalInfo.height)

		let len = x1 - x0
		if len > 0 && y0 < y1 {
			mEscapeCodes.foregroundColor(mTerminalInfo.foregroundColor)
			mEscapeCodes.backgroundColor(mTerminalInfo.backgroundColor)
			mTerminalController.execute(escapeCodes: mEscapeCodes.codes)
			mEscapeCodes.clear()

			let str = String(repeating: c, count: len)
			for y in y0..<y1 {
				moveTo(x: x0, y: y)
				put(string: str)
			}
		}
	}

	private func clip(value v: Int, min minv: Int, max maxv: Int) -> Int {
		return max(minv, min(maxv, v))
	}
}
