/**
 * @file	CNPipe.swift
 * @brief	Define CNPipe class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public extension Pipe
{
	static let InterfaceName = "PipeIF"

	static func allocateInterfaceType(fileIF flif: CNInterfaceType) -> CNInterfaceType {
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: "fileForReading", type: .interfaceType(flif)),
			M(name: "fileorWriting",  type: .interfaceType(flif))
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	func fileForReading(fileType ftype: CNFile.FileType) -> CNInputFile {
		return CNInputFile(fileType: ftype, fileHandle: self.fileHandleForReading)
	}

	func fileForWriting(fileType ftype: CNFile.FileType) -> CNOutputFile {
		return CNOutputFile(fileType: ftype, fileHandle: self.fileHandleForWriting)
	}
}
