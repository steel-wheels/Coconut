/**
 * @file	CNConsole.h
 * @brief	Define CNConsole class
 * @par Copyright
 *   Copyright (C) 2015-2016 Steel Wheels Project
 */

import Foundation

public protocol CNConsole {
	func print(string str: String)
	func error(string str: String)
	func log(string str: String)
	func scan() -> String?
}

public class CNDefaultConsole: CNConsole
{
	public static let InterfaceName = "ConsoleIF"

	public static func allocateInterfaceType() -> CNInterfaceType {
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: "print",	type: .functionType(.voidType, [.stringType])),
			M(name: "error",	type: .functionType(.voidType, [.stringType])),
			M(name: "log",		type: .functionType(.voidType, [.stringType])),
			M(name: "scan",		type: .functionType(.nullable(.stringType), []))
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	public init(){
	}

	public func print(string str: String){
		NSLog(str)
	}

	public func error(string str: String){
		NSLog(str)
	}

	public func log(string str: String){
		NSLog(str)
	}

	public func scan() -> String? {
		return nil
	}
}

public class CNFileConsole : CNConsole
{
	public var inputFile:		CNInputFile
	public var outputFile:		CNOutputFile
	public var errorFile:		CNOutputFile

	public init(input ifile: CNInputFile, output ofile: CNOutputFile, error efile: CNOutputFile){
		inputFile	= ifile
		outputFile	= ofile
		errorFile	= efile
	}

	public init() {
                inputFile	= CNStandardFiles.input
                outputFile	= CNStandardFiles.output
                errorFile	= CNStandardFiles.error
	}

	public func print(string str: String){
		outputFile.put(string: str)
	}

	public func error(string str: String){
		#if false
			let attr = CNEscapeCode.foregroundColor(.red).encode()
			let rev  = CNEscapeCode.resetCharacterAttribute.encode()
			errorFile.put(string: attr + str + rev)
		#else
			errorFile.put(string: str)
		#endif
	}

	public func log(string str: String){
                CNLog(message: str)
	}

	public func scan() -> String? {
		let result: String?
		switch inputFile.gets() {
		case .str(let s):
			result = s
		case .endOfFile, .null:
			result = nil
		}
		return result
	}
}

public class CNIndentedConsole: CNConsole
{
	private var mConsole:		CNConsole
	private var mIndentValue:	Int
	private var mIndentString:	String

	public required init(console cons: CNConsole){
		mConsole 	= cons
		mIndentValue	= 0
		mIndentString	= ""
	}

	public func print(string str: String){
		mConsole.print(string: mIndentString + str)
	}

	public func error(string str: String){
		mConsole.error(string: mIndentString + str)
	}

	public func log(string str: String){
		mConsole.log(string: mIndentString + str)
	}

	public func scan() -> String? {
		return mConsole.scan()
	}

	public func incrementIndent() {
		updateIndent(indent: mIndentValue + 1)
	}

	public func decrementIndent() {
		if mIndentValue > 0 {
			updateIndent(indent: mIndentValue - 1)
		}
	}

	public func updateIndent(indent idt: Int) {
		var result = ""
		for _ in 0..<idt {
			result = result + "  "
		}
		mIndentValue  = idt
		mIndentString = result
	}
}

public class CNBufferedConsole: CNConsole
{
	private var mOutputBuffer:	Array<String>
	private var mErrorBuffer:	Array<String>

	private var mOutputConsole: CNConsole?

	public init(){
		mOutputBuffer	= []
		mErrorBuffer	= []
		mOutputConsole	= nil
	}

	public var outputConsole: CNConsole? {
		get { return mOutputConsole }
		set(newcons){
			if let cons = newcons {
				flushOutput(console: cons)
				flushError(console: cons)
			}
			mOutputConsole = newcons
		}
	}

	public func print(string str: String){
		if let cons = mOutputConsole {
			flushOutput(console: cons)
			cons.print(string: str)
		} else {
			mOutputBuffer.append(str)
		}
	}

	public func error(string str: String){
		if let cons = mOutputConsole {
			flushError(console: cons)
			cons.error(string: str)
		} else {
			mErrorBuffer.append(str)
		}
	}

	public func log(string str: String){
		if let cons = mOutputConsole {
			cons.log(string: str)
		} else {
                        CNLog(message: str)
		}
	}

	private func flushOutput(console cons: CNConsole){
		for elm in mOutputBuffer {
			cons.print(string: elm)
		}
		mOutputBuffer = []
	}

	private func flushError(console cons: CNConsole){
		for elm in mErrorBuffer {
			cons.error(string: elm)
		}
		mErrorBuffer = []
	}

	public func scan() -> String? {
		if let cons = mOutputConsole {
			return cons.scan()
		} else {
			return nil
		}
	}
}

