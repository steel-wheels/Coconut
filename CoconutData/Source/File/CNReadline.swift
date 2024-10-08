/**
 * @file	CNReadline.swift
 * @brief	Define CNReadline class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import Foundation

public class CNReadline
{
        private static let InterfaceName       = "ReadlineCoreIF"

	private var mLine:	String
	private var mIndex:	String.Index

	public var line: String  { get { return mLine }}
	public var isEmpty: Bool { get { return mLine.isEmpty }}

        static func allocateInterfaceType() -> CNInterfaceType {
                typealias M = CNInterfaceType.Member
                let members: Array<M> = [
                        M(name: "execute",                type: .functionType(.nullable(.stringType), [])),
                ]
                return CNInterfaceType(name: CNReadline.InterfaceName, base: nil, members: members)
        }

	public init() {
		self.mLine     = ""
		self.mIndex    = mLine.startIndex
	}

	public func insert(string str: String) {
		mLine.insert(contentsOf: str, at: mIndex)
		mIndex = mLine.index(mIndex, offsetBy: str.count)
	}

	public func delete() -> Bool {
		if mLine.startIndex < mIndex {
			let previdx = mLine.index(before: mIndex)
			mLine.remove(at: previdx)
			mIndex = previdx
			return true
		} else {
			return false
		}
	}

	public func cursorForward(_ num: Int) -> Int {
		var movenum = 0
		for _ in 0..<num {
			if mIndex < mLine.endIndex {
				movenum += 1
				mIndex = mLine.index(after: mIndex)
			} else {
				break
			}
		}
		return movenum
	}

	public func cursorBackward(_ num: Int) -> Int {
		var movenum = 0
		for _ in 0..<num {
			if mLine.startIndex < mIndex {
				movenum += 1
				mIndex = mLine.index(before: mIndex)
			} else {
				break
			}
		}
		return movenum
	}

	public func clear(){
		self.mLine  = ""
		self.mIndex = mLine.startIndex
	}

        public enum ExecutionResult {
                case doContinue
                case doExit
                case doExecute(String)
        }

        public func execute(console cons: CNFileConsole, applicationType apptype: CNApplicationType) -> ExecutionResult {
                var result: ExecutionResult
                switch cons.inputFile.gets() {
                case .str(let s):
                        switch CNEscapeCode.decode(string: s) {
                        case .ok(let codes):
                                result = .doContinue
                                for code in codes {
                                        if let str = execute(escapeCode: code, console: cons, type: apptype) {
                                                if !str.isEmpty {
                                                        result = .doExecute(str)
                                                }
                                        }
                                }
                        case .error(let err):
                                let newline = CNEscapeCode.newline.encode()
                                cons.error(string: "[Error] " + err.toString() + newline)
                                result = .doExit
                        }
                case .endOfFile:
                        result = .doExit
                case .null:
                        Thread.sleep(forTimeInterval: 0.01)
                        result = .doContinue
                }
                return result
        }

        private func execute(escapeCode ecode: CNEscapeCode, console cons: CNFileConsole, type typ: CNApplicationType) -> String? {
                var result: String? = nil

                /* decode the command */
                switch ecode {
                case .string(let str):
                        self.insert(string: str)
                        let ins: CNEscapeCode = .insertSpace(str.count)
                        print(string: ins.encode(), console: cons)
                        print(string: ecode.encode(), console: cons)
                case .delete:
                        if self.delete() {
                                switch typ {
                                case .terminal:
                                        let bs = CNEscapeCode.backspace.encode()
                                        print(string: bs,  console: cons)
                                        print(string: " ", console: cons)
                                        print(string: bs,  console: cons)
                                default:
                                        let dcode: CNEscapeCode = .delete
                                        print(string: dcode.encode(), console: cons)
                                }
                        }
                case .newline:
                        print(string: ecode.encode(), console: cons)
                        /* execute the command */
                        if !self.isEmpty {
                                result = self.line
                                self.clear()
                        }
                case .cursorForward(let num):
                        let delta = self.cursorForward(num)
                        if delta > 0 {
                                let newcode: CNEscapeCode = .cursorForward(delta)
                                print(string: newcode.encode(), console: cons)
                        }
                case .cursorBackward(let num):
                        let delta = self.cursorBackward(num)
                        if delta > 0 {
                                let newcode: CNEscapeCode = .cursorBackward(delta)
                                print(string: newcode.encode(), console: cons)
                        }
                default:
                        print(string: ecode.encode(), console: cons)
                }
                return result
        }

        private func print(string str: String, console cons: CNFileConsole){
                /* I dont know why this interval is required */
                cons.print(string: str)
                Thread.sleep(forTimeInterval: 0.001)
        }
}
