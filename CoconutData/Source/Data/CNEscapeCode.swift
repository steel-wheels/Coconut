/**
 * @file	CNEscapeCode.swift
 * @brief	Define CNEscapeCode type
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

#if os(OSX)
import AppKit
#else
import UIKit
#endif

/* Reference:
 *  - https://en.wikipedia.org/wiki/ANSI_escape_code
 *  - https://qiita.com/PruneMazui/items/8a023347772620025ad6
 *  - http://www.termsys.demon.co.uk/vtansi.htm
 */
public enum CNEscapeCode
{
	case	string(String)
	case	eot					/* End of transmission (CTRL-D)	*/
	case	newline
	case	tab
	case	backspace				/* = moveLeft(1)		*/
	case	delete					/* Delete left 1 character	*/
	case	insertSpace(Int)			/* Inset spaces					*/
	case	cursorUp(Int)
	case	cursorDown(Int)
	case	cursorForward(Int)
	case	cursorBackward(Int)
	case	cursorNextLine(Int)			/* Moves cursor to beginning of the line n	*/
	case	cursorPreviousLine(Int)			/* Moves cursor to beginning of the line n	*/
	case	cursorHolizontalAbsolute(Int)		/* (Column) started from 1			*/
	case	cursorVisible(Bool)			/* make cursor visble:true/invisible/:false	*/
	case	saveCursorPosition			/* Save current cursor position			*/
	case	restoreCursorPosition			/* Update cursor position by saved one		*/
	case	cursorPosition(Int, Int)		/* (Row, Column) started from 1			*/
	case	eraceFromCursorToEnd			/* Clear from cursor to end of buffer		*/
	case	eraceFromCursorToBegin			/* Clear from begining of buffer to cursor	*/
	case	eraceEntireBuffer			/* Clear entire buffer				*/
	case	eraceFromCursorToRight			/* Clear from cursor to end of line		*/
	case	eraceFromCursorToLeft			/* Clear from cursor to beginning of line	*/
	case	eraceEntireLine				/* Clear entire line				*/
	case	scrollUp(Int)				/* Scroll up n lines				*/
	case	scrollDown(Int)				/* Scroll down n lines				*/
	case	resetAll				/* Clear text, reset cursor postion and tabstop	*/
	case	resetCharacterAttribute			/* Reset all arributes for character		*/
	case	boldCharacter(Bool)			/* Set/reset bold font				*/
	case	underlineCharacter(Bool)		/* Set/reset underline font			*/
	case	blinkCharacter(Bool)			/* Set/reset blink font				*/
	case	reverseCharacter(Bool)			/* Set/reset reverse character			*/
	case	foregroundColor(CNColor)		/* Set foreground color				*/
	case	defaultForegroundColor			/* Set default foreground color			*/
	case	backgroundColor(CNColor)		/* Set background color				*/
	case	defaultBackgroundColor			/* Reset default background color		*/

	case	requestScreenSize			/* Send request to receive screen size
							 * Ps = 18 -> Report the size of the text area in characters as CSI 8 ; height ; width t
							 */
	case	screenSize(Int, Int)			/* Set screen size (Width, Height)		*/
	case	selectAltScreen(Bool)			/* Do switch alternative screen (Yes/No)	*/
	/* Escape sequence for Xterm */
	case	setFontStyle(Int)			/* Set font style by numnber 			*/
	case	setFontSize(Int)			/* Set font size by number			*/

