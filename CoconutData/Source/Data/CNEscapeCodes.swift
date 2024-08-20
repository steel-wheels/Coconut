/**
 * @file	CNEscapeCodes.swift
 * @brief	Define CNEscapeCodes type
 * @par Copyright
 *   Copyright (C) 2023  Steel Wheels Project
 */

#if os(OSX)
import AppKit
#else
import UIKit
#endif

public protocol CNEscapeCoding
{
	func execute() -> Any?

	func string(_ str: String)
	func newline()
	func tab()
	func backspace()
	func delete()
	func insertSpace(_ num: Int)
	func cursorUp(_ line: Int)
	func cursorDown(_ line: Int)
	func cursorForward(_ line: Int)
	func cursorBackward(_ line: Int)
	func cursorNextLine(_ line: Int)
	func cursorPreviousLine(_ line: Int)
	func cursorHolizontalAbsolute(_ line: Int)
	func cursorVisible(_ vis: Bool)
	func saveCursorPosition()
	func restoreCursorPosition()
	func cursorPosition(_ row: Int, _ column: Int)	// Started from 1
	func eraceFromCursorToEnd()
	func eraceFromCursorToBegin()
	func eraceEntireBuffer()
	func eraceFromCursorToRight()
	func eraceFromCursorToLeft()
	func eraceEntireLine()
	func scrollUp(_ line: Int)
	func scrollDown(_ line: Int)
	func resetAll()
	func resetCharacterAttribute()
	func boldCharacter(_ enable: Bool)
	func underlineCharacter(_ enable: Bool)
	func blinkCharacter(_ enable: Bool)
	func reverseCharacter(_ enable: Bool)
	func foregroundColor(_ color: CNColor)
	func defaultForegroundColor()
	func backgroundColor(_ color: CNColor)
	func defaultBackgroundColor()
	func requestScreenSize()
	func screenSize(_ width: Int, _ height:Int)
	func selectAltScreen(_ enable: Bool)
	func setFontStyle(_ style: CNFont.Style)
	func setFontSize(_ size: CNFont.Size)
}

open class CNEscapeCodes: CNEscapeCoding
{
	public static let InterfaceName = "EscapeCodesIF"

	private var mCodes:	Array<CNEscapeCode>
	public var codes:	Array<CNEscapeCode> { get { return mCodes }}

