/**
 * @file	CNReadline.swift
 * @brief	Define CNReadline class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import Foundation

public class CNReadline
{
        public enum ApplicationType {
                case terminal
                case window
        }

	private var mLine:	String
	private var mIndex:	String.Index

	public var line: String  { get { return mLine }}
	public var isEmpty: Bool { get { return mLine.isEmpty }}

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

        public func execute(escapeCode ecode: CNEscapeCode, console cons: CNFileConsole, type typ: ApplicationType) -> String? {
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

        public func execute(console cons: CNFileConsole, type typ: ApplicationType) -> String? {
                var result: String? = nil
                switch cons.inputFile.gets() {
                case .str(let s):
                        switch CNEscapeCode.decode(string: s) {
                        case .ok(let codes):
                                for code in codes {
                                        if let str = execute(escapeCode: code, console: cons, type: typ){
                                                result = str
                                        }
                                }
                        case .error(let err):
                                cons.error(string: "[Error] " + err.toString() + "\n")
                        }
                case .endOfFile, .null:
                        result = "" // can not continue but no result
                }
                return result
        }

        private func print(string str: String, console cons: CNFileConsole){
                /* I dont know why this interval is required */
                cons.print(string: str)
                Thread.sleep(forTimeInterval: 0.001)
        }
}