	public func description() -> String {
		var result: String
		switch self {
		case .string(let str):				result = "string(\"\(str)\")"
		case .eot:					result = "endOfTrans"
		case .newline:					result = "newline"
		case .tab:					result = "tab"
		case .backspace:				result = "backspace"
		case .delete:					result = "delete"
		case .insertSpace(let n):			result = "insertSpace(\(n))"
		case .cursorUp(let n):				result = "cursorUp(\(n))"
		case .cursorDown(let n):			result = "cursorDown(\(n))"
		case .cursorForward(let n):			result = "cursorForward(\(n))"
		case .cursorBackward(let n):			result = "cursorBack(\(n))"
		case .cursorNextLine(let n):			result = "cursorNextLine(\(n))"
		case .cursorPreviousLine(let n):		result = "cursorPreviousLine(\(n))"
		case .cursorVisible(let f):			result = "cursorVisible(\(f))"
		case .cursorHolizontalAbsolute(let pos):	result = "cursorHolizontalAbsolute(\(pos))"
		case .saveCursorPosition:			result = "saveCursorPosition"
		case .restoreCursorPosition:			result = "restoreCursorPosition"
		case .cursorPosition(let row, let col):		result = "cursorPoisition(\(row),\(col))"
		case .eraceFromCursorToEnd:			result = "eraceFromCursorToEnd"
		case .eraceFromCursorToBegin:			result = "eraceFromCursorToBegin"
		case .eraceEntireBuffer:			result = "eraceEntireBuffer"
		case .eraceFromCursorToRight:			result = "eraceFromCursorToRight"
		case .eraceFromCursorToLeft:			result = "eraceFromCursorToLeft"
		case .eraceEntireLine:				result = "eraceEntireLine"
		case .scrollUp(let lines):			result = "scrollUp(\(lines))"
		case .scrollDown(let lines):			result = "scrollDown(\(lines))"
		case .resetAll:					result = "resetAll"
		case .resetCharacterAttribute:			result = "resetCharacterAttribute"
		case .boldCharacter(let flag):			result = "boldCharacter(\(flag))"
		case .underlineCharacter(let flag):		result = "underlineCharacter(\(flag))"
		case .blinkCharacter(let flag):			result = "blinkCharacter(\(flag))"
		case .reverseCharacter(let flag):		result = "reverseCharacter(\(flag))"
		case .foregroundColor(let col):			result = "foregroundColor(\(col.rgbName))"
		case .defaultForegroundColor:			result = "defaultForegroundColor"
		case .backgroundColor(let col):			result = "backgroundColor(\(col.rgbName))"
		case .defaultBackgroundColor:			result = "defaultBackgroundColor"
		case .requestScreenSize:			result = "requestScreenSize"
		case .screenSize(let width, let height):	result = "screenSize(\(width), \(height))"
		case .selectAltScreen(let selalt):		result = "selectAltScreen(\(selalt))"
		case .setFontStyle(let fn):			result = "setFontStyle(\(fn))"
		case .setFontSize(let fs):			result = "setFontSize(\(fs))"
		}
		return result
	}

	public func encode() -> String {
		let ESC = Character.ESC
		var result: String
		switch self {
		case .string(let str):				result = str
		case .eot:					result = String(Character.EOT)
		case .newline:					result = String(Character.LF)
		case .tab:					result = String(Character.TAB)
		case .backspace:				result = String(Character.BS)
		case .delete:					result = String(Character.DEL)
		case .insertSpace(let n):			result = "\(ESC)[\(n)@"
		case .cursorUp(let n):				result = "\(ESC)[\(n)A"
		case .cursorDown(let n):			result = "\(ESC)[\(n)B"
		case .cursorForward(let n):			result = "\(ESC)[\(n)C"
		case .cursorBackward(let n):			result = "\(ESC)[\(n)D"
		case .cursorNextLine(let n):			result = "\(ESC)[\(n)E"
		case .cursorPreviousLine(let n):		result = "\(ESC)[\(n)F"
		case .cursorHolizontalAbsolute(let n):		result = "\(ESC)[\(n)G"
		case .cursorVisible(let f):			result = f ? "\(ESC)[?25h" : "\(ESC)[?25l"
		case .saveCursorPosition:			result = "\(ESC)7"
		case .restoreCursorPosition:			result = "\(ESC)8"
		case .cursorPosition(let row, let col):		result = "\(ESC)[\(row);\(col)H"
		case .eraceFromCursorToEnd:			result = "\(ESC)[0J"
		case .eraceFromCursorToBegin:			result = "\(ESC)[1J"
		case .eraceEntireBuffer:			result = "\(ESC)[2J"
		case .eraceFromCursorToRight:			result = "\(ESC)[0K"
		case .eraceFromCursorToLeft:			result = "\(ESC)[1K"
		case .eraceEntireLine:				result = "\(ESC)[2K"
		case .scrollUp(let lines):			result = "\(ESC)[\(lines)S"
		case .scrollDown(let lines):			result = "\(ESC)[\(lines)T"
		case .resetAll:					result = "\(ESC)c"
		case .resetCharacterAttribute:			result = "\(ESC)[0m"
		case .boldCharacter(let flag):			result = "\(ESC)[\(flag ? 1: 22)m"
		case .underlineCharacter(let flag):		result = "\(ESC)[\(flag ? 4: 24)m"
		case .blinkCharacter(let flag):			result = "\(ESC)[\(flag ? 5: 25)m"
		case .reverseCharacter(let flag):		result = "\(ESC)[\(flag ? 7: 27)m"
		case .foregroundColor(let col):			result = "\(ESC)[\(colorToCode(isForeground: true, color: col))m"
		case .defaultForegroundColor:			result = "\(ESC)[39m"
		case .backgroundColor(let col):			result = "\(ESC)[\(colorToCode(isForeground: false, color: col))m"
		case .defaultBackgroundColor:			result = "\(ESC)[49m"
		case .requestScreenSize:			result = "\(ESC)[18;0;0t"
		case .screenSize(let width, let height):	result = "\(ESC)[8;\(height);\(width)t"
		case .selectAltScreen(let selalt):		result = selalt ? "\(ESC)[?47h" : "\(ESC)[?47l"
		case .setFontStyle(let fn):			result = "\(ESC)]50;\(fn)\(Character.BEL)"
		case .setFontSize(let fn):			result = "\(ESC)]49;\(fn)\(Character.BEL)"
		}
		return result
	}

