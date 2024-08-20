/**
 * @file	CNExitCode.swift
 * @brief	Define exit code
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public enum CNExitCode: Int
{
	public static let TypeName = "ExitCode"

	case noError		= 0
	case internalError	= 1
	case commandLineError	= 2
	case fileError		= 3
	case compileError	= 4
	case runtimeError	= 5
	case exception		= 6

	public var description: String {
		let result: String
		switch self {
		case .noError:		result = "No error"
		case .internalError:	result = "Internal error"
		case .commandLineError:	result = "Commandline error"
		case .fileError:	result = "File error"
		case .compileError:	result = "Syntax error"
		case .runtimeError:	result = "Runtime error"
		case .exception:	result = "Exception"
		}
		return result
	}

	public static func allocateEnumType() -> CNEnumType {
		let exitcode = CNEnumType(typeName: TypeName)
		exitcode.add(members: [
			"noError": 		.intValue(CNExitCode.noError.rawValue),
			"internalError":	.intValue(CNExitCode.internalError.rawValue),
			"commaneLineError":	.intValue(CNExitCode.commandLineError.rawValue),
			"fileError":		.intValue(CNExitCode.fileError.rawValue),
			"syntaxError":		.intValue(CNExitCode.compileError.rawValue),
			"runtimeError":		.intValue(CNExitCode.runtimeError.rawValue),
			"exception":		.intValue(CNExitCode.exception.rawValue)
		])
		return exitcode
	}
}

