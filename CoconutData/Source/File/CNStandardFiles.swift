/*
 * @file	CNStandardFiles.swift
 * @brief	Define CNStandardFiles class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation

public class CNStandardFiles
{
        public static var input: CNInputFile { get {
                return CNInputFile(fileType: .standardIO, fileHandle: FileHandle.standardInput)
        }}

        public static var output: CNOutputFile { get {
                return CNOutputFile(fileType: .standardIO, fileHandle: FileHandle.standardOutput)
        }}

        public static var error: CNOutputFile { get {
                return CNOutputFile(fileType: .standardIO, fileHandle: FileHandle.standardError)
        }}
}

