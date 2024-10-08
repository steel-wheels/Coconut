/**
 * @file	UTFileManager.swift
 * @brief	Test function for FileManager class
 * @par Copyright
 *   Copyright (C) 2020Steel Wheels Project
 */

import CoconutData
import Foundation

public func testFileManager(console cons: CNConsole) -> Bool
{
	var result   = true
	let fmanager = FileManager.default

	let curdir	= CNEnvironment.shared.currentDirectory
	let plisturl	= fmanager.fullPath(pathString: "./CoconutData.framework/Resources/Info.plist", baseURL: curdir)
	let nonurl	= fmanager.fullPath(pathString: "./CoconutData.framework/Resources/Info.plist-2", baseURL: curdir)
	//cons.print(string: "fullpath: \(plisturl.path)\n")

	cons.print(string: "Test: fileExists -> ")
	if fmanager.fileExists(atURL: plisturl) {
		cons.print(string: "OK\n")
	} else {
		cons.print(string: "NG -> File \(plisturl.path) is NOT exist\n")
		result = false
	}
	cons.print(string: "Test: fileExists -> ")
	if fmanager.fileExists(atURL: nonurl) {
		cons.print(string: "NG -> File \(nonurl.path) is exist\n")
		result = false
	} else {
		cons.print(string: "OK\n")
	}

	cons.print(string: "Test: isAccessible (Read) -> ")
	if fmanager.isAccessible(pathString: plisturl.path, accessType: .ReadAccess) {
		cons.print(string: "OK\n")
	} else {
		cons.print(string: "NG -> File \(plisturl.path) can not be read\n")
		result = false
	}
	cons.print(string: "Test: isAccessible (Read) -> ")
	if fmanager.isAccessible(pathString: nonurl.path, accessType: .ReadAccess) {
		cons.print(string: "NG -> File \(nonurl.path) can be read\n")
		result = false
	} else {
		cons.print(string: "OK\n")
	}

	cons.print(string: "Test: isAccessible (CurDir) -> ")
	if fmanager.isAccessible(pathString: curdir.path, accessType: .AppendAccess) {
		cons.print(string: "OK\n")
	} else {
		cons.print(string: "NG -> File \(curdir) can be read\n")
		result = false
	}

	let docdir = FileManager.default.documentDirectory
	cons.print(string: "doc-dir: \(docdir.absoluteString)\n")

	cons.print(string: "rel: /tmp/a -> ")
	let url0 = fmanager.fullPath(pathString: "/tmp/a", baseURL: docdir)
	if url0.path == "/tmp/a" {
		cons.print(string: "OK\n")
	} else {
		cons.print(string: "NG: url0 = \(url0.path)\n")
		result = false
	}
	cons.print(string: "rel: a.txt -> ")
	let url1 = fmanager.fullPath(pathString: "a.txt", baseURL: docdir)
	let exp1 = docdir.path + "/a.txt"
	if url1.path == exp1 {
		cons.print(string: "OK\n")
	} else {
		cons.print(string: "NG: url1 = \(url1.path) <-> \(exp1)\n")
		result = false
	}
	cons.print(string: "rel: subdir/a.txt -> ")
	let url2 = fmanager.fullPath(pathString: "subdir/a.txt", baseURL: docdir)
	let exp2 = docdir.path + "/subdir/a.txt"
	if url2.path == exp2 {
		cons.print(string: "OK\n")
	} else {
		cons.print(string: "NG: url2 = \(url2.path) <-> \(exp2)\n")
		result = false
	}
	cons.print(string: "rel: ../a.txt -> ")
	let url3 = fmanager.fullPath(pathString: "../a.txt", baseURL: docdir)
	let exp3 = FileManager.default.homeDirectoryForCurrentUser.path + "/a.txt"
	if url3.path == exp3 {
		cons.print(string: "OK\n")
	} else {
		cons.print(string: "NG: url3 = \(url3.path) <-> \(exp3)\n")
		result = false
	}

	let url4 = fmanager.homeDirectoryForCurrentUser
	cons.print(string: "home directory: \(url4.absoluteString)\n")

	if result {
		cons.print(string: "testFileManager .. OK\n")
	} else {
		cons.print(string: "testFileManager .. NG\n")
	}
	return result
}

