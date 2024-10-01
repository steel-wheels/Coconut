/*
 * @file	CNFile.swift
 * @brief	Define CNFile, CNTextFile protocols
 * @par Copyright
 *   Copyright (C) 2017-2023 Steel Wheels Project
 */

import Foundation

public class CNFile
{
	public static let InterfaceName = "FileIF"
	public static let EOF:String = "\(Character.EOT)"

	public enum FileType {
		case standardIO
		case file
	}

	public enum Char {
		case char(Character)
		case endOfFile
		case null
	}

	public enum Str {
		case str(String)
		case endOfFile
		case null
	}

	public enum Line {
		case line(String)
		case endOfFile
		case null
	}

	static func allocateInterfaceType() -> CNInterfaceType {
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: "getc",		type: .functionType(.nullable(.stringType), [])),
			M(name: "getl",		type: .functionType(.nullable(.stringType), [])),
			M(name: "put",		type: .functionType(.voidType, [.stringType])),
			M(name: "close",	type: .functionType(.voidType, []))
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	public static func open(forWriting url: URL) -> CNFile? {
		do {
			let path = url.path
			if FileManager.default.createFile(atPath: path, contents: nil, attributes: nil) {
				let handle = try FileHandle(forWritingTo: url)
				return CNOutputFile(fileType: .file, fileHandle: handle)
			}
			return nil
		} catch {
			return nil
		}
	}

	public static func open(forReading url: URL) -> CNFile? {
		do {
			let path = url.path
			if FileManager.default.createFile(atPath: path, contents: nil, attributes: nil) {
				let handle = try FileHandle(forWritingTo: url)
				return CNInputFile(fileType: .file, fileHandle: handle)
			}
			return nil
		} catch {
			return nil
		}
	}

	public static func isEOF(_ src: String) -> Bool {
		return src == CNFile.EOF
	}