	private func colorToCode(isForeground isfg: Bool, color col: CNColor) -> Int32 {
		let result: Int32
		if isfg {
			result = col.escapeCode() + 30
		} else {
			result = col.escapeCode() + 40
		}
		return result
	}

	public func compare(code src: CNEscapeCode) -> Bool {
		var result = false
		switch self {
		case .string(let s0):
			switch src {
			case .string(let s1):			result = (s0 == s1)
			default:				break
			}
		case .eot:
			switch src {
			case .eot:				result = true
			default:				break
			}
		case .newline:
			switch src {
			case .newline:				result = true
			default:				break
			}
		case .tab:
			switch src {
			case .tab:				result = true
			default:				break
			}
		case .backspace:
			switch src {
			case .backspace:			result = true
			default:				break
			}
		case .delete:
			switch src {
			case .delete:				result = true
			default:				break
			}
		case .insertSpace(let n0):
			switch src {
			case .insertSpace(let n1):		result = (n0 == n1)
			default:				break
			}
		case .cursorUp(let n0):
			switch src {
			case .cursorUp(let n1):			result = (n0 == n1)
			default:				break
			}
		case .cursorDown(let n0):
			switch src {
			case .cursorDown(let n1):		result = (n0 == n1)
			default:				break
			}
		case .cursorForward(let n0):
			switch src {
			case .cursorForward(let n1):		result = (n0 == n1)
			default:				break
			}
		case .cursorBackward(let n0):
			switch src {
			case .cursorBackward(let n1):		result = (n0 == n1)
			default:				break
			}
		case .cursorNextLine(let n0):
			switch src {
			case .cursorNextLine(let n1):		result = (n0 == n1)
			default:				break
			}
		case .cursorPreviousLine(let n0):
			switch src {
			case .cursorPreviousLine(let n1):	result = (n0 == n1)
			default:				break
			}
		case .cursorHolizontalAbsolute(let n0):
			switch src {
			case .cursorHolizontalAbsolute(let n1):	result = (n0 == n1)
			default:				break
			}
		case .cursorVisible(let b0):
			switch src {
			case .cursorVisible(let b1):		result = (b0 == b1)
			default:				break
			}
		case .saveCursorPosition:
			switch src {
			case .saveCursorPosition:		result = true
			default:				break
			}
		case .restoreCursorPosition:
			switch src {
			case .restoreCursorPosition:		result = true
			default:				break
			}
		case .cursorPosition(let row0, let col0):
			switch src {
			case .cursorPosition(let row1, let col1):	result = (row0 == row1) && (col0 == col1)
			default:				break
			}
		case .eraceFromCursorToEnd:
			switch src {
			case .eraceFromCursorToEnd:		result = true
			default:				break
			}
		case .eraceFromCursorToBegin:
			switch src {
			case .eraceFromCursorToBegin:		result = true
			default:				break
			}
		case .eraceEntireBuffer:
			switch src {
			case .eraceEntireBuffer:		result = true
			default:				break
			}
		case .eraceFromCursorToRight:
			switch src {
			case .eraceFromCursorToRight:		result = true
			default:				break
			}
		case .eraceFromCursorToLeft:
			switch src {
			case .eraceFromCursorToLeft:		result = true
			default:				break
			}
		case .eraceEntireLine:
			switch src {
			case .eraceEntireLine:			result = true
			default:				break
			}
		case .scrollUp:
			switch src {
			case .scrollUp:				result = true
			default:				break
			}
		case .scrollDown:
			switch src {
			case .scrollDown:			result = true
			default:				break
			}
		case .resetAll:
			switch src {
			case .resetAll:				result = true
			default:				break
			}
		case .resetCharacterAttribute:
			switch src {
			case .resetCharacterAttribute:		result = true
			default:				break
			}
		case .boldCharacter(let flag0):
			switch src {
			case .boldCharacter(let flag1):		result = flag0 == flag1
			default:				break
			}
		case .underlineCharacter(let flag0):
			switch src {
			case .underlineCharacter(let flag1):	result = flag0 == flag1
			default:				break
			}
		case .blinkCharacter(let flag0):
			switch src {
			case .blinkCharacter(let flag1):	result = flag0 == flag1
			default:				break
			}
		case .reverseCharacter(let flag0):
			switch src {
			case .reverseCharacter(let flag1):	result = flag0 == flag1
			default:				break
			}
		case .foregroundColor(let col0):
			switch src {
			case .foregroundColor(let col1):	result = col0 == col1
			default:				break
			}
		case .defaultForegroundColor:
			switch src {
			case .defaultForegroundColor:		result = true
			default:				break
			}
		case .backgroundColor(let col0):
			switch src {
			case .backgroundColor(let col1):	result = col0 == col1
			default:				break
			}
		case .defaultBackgroundColor:
			switch src {
			case .defaultBackgroundColor:		result = true
			default:				break
			}
		case .requestScreenSize:
			switch src {
			case .requestScreenSize:		result = true
			default:				break
			}
		case .screenSize(let width0, let height0):
			switch src {
			case .screenSize(let width1, let height1):
				result = (width0 == width1) && (height0 == height1)
			default:				break
			}
		case .selectAltScreen(let s0):
			switch src {
			case .selectAltScreen(let s1):		result = (s0 == s1)
			default:				break
			}
		case .setFontStyle(let s0):
			switch src {
			case .setFontStyle(let s1):		result = (s0 == s1)
			default:				break
			}
		case .setFontSize(let s0):
			switch src {
			case .setFontSize(let s1):		result = (s0 == s1)
			default:				break
			}
		}
		return result
	}

