/*
 * @file	CNFileHandle.swift
 * @brief	Define CNFileHandle class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation
import Darwin.POSIX.termios
import Darwin

// see https://stackoverflow.com/a/24335355/669586
private func initStruct<S>() -> S {
	let struct_pointer = UnsafeMutablePointer<S>.allocate(capacity: 1)
	let struct_memory = struct_pointer.pointee
	struct_pointer.deallocate()
	return struct_memory
}

private func enableRawMode(fileHandle: FileHandle, enable en: Bool){
	var raw: termios = initStruct()
	tcgetattr(fileHandle.fileDescriptor, &raw)
	if en {
		raw.c_lflag &= ~(UInt(ECHO | ICANON))
	} else {
		raw.c_lflag |=  (UInt(ECHO | ICANON))
	}
	tcsetattr(fileHandle.fileDescriptor, TCSAFLUSH, &raw);
}

extension FileHandle
{
	public func write(string str: String) {
		if let data = str.data(using: .utf8) {
			self.write(data)
		} else {
			CNLog(logLevel: .error, message: "Failed to convert", atFunction: #function, inFile: #file)
		}
	}

	public var availableString: String { get {
		let data = self.availableData
		if let str = String.stringFromData(data: data) {
			return str
		} else {
			CNLog(logLevel: .error, message: "Failed to convert", atFunction: #function, inFile: #file)
			return ""
		}
	}}

	public func closeHandle() -> NSError? {
		do {
			try self.close()
			return nil
		} catch {
			return NSError.fileError(message: "Failed to close fileHandle")
		}
	}

	public func setRawMode(enable en: Bool){
		enableRawMode(fileHandle: self, enable: en)
	}
}