	static func allocateInterfaceType(colorIF colif: CNInterfaceType) -> CNInterfaceType {
		typealias M = CNInterfaceType.Member

		let fontstyleif = CNFont.Style.allocateEnumType()
		let fontsizeif  = CNFont.Size.allocateEnumType()
		let members: Array<M> = [
			M(name: "execute",			type: .functionType(.nullable(.anyType), [])),
			M(name: "string",			type: .functionType(.voidType, [.stringType])),
			M(name: "newline",			type: .functionType(.voidType, [])),
			M(name: "tab",				type: .functionType(.voidType, [])),
			M(name: "backspace",			type: .functionType(.voidType, [])),
			M(name: "delete",			type: .functionType(.voidType, [])),
			M(name: "insertSpace",			type: .functionType(.voidType, [.numberType])),
			M(name: "cursorUp", 			type: .functionType(.voidType, [.numberType])),
			M(name: "cursorDown", 			type: .functionType(.voidType, [.numberType])),
			M(name: "cursorForward", 		type: .functionType(.voidType, [.numberType])),
			M(name: "cursorBackward", 		type: .functionType(.voidType, [.numberType])),
			M(name: "cursorNextLine", 		type: .functionType(.voidType, [.numberType])),
			M(name: "cursorPreviousLine", 		type: .functionType(.voidType, [.numberType])),
			M(name: "cursorHolizontalAbsolute", 	type: .functionType(.voidType, [.numberType])),
			M(name: "cursorVisible",		type: .functionType(.voidType, [.boolType])),
			M(name: "saveCursorPosition", 		type: .functionType(.voidType, [])),
			M(name: "restoreCursorPosition",	type: .functionType(.voidType, [])),
			M(name: "cursorPosition",		type: .functionType(.voidType, [.numberType, .numberType])),
			M(name: "eraceFromCursorToEnd",		type: .functionType(.voidType, [])),
			M(name: "eraceFromCursorToBegin",	type: .functionType(.voidType, [])),
			M(name: "eraceEntireBuffer",		type: .functionType(.voidType, [])),
			M(name: "eraceFromCursorToRight",	type: .functionType(.voidType, [])),
			M(name: "eraceFromCursorToLeft",	type: .functionType(.voidType, [])),
			M(name: "eraceEntireLine",		type: .functionType(.voidType, [])),
			M(name: "scrollUp",			type: .functionType(.voidType, [.numberType])),
			M(name: "scrollDown",			type: .functionType(.voidType, [.numberType])),
			M(name: "resetAll",			type: .functionType(.voidType, [])),
			M(name: "resetCharacterAttribute",	type: .functionType(.voidType, [])),
			M(name: "boldCharacter",		type: .functionType(.voidType, [.boolType])),
			M(name: "underlineCharacter",		type: .functionType(.voidType, [.boolType])),
			M(name: "blinkCharacter",		type: .functionType(.voidType, [.boolType])),
			M(name: "reverseCharacter",		type: .functionType(.voidType, [.boolType])),
			M(name: "foregroundColor",		type: .functionType(.voidType, [.interfaceType(colif)])),
			M(name: "defaultForegroundColor",	type: .functionType(.voidType, [])),
			M(name: "backgroundColor",		type: .functionType(.voidType, [.interfaceType(colif)])),
			M(name: "defaultBackgroundColor",	type: .functionType(.voidType, [])),
			M(name: "requestScreenSize",		type: .functionType(.voidType, [])),
			M(name: "screenSize",			type: .functionType(.voidType, [.numberType, .numberType])),
			M(name: "selectAltScreen",		type: .functionType(.voidType, [.boolType])),
			M(name: "setFontStyle",			type: .functionType(.voidType, [.enumType(fontstyleif)])),
			M(name: "setFontSize",			type: .functionType(.voidType, [.enumType(fontsizeif)]))
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	public init() {
		mCodes = []
	}

	public func clear() {
		mCodes = []
	}

	public func execute() -> Any? {
		NSLog("[Error] The method \(#function) in \(#file) is not supported")
		return nil
	}

	public func append(escapeCode ecode: CNEscapeCode){
		mCodes.append(ecode)
	}

	public func string(_ str: String) {
		mCodes.append(.string(str))
	}

	public func newline(){
		mCodes.append(.newline)
	}

	public func tab(){
		mCodes.append(.tab)
	}

	public func backspace() {
		mCodes.append(.backspace)
	}

	public func delete(){
		mCodes.append(.delete)
	}

	public func insertSpace(_ num: Int) {
		mCodes.append(.insertSpace(num))
	}

	public func cursorUp(_ line: Int) {
		mCodes.append(.cursorUp(line))
	}

	public func cursorDown(_ line: Int) {
		mCodes.append(.cursorDown(line))
	}

	public func cursorForward(_ line: Int) {
		mCodes.append(.cursorForward(line))
	}

	public func cursorBackward(_ line: Int) {
		mCodes.append(.cursorBackward(line))
	}

	public func cursorNextLine(_ num: Int) {
		mCodes.append(.cursorNextLine(num))
	}

	public func cursorPreviousLine(_ num: Int) {
		mCodes.append(.cursorPreviousLine(num))
	}

	public func cursorHolizontalAbsolute(_ num: Int) {
		mCodes.append(.cursorHolizontalAbsolute(num))
	}

	public func cursorVisible(_ dovis: Bool) {
		mCodes.append(.cursorVisible(dovis))
	}

	public func saveCursorPosition() {
		mCodes.append(.saveCursorPosition)
	}

	public func restoreCursorPosition() {
		mCodes.append(.restoreCursorPosition)
	}

	public func cursorPosition(_ num0: Int, _ num1: Int) {
		mCodes.append(.cursorPosition(num0, num1))
	}

	public func eraceFromCursorToEnd() {
		mCodes.append(.eraceFromCursorToEnd)
	}

	public func eraceFromCursorToBegin() {
		mCodes.append(.eraceFromCursorToBegin)
	}

	public func eraceEntireBuffer() {
		mCodes.append(.eraceEntireBuffer)
	}

	public func eraceFromCursorToRight() {
		mCodes.append(.eraceFromCursorToRight)
	}

	public func eraceFromCursorToLeft() {
		mCodes.append(.eraceFromCursorToLeft)
	}

	public func eraceEntireLine() {
		mCodes.append(.eraceEntireLine)
	}

	public func scrollUp(_ num: Int) {
		mCodes.append(.scrollUp(num))
	}

	public func scrollDown(_ num: Int) {
		mCodes.append(.scrollDown(num))
	}

	public func resetAll() {
		mCodes.append(.resetAll)
	}

	public func resetCharacterAttribute() {
		mCodes.append(.resetCharacterAttribute)
	}

	public func boldCharacter(_ flag: Bool) {
		mCodes.append(.boldCharacter(flag))
	}

	public func underlineCharacter(_ flag: Bool) {
		mCodes.append(.underlineCharacter(flag))
	}

	public func blinkCharacter(_ flag: Bool) {
		mCodes.append(.blinkCharacter(flag))
	}

	public func reverseCharacter(_ flag: Bool) {
		mCodes.append(.reverseCharacter(flag))
	}

	public func foregroundColor(_ col: CNColor) {
		mCodes.append(.foregroundColor(col))
	}

	public func defaultForegroundColor() {
		mCodes.append(.defaultForegroundColor)
	}

	public func backgroundColor(_ col: CNColor) {
		mCodes.append(.backgroundColor(col))
	}

	public func defaultBackgroundColor() {
		mCodes.append(.defaultBackgroundColor)
	}

	public func requestScreenSize() {
		mCodes.append(.requestScreenSize)
	}

	public func screenSize(_ num0: Int, _ num1: Int) {
		mCodes.append(.screenSize(num0, num1))
	}

	public func selectAltScreen(_ flag: Bool) {
		mCodes.append(.selectAltScreen(flag))
	}

	public func setFontStyle(_ style: CNFont.Style) {
		mCodes.append(.setFontStyle(style.rawValue))
	}

	public func setFontSize(_ size: CNFont.Size) {
		mCodes.append(.setFontSize(size.rawValue))
	}
}