	public enum DecodeResult {
		case	ok(Array<CNEscapeCode>)
		case	error(NSError)
	}

	public static func decode(string src: String) -> DecodeResult {
		do {
			let strm   = CNStringStream(string: src)
			let result = try decodeString(stream: strm)
			return .ok(result)
		} catch {
			return .error(error as NSError)
		}
	}

	private static func decodeString(stream strm: CNStringStream) throws -> Array<CNEscapeCode> {
		var result: Array<CNEscapeCode> = []
		var substr = ""
		while !strm.eof() {
			let c0 = try nextChar(stream: strm)
			switch c0 {
			case Character.ESC:
				/* Save current sub string */
				if substr.count > 0 {
					result.append(CNEscapeCode.string(substr))
					substr = ""
				}
				/* get next char */
				let c1 = try nextChar(stream: strm)
				switch c1 {
				case "[":
					/* Decode escape sequence */
					let commands = try decodeEscapeSequence(stream: strm)
					result.append(contentsOf: commands)
				case "]":
					/* Decode escape sequence for Xterm */
					let commands = try decodeEscapeSequenceForXterm(stream: strm)
					result.append(contentsOf: commands)
				case "7":
					result.append(.saveCursorPosition)
				case "8":
					result.append(.restoreCursorPosition)
				default:
					result.append(.string("\(c0)\(c1)"))
				}
			case Character.LF, "\n":
				/* Save current sub string */
				if substr.count > 0 {
					result.append(CNEscapeCode.string(substr))
					substr = ""
				}
				/* add newline */
				result.append(.newline)
			case Character.CR:
				break // ignore
			case Character.TAB:
				/* Save current sub string */
				if substr.count > 0 {
					result.append(CNEscapeCode.string(substr))
					substr = ""
				}
				/* add tab */
				result.append(.tab)
			case Character.BS:
				/* Save current sub string */
				if substr.count > 0 {
					result.append(CNEscapeCode.string(substr))
					substr = ""
				}
				/* add backspace */
				result.append(.backspace)
			case Character.DEL:
				/* Save current sub string */
				if substr.count > 0 {
					result.append(CNEscapeCode.string(substr))
					substr = ""
				}
				/* add delete */
				result.append(.delete)
			case Character.EOT:
				/* Save current sub string */
				if substr.count > 0 {
					result.append(CNEscapeCode.string(substr))
					substr = ""
				}
				/* add delete */
				result.append(.eot)
			default:
				substr.append(c0)
			}
		}
		/* Unsaved string */
		if substr.count > 0 {
			result.append(CNEscapeCode.string(substr))
			substr = ""
		}
		return result
	}

