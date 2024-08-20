/**
 * @file	CNEscapeSequence.swift
 * @brief	Define CNEscapeSequence type
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

#if os(OSX)
import AppKit
#else
import UIKit
#endif

public class CNEscapeSequences
{
	public static let InterfaceName = "EscapeSequencesIF"

	private static var mShared: CNEscapeSequences? = nil

	public static var shared: CNEscapeSequences { get {
		if let result = CNEscapeSequences.mShared {
			return result
		} else {
			let newobj = CNEscapeSequences()
			CNEscapeSequences.mShared = newobj
			return newobj
		}
	}}

	static func allocateInterfaceType(escapeSequenceIF eseq: CNInterfaceType, colorIF colif: CNInterfaceType) -> CNInterfaceType {
		let etype: CNValueType = .interfaceType(eseq)
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: "string",			type: .functionType(etype, [.stringType])),
			M(name: "eot",				type: .functionType(etype, [])),
			M(name: "newline",			type: .functionType(etype, [])),
			M(name: "tab",				type: .functionType(etype, [])),
			M(name: "backspace",			type: .functionType(etype, [])),
			M(name: "delete",			type: .functionType(etype, [])),
			M(name: "insertSpaces",			type: .functionType(etype, [.numberType])),
			M(name: "cursorUp",			type: .functionType(etype, [.numberType])),
			M(name: "cursorDown",			type: .functionType(etype, [.numberType])),
			M(name: "cursorForward",		type: .functionType(etype, [.numberType])),
			M(name: "cursorBackward",		type: .functionType(etype, [.numberType])),
			M(name: "cursorNextLine",		type: .functionType(etype, [.numberType])),
			M(name: "cursorPreviousLine",		type: .functionType(etype, [.numberType])),
			M(name: "cursorHolizontalAbsolute",	type: .functionType(etype, [.numberType])),
			M(name: "cursorVisible",		type: .functionType(etype, [.boolType])),
			M(name: "saveCursorPosition",		type: .functionType(etype, [])),
			M(name: "restoreCursorPosition",	type: .functionType(etype, [])),
			M(name: "cursorPosition",		type: .functionType(etype, [.numberType, .numberType])),
			M(name: "eraceFromCursorToEnd",		type: .functionType(etype, [])),
			M(name: "eraceFromCursorToBegin",	type: .functionType(etype, [])),
			M(name: "eraceEntireBuffer",		type: .functionType(etype, [])),
			M(name: "eraceFromCursorToRight",	type: .functionType(etype, [])),
			M(name: "eraceFromCursorToLeft",	type: .functionType(etype, [])),
			M(name: "eraceEntireLine",		type: .functionType(etype, [])),
			M(name: "scrollUp",			type: .functionType(etype, [.numberType])),
			M(name: "scrollDown",			type: .functionType(etype, [.numberType])),
			M(name: "resetAll",			type: .functionType(etype, [])),
			M(name: "resetCharacterAttribute",	type: .functionType(etype, [])),
			M(name: "boldCharacter",		type: .functionType(etype, [.boolType])),
			M(name: "underlineCharacter",		type: .functionType(etype, [.boolType])),
			M(name: "blinkCharacter",		type: .functionType(etype, [.boolType])),
			M(name: "reverseCharacter",		type: .functionType(etype, [.boolType])),
			M(name: "foregroundColor",		type: .functionType(etype, [.interfaceType(colif)])),
			M(name: "defaultForegroundColor",	type: .functionType(etype, [])),
			M(name: "backgroundColor",		type: .functionType(etype, [.interfaceType(colif)])),
			M(name: "defaultBackgroundColor",	type: .functionType(etype, [])),
			M(name: "requestScreenSize",		type: .functionType(etype, [])),
			M(name: "screenSize",			type: .functionType(etype, [.numberType, .numberType])),
			M(name: "selectAltScreen",		type: .functionType(etype, [.boolType])),
			M(name: "setFontStyle",			type: .functionType(etype, [.numberType])),
			M(name: "setFontSize",			type: .functionType(etype, [.numberType]))
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	public func str(string str: String) -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .string(str))
	}

	public func eot() -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .eot)
	}

	public func newline() -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .newline)
	}

	public func tab() -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .tab)
	}

	public func backspace() -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .backspace)
	}

	public func delete() -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .delete)
	}

	public func insertSpaces(count cnt: Int) -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .insertSpace(cnt))
	}

	public func cursorUp(count cnt: Int) -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .cursorUp(cnt))
	}

	public func cursorDown(count cnt: Int) -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .cursorDown(cnt))
	}

	public func cursorForward(count cnt: Int) -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .cursorForward(cnt))
	}

	public func cursorBackward(count cnt: Int) -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .cursorBackward(cnt))
	}

	public func cursorNextLine(count cnt: Int) -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .cursorNextLine(cnt))
	}

	public func cursorPreviousLine(count cnt: Int) -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .cursorPreviousLine(cnt))
	}

	public func cursorHolizontalAbsolute(count cnt: Int) -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .cursorHolizontalAbsolute(cnt))
	}

	public func cursorVisible(flag flg: Bool) -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .cursorVisible(flg))
	}

	public func saveCursorPosition() -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .saveCursorPosition)
	}

	public func restoreCursorPosition() -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .restoreCursorPosition)
	}

	public func cursorPosition(row rnum: Int, column cnum: Int) -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .cursorPosition(rnum, cnum))
	}

	public func eraceFromCursorToEnd() -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .eraceFromCursorToEnd)
	}

	public func eraceFromCursorToBegin() -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .eraceFromCursorToBegin)
	}

	public func eraceEntireBuffer() -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .eraceEntireBuffer)
	}

	public func eraceFromCursorToRight() -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .eraceFromCursorToRight)
	}

	public func eraceFromCursorToLeft() -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .eraceFromCursorToLeft)
	}

	public func eraceEntireLine() -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .eraceEntireLine)
	}

	public func scrollUp(count cnt: Int) -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .scrollUp(cnt))
	}

	public func scrollDown(count cnt: Int) -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .scrollDown(cnt))
	}

	public func resetAll() -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .resetAll)
	}

	public func resetCharacterAttribute() -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .resetCharacterAttribute)
	}

	public func boldCharacter(flag flg: Bool) -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .boldCharacter(flg))
	}

	public func underlineCharacter(flag flg: Bool) -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .underlineCharacter(flg))
	}

	public func blinkCharacter(flag flg: Bool) -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .blinkCharacter(flg))
	}

	public func reverseCharacter(flag flg: Bool) -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .reverseCharacter(flg))
	}

	public func foregroundColor(color col: CNColor) -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .foregroundColor(col))
	}

	public func defaultForegroundColor() -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .defaultForegroundColor)
	}

	public func backgroundColor(color col: CNColor) -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .backgroundColor(col))
	}

	public func defaultBackgroundColor() -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .defaultBackgroundColor)
	}

	public func requestScreenSize() -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .requestScreenSize)
	}

	public func screenSize(width wnum: Int, height hnum: Int) -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .screenSize(wnum, hnum))
	}

	public func selectAltScreen(flag flg: Bool) -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .selectAltScreen(flg))
	}

	public func setFontStyle(style stl: Int) -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .setFontStyle(stl))
	}

	public func setFontSize(size sz: Int) -> CNEscapeSequence {
		return CNEscapeSequence(escapeCode: .setFontSize(sz))
	}
}

public class CNEscapeSequence
{
	public static let InterfaceName = "EscapeSequenceIF"

	private var mEscapeCode:	CNEscapeCode

	public var code: CNEscapeCode { get {
		return mEscapeCode
	}}

	public init(escapeCode ecode: CNEscapeCode) {
		mEscapeCode = ecode
	}

	static func allocateInterfaceType() -> CNInterfaceType {
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: "toString", type: .functionType(.stringType, []))
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	public func toString() -> String {
		return mEscapeCode.encode()
	}
}