	open var fileHandle: FileHandle { get {
		CNLog(logLevel: .error, message: "must be override", atFunction: #function, inFile: #file)
		return FileHandle.standardOutput
	}}

	open func close() {
		CNLog(logLevel: .error, message: "must be override", atFunction: #function, inFile: #file)
	}

	open func getc() -> CNFile.Char {
		CNLog(logLevel: .error, message: "must be override", atFunction: #function, inFile: #file)
		return .endOfFile
	}

	open func gets() -> CNFile.Str {
		CNLog(logLevel: .error, message: "must be override", atFunction: #function, inFile: #file)
		return .endOfFile
	}

	open func getl() -> CNFile.Line {
		CNLog(logLevel: .error, message: "must be override", atFunction: #function, inFile: #file)
		return .endOfFile
	}

	open func put(string str: String) {
		CNLog(logLevel: .error, message: "must be override", atFunction: #function, inFile: #file)
	}
}

public class CNInputFile: CNFile
{
	private var mFileHandle:	FileHandle
	private var mFileType:		FileType
	private var mTermios:		termios?
	private var mLock:		NSLock
	private var mBuffer:		String
	private var mReadDone:		Bool
	private var mClosed:		Bool

	public init(fileType ftype: FileType, fileHandle hdl: FileHandle) {
		mFileType		= ftype
		mFileHandle		= hdl
		mTermios		= nil
		mLock			= NSLock()
		mBuffer			= ""
		mReadDone		= false
		mClosed			= false
		super.init()
		//setupCallback(fileHandle: hdl)
	}

	deinit {
		close()
	}

	public var isStandardIO: Bool { get {
		let result: Bool
		switch mFileType {
		case .standardIO:	result = true
		default:		result = false
		}
		return result
	}}

	public override func close() {
		guard !mClosed else {
			return // already closesd
		}
		mFileHandle.setRawMode(enable: false)
		if !self.isStandardIO {
			if let err = mFileHandle.closeHandle() {
				CNLog(logLevel: .error, message: "[Error] " + err.toString(), atFunction: #function, inFile: #file)
			}
		}
		mClosed = true
	}

	public override var fileHandle: FileHandle { get {
		return mFileHandle
	}}

	public override func getc() -> CNFile.Char {
		updateBuffer(fileHandler: self.fileHandle)
		return getcFromBuffer()
	}

	public override func gets() -> CNFile.Str {
		updateBuffer(fileHandler: self.fileHandle)
		return getsFromBuffer()
	}

	public override func getl() -> CNFile.Line {
		updateBuffer(fileHandler: self.fileHandle)
		return getlFromBuffer()
	}

	private func updateBuffer(fileHandler hdl: FileHandle) {
		self.mLock.lock()
                switch mFileType {
                case .standardIO:
                        if hdl.hasAvailableData() {
                                let data = hdl.availableData
                                if !data.isEmpty {
                                        if let str = String(data: data, encoding: .utf8) {
                                                self.mBuffer += str
                                        } else {
                                                CNLog(logLevel: .error, message: "Failed to decode input", atFunction: #function, inFile: #file)
                                        }
                                }
                        }
                case .file:
                        let data = hdl.availableData
                        if !data.isEmpty {
                                if let str = String(data: data, encoding: .utf8) {
                                        self.mBuffer += str
                                } else {
                                        CNLog(logLevel: .error, message: "Failed to decode input", atFunction: #function, inFile: #file)
                                }
                        } else {
                                hdl.readabilityHandler = nil
                                self.mReadDone = true
                        }
                }
                self.mLock.unlock()
	}

	private func getcFromBuffer() -> Char {
		let result: Char
		mLock.lock()
		if let c = mBuffer.first {
			mBuffer.removeFirst()
			result = .char(c)
		} else {
			result = mReadDone ? .endOfFile : .null
		}
		mLock.unlock()
		return result
	}

	private func getsFromBuffer() -> Str {
		let result: Str
		mLock.lock()
		if mBuffer.count > 0 {
			result  = .str(mBuffer)
			mBuffer = ""
		} else {
			result = mReadDone ? .endOfFile : .null
		}
		mLock.unlock()
		return result
	}

	private func getlFromBuffer() -> Line {
		var result: Line = .null
		mLock.lock()
		let start = mBuffer.startIndex
		let end   = mBuffer.endIndex
		var idx   = start
		while idx < end {
			let c = mBuffer[idx]
			if c.isNewline {
				let next = mBuffer.index(after: idx)
				let head = mBuffer.prefix(upTo: next)
				let tail = mBuffer.suffix(from: next)
				mBuffer = String(tail)
				result = .line(String(head))
				break
			}
			idx = mBuffer.index(after: idx)
		}
		switch result {
		case .line(_):
			break
		case .null, .endOfFile:
			if mReadDone {
				if mBuffer.count > 0 {
					result  = .line(mBuffer)
					mBuffer = ""
				} else {
					result = .endOfFile
				}
			} else {
				result = .null
			}
		}
		mLock.unlock()
		return result
	}

	public func setRawMode(enable en: Bool){
		mFileHandle.setRawMode(enable: en)
	}
}

public class CNOutputFile: CNFile
{
	private var mFileHandle:	FileHandle
	private var mFileType:		FileType
	private var mClosed:		Bool

	public init(fileType ftype: FileType, fileHandle hdl: FileHandle){
		mFileHandle	= hdl
		mFileType	= ftype
		mClosed		= false
	}

	deinit {
		close()
	}

	public override var fileHandle: FileHandle { get {
		return mFileHandle
	}}

	public override func close() {
		guard !mClosed else {
			return
		}
		if !self.isStandardIO {
			if let err = mFileHandle.closeHandle() {
				CNLog(logLevel: .error, message: "[Error] " + err.toString(), atFunction: #function, inFile: #file)
			}
		}
		mClosed = true
	}

	public var isStandardIO: Bool { get {
		let result: Bool
		switch mFileType {
		case .standardIO:	result = true
		default:		result = false
		}
		return result
	}}

	public override func put(string str: String) {
		mFileHandle.write(string: str)
	}
}