	private static func decodeEscapeSequence(stream strm: CNStringStream) throws -> Array<CNEscapeCode> {
		let tokens   = try decodeUntiCharacter(stream: strm, checher: { $0.isLetter })
		let tokennum = tokens.count
		if tokennum == 0 {
			throw incompleteSequenceError()
		}

		var results : Array<CNEscapeCode> = []
		let lasttoken	= tokens[tokennum - 1]
		if let c = lasttoken.getSymbol() {
			switch c {
			case "@": results.append(CNEscapeCode.insertSpace(try get1Parameter(from: tokens, forCommand: c)))
			case "A": results.append(CNEscapeCode.cursorUp(try get1Parameter(from: tokens, forCommand: c)))
			case "B": results.append(CNEscapeCode.cursorDown(try get1Parameter(from: tokens, forCommand: c)))
			case "C": results.append(CNEscapeCode.cursorForward(try get1Parameter(from: tokens, forCommand: c)))
			case "D": results.append(CNEscapeCode.cursorBackward(try get1Parameter(from: tokens, forCommand: c)))
			case "E": results.append(CNEscapeCode.cursorNextLine(try get1Parameter(from: tokens, forCommand: c)))
			case "F": results.append(CNEscapeCode.cursorPreviousLine(try get1Parameter(from: tokens, forCommand: c)))
			case "G": results.append(CNEscapeCode.cursorHolizontalAbsolute(try get1Parameter(from: tokens, forCommand: c)))
			case "H": let (row, col) = try get0Or2Parameter(from: tokens, forCommand: c)
				  results.append(CNEscapeCode.cursorPosition(row, col))
			case "J":
				let param = try get1Parameter(from: tokens, forCommand: c)
				switch param {
				case 0: results.append(CNEscapeCode.eraceFromCursorToEnd)
				case 1: results.append(CNEscapeCode.eraceFromCursorToBegin)
				case 2: results.append(CNEscapeCode.eraceEntireBuffer)
				default:
					throw invalidCommandAndParameterError(command: c, parameter: param)
				}
			case "K":
				let param = try get1Parameter(from: tokens, forCommand: c)
				switch param {
				case 0: results.append(CNEscapeCode.eraceFromCursorToRight)
				case 1: results.append(CNEscapeCode.eraceFromCursorToLeft)
				case 2: results.append(CNEscapeCode.eraceEntireLine)
				default:
					throw invalidCommandAndParameterError(command: c, parameter: param)
				}
			case "S":
				let param = try get1Parameter(from: tokens, forCommand: c)
				results.append(CNEscapeCode.scrollUp(param))
			case "T":
				let param = try get1Parameter(from: tokens, forCommand: c)
				results.append(CNEscapeCode.scrollDown(param))
			case "h":
				let param = try getDec1Parameter(from: tokens, forCommand: c)
				switch param {
				case 25: results.append(CNEscapeCode.cursorVisible(true))
				case 47: results.append(CNEscapeCode.selectAltScreen(true))	// XT_ALTSCRN
				default:
					throw invalidCommandAndParameterError(command: c, parameter: param)
				}
			case "l":
				let param = try getDec1Parameter(from: tokens, forCommand: c)
				switch param {
				case 25: results.append(CNEscapeCode.cursorVisible(false))
				case 47: results.append(CNEscapeCode.selectAltScreen(false))	// XT_ALTSCRN
				default:
					throw invalidCommandAndParameterError(command: c, parameter: param)
				}
			case "m":
				let params = try getParameters(from: tokens, count: tokennum - 1, forCommand: c)
				results.append(contentsOf: try CNEscapeCode.decodeCharacterAttributes(parameters: params))
			case "s":
				results.append(.saveCursorPosition)
			case "t":
				let (param0, param1, param2) = try get3Parameter(from: tokens, forCommand: c)
				switch param0 {
				case 8:
					results.append(.screenSize(param2, param1))
				case 18:
					results.append(.requestScreenSize)
				default:
					throw invalidCommandAndParameterError(command: c, parameter: param0)
				}
			case "u":
				results.append(.restoreCursorPosition)
			default:
				throw unknownCommandError(command: c)
			}
		} else {
			throw incompleteSequenceError()
		}
		return results
	}

