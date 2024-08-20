/**
 * @file	CNTermiios.swift
 * @brief	Define CNTermios class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import Foundation

public class CNTermios
{
	private var mFileHandle:      FileHandle
	private var mCurrentTermios:  termios
	private var mOriginalTermios: termios

	public init(forFileHandle hdl: FileHandle) {
		mFileHandle      = hdl

		var newterm:termios = initStruct()
		tcgetattr(mFileHandle.fileDescriptor, &newterm)
		mCurrentTermios  = newterm
		mOriginalTermios = newterm
	}

	public func restore() {
		restoreTermios(fileHandle: mFileHandle, originalTerm: mOriginalTermios)
	}

	public func echo(enable en: Bool) {
		if en {
			mCurrentTermios.c_lflag |=  UInt(ECHO | ICANON)
		} else {
			mCurrentTermios.c_lflag &= ~UInt(ECHO | ICANON)
		}
		tcsetattr(mFileHandle.fileDescriptor, TCSAFLUSH, &mCurrentTermios);
	}
}

private func initStruct<S>() -> S {
    let struct_pointer = UnsafeMutablePointer<S>.allocate(capacity: 1)
    let struct_memory = struct_pointer.pointee
    struct_pointer.deallocate()
    return struct_memory
}

private func enableRawMode(fileHandle: FileHandle) -> termios {
    var raw: termios = initStruct()
    tcgetattr(fileHandle.fileDescriptor, &raw)

    let original = raw

    raw.c_lflag &= ~(UInt(ECHO | ICANON))
    tcsetattr(fileHandle.fileDescriptor, TCSAFLUSH, &raw);

    return original
}

private func restoreTermios(fileHandle: FileHandle, originalTerm: termios) {
    var term = originalTerm
    tcsetattr(fileHandle.fileDescriptor, TCSAFLUSH, &term);
}
