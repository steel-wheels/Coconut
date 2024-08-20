/*
 * @file	CNStandardFiles.swift
 * @brief	Define CNStandardFiles class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public class CNStandardFiles
{
	private static var mStandardFiles: CNStandardFiles? = nil

	public static var shared: CNStandardFiles {
		get {
			if let files = mStandardFiles {
				return files
			} else {
				let newfiles   = CNStandardFiles()
				mStandardFiles = newfiles
				return newfiles
			}
		}
	}

	public var input:   CNFile
	public var output:  CNFile
	public var error:   CNFile

	private init() {
		input  = CNInputFile(fileType: .standardIO, fileHandle: FileHandle.standardInput)
		output = CNOutputFile(fileType: .standardIO, fileHandle: FileHandle.standardOutput)
		error  = CNOutputFile(fileType: .standardIO, fileHandle: FileHandle.standardError)
	}
}