	private static func decodeEscapeSequenceForXterm(stream strm: CNStringStream) throws -> Array<CNEscapeCode> {
		var results : Array<CNEscapeCode> = []
		let tokens   = try decodeUntiCharacter(stream: strm, checher: { $0 == Character.BEL })
		let tokennum = tokens.count
		/* 50 ; fn ST */
		if tokennum != 4 {
			throw incompleteSequenceError()
		}
		if let num = tokens[0].getInt() {
			switch num {
			case 49:
				if let param = tokens[2].getInt() {
					results.append(.setFontSize(param))
				} else {
					throw incompleteSequenceError()
				}
			case 50:
				if let param = tokens[2].getInt() {
					results.append(.setFontStyle(param))
				} else {
					throw incompleteSequenceError()
				}
			default:
				throw unexpectedNumberError(number: num)
			}
		} else {
			throw incompleteSequenceError()
		}
		return results
	}

	private static func decodeCharacterAttributes(parameters params: Array<Int>) throws -> Array<CNEscapeCode> {
		var results: Array<CNEscapeCode> = []

		var index: Int = 0
		let paramnum = params.count
		while index < paramnum {
			let param = params[index]
			if param == 0 {
				/* Reset status */
				results.append(.resetCharacterAttribute)
				/* Next index */
				index += 1
			} else if param == 1 {
				/* Reset status */
				results.append(.boldCharacter(true))
				/* Next index */
				index += 1
			} else if param == 4 {
				/* Reset status */
				results.append(.underlineCharacter(true))
				/* Next index */
				index += 1
			} else if param == 5 {
				/* Reset status */
				results.append(.blinkCharacter(true))
				/* Next index */
				index += 1
			} else if param == 7 {
				/* Reset status */
				results.append(.reverseCharacter(true))
				/* Next index */
				index += 1
			} else if param == 22 {
				/* Reset status */
				results.append(.boldCharacter(false))
				/* Next index */
				index += 1
			} else if param == 24 {
				/* Reset status */
				results.append(.underlineCharacter(false))
				/* Next index */
				index += 1
			} else if param == 25 {
				/* Reset status */
				results.append(.blinkCharacter(false))
				/* Next index */
				index += 1
			} else if param == 27 {
				/* Reset status */
				results.append(.reverseCharacter(false))
				/* Next index */
				index += 1
			} else if 30<=param && param<=37 {
				if let col = CNColor.color(withEscapeCode: Int32(param - 30)) {
					results.append(.foregroundColor(col))
				} else {
					throw invalidCommandAndParameterError(command: "m", parameter: param)
				}
				/* Next index */
				index += 1
			} else if param == 39 {
				results.append(.defaultForegroundColor)
				/* Next index */
				index += 1
			} else if 40<=param && param<=47 {
				if let col = CNColor.color(withEscapeCode: Int32(param - 40)) {
					results.append(.backgroundColor(col))
				} else {
					throw invalidCommandAndParameterError(command: "m", parameter: param)
				}
				/* Next index */
				index += 1
			} else if param == 49 {
				results.append(.defaultBackgroundColor)
				/* Next index */
				index += 1
			} else {
				throw invalidCommandAndParameterError(command: "m", parameter: param)
			}
		}
		return results
	}

