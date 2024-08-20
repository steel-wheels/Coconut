/**
 * @file	CNTerminalController.swift
 * @brief	Define CNTerminalController class
 * @par Copyright
 *   Copyright (C) 2023  Steel Wheels Project
 */

import Foundation

public protocol CNTerminalController
{
	func execute(escapeCode ecode: CNEscapeCode)
	func execute(escapeCodes ecodes: Array<CNEscapeCode>)
	func screenSize() -> (Int, Int)
}

public class CNFileTerminalController: CNTerminalController
{
	private var mConsole: CNFileConsole

	public var console: CNFileConsole { get { return mConsole }}

	public init(console cons: CNFileConsole) {
		mConsole = cons
	}

	public func execute(escapeCode ecode: CNEscapeCode) {
		switch ecode {
		case .delete:
			/* Replace .delete by .bs + " + bs */
			let bs =  CNEscapeCode.backspace.encode()
			mConsole.outputFile.put(string: bs)
			mConsole.outputFile.put(string: " ")
			mConsole.outputFile.put(string: bs)
		default:
			mConsole.outputFile.put(string: ecode.encode())
		}
	}

	public func execute(escapeCodes ecodes: Array<CNEscapeCode>) {
		for ecode in ecodes {
			execute(escapeCode: ecode)
		}
	}

	public func screenSize() -> (Int, Int) {
		let retstr = waitInputString(lastChar: "t")
		switch CNEscapeCode.decode(string: retstr) {
		case .ok(let codes):
			for code in codes {
				switch code {
				case .screenSize(let width, let height):
					return (width, height)
				default:
					CNLog(logLevel: .error, message: "Unexpected escape code: \(code.description())", atFunction: #function, inFile: #file)
				}
			}
		case .error(let err):
			CNLog(logLevel: .error, message: "Unexpected return code: \(err.toString())", atFunction: #function, inFile: #file)
		}
		return (80, 25)	// dummy value
	}

	private func waitInputString(lastChar lastc: Character) -> String {
		var result: String = ""
		var docont: Bool   = true
		while docont {
			let ch = mConsole.inputFile.getc()
			switch ch {
			case .char(let c):
				result.append(c)
				if c == lastc {
					docont = false
				}
			case .endOfFile:
				docont = false
			case .null:
				break // continue
			}
		}
		return result
	}
}