	private static func getParameters(from tokens: Array<CNToken>, count tokennum: Int, forCommand c: Character) throws -> Array<Int> {
		if tokennum > 0 {
			var result: Array<Int> = []
			for token in tokens[0..<tokennum] {
				switch token.type {
				case .IntToken(let val):
					result.append(val)
				case .SymbolToken(let c):
					if c != ";" {
						throw unexpectedCharacterError(char: c)
					}
				default:
					throw incompleteSequenceError()
				}
			}
			return result
		} else {
			return [0]
		}
	}

	private static func get1Parameter(from tokens: Array<CNToken>, forCommand c: Character) throws -> Int {
		if tokens.count == 1 {
			return 1 // default value
		} else if tokens.count == 2 {
			if let param = tokens[0].getInt() {
				return param
			}
		}
		throw invalidCommandAndParameterError(command: c, parameter: -1)
	}

	private static func get0Or2Parameter(from tokens: Array<CNToken>, forCommand c: Character) throws -> (Int, Int) {
		if tokens.count == 4 {
			if let p0 = tokens[0].getInt(), let p1 = tokens[2].getInt() {
				return (p0, p1)
			}
		} else if tokens.count == 1 {
			return (1, 1)	// give default values
		}
		throw invalidCommandAndParameterError(command: c, parameter: -1)
	}

	private static func get3Parameter(from tokens: Array<CNToken>, forCommand c: Character) throws -> (Int, Int, Int) {
		if tokens.count == 6 {
			if let p0 = tokens[0].getInt(), let p1 = tokens[2].getInt(), let p2 = tokens[4].getInt() {
				return (p0, p1, p2)
			}
		}
		throw invalidCommandAndParameterError(command: c, parameter: -1)
	}

	private static func getDec1Parameter(from tokens: Array<CNToken>, forCommand c: Character) throws -> Int {
		if tokens.count == 3 {
			if tokens[0].getSymbol() == "?" {
				if let pm = tokens[1].getInt() {
					return pm
				}
			}
		}
		throw invalidCommandAndParameterError(command: c, parameter: -1)
	}

	private static func decodeUntiCharacter(stream strm: CNStringStream, checher ckr: (_ c: Character) -> Bool) throws -> Array<CNToken> {
		var result: Array<CNToken> = []
		while !strm.eof() {
			if let ival = try nextInt(stream: strm) {
				let newtoken = CNToken(type: .IntToken(ival), lineNo: 0)
				result.append(newtoken)
			} else {
				let c2 = try nextChar(stream: strm)
				let newtoken = CNToken(type: .SymbolToken(c2), lineNo: 0)
				result.append(newtoken)
				/* Finish at the alphabet */
				if ckr(c2) {
					return result
				}
			}

		}
		return result
	}

	private static func nextInt(stream strm: CNStringStream) throws -> Int? {
		let c0 = try nextChar(stream: strm)
		if let digit = c0.toInt() {
			var result = digit
			var docont = true
			while docont {
				let c2 = try nextChar(stream: strm)
				if let digit = c2.toInt() {
					result = result * 10 + digit
				} else {
					let _ = strm.ungetc() // unget c2
					docont = false
				}
			}
			return Int(result)
		} else {
			let _ = strm.ungetc() // unget c0
			return nil
		}
	}

	private static func nextChar(stream strm: CNStringStream) throws -> Character {
		if let c = strm.getc() {
			return c
		} else {
			throw incompleteSequenceError()
		}
	}

	private func hex(_ v: Int) -> String {
		return String(v, radix: 16)
	}

	private static func incompleteSequenceError() -> NSError {
		return NSError.parseError(message: "Incomplete sequence")
	}

	private static func unexpectedCharacterError(char c: Character) -> NSError {
		return NSError.parseError(message: "Unexpected character: \(c)")
	}

	private static func unexpectedNumberError(number n: Int) -> NSError {
		return NSError.parseError(message: "Unexpected nunber: \(n)")
	}

	private static func unknownCommandError(command cmd: Character) -> NSError {
		return NSError.parseError(message: "Unknown command: \(cmd)")
	}

	private static func invalidCommandAndParameterError(command cmd: Character, parameter param: Int) -> NSError {
		let paramstr = param > 0 ? ", paramter: \(param)" : ""
		return NSError.parseError(message: "Invalid command: \(cmd)" + paramstr)
	}
}

