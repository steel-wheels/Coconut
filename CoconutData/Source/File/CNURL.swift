/*
 * @file	CNURL.swift
 * @brief	Extend URL class
 * @par Copyright
 *   Copyright (C) 2016-2021 Steel Wheels Project
 */

#if os(OSX)
import AppKit
#else
import UIKit
#endif
import Foundation
import UniformTypeIdentifiers

/**
 * Extend the URL methods to open, load, save, close the files in the sand-box
 */
public extension URL
{
	static let InterfaceName = "URLIF"

	static func null() -> URL {
		guard let u = URL(string: "file:///dev/null") else {
			fatalError("Failed to allocate null URL")
		}
		return u
	}

	static func allocateInterfaceType() -> CNInterfaceType {
		// dummy interface to reference itself
		let urlif:CNValueType = .interfaceType(CNInterfaceType(name: URL.InterfaceName, base: nil, members: []))
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: "isNull",			type: .boolType),
			M(name: "absoluteStriung",		type: .stringType),
			M(name: "path",				type: .stringType),
			M(name: "appending",			type: .functionType(urlif, [.stringType])),
			M(name: "lastPathComponent",		type: .stringType),
			M(name: "deletingLastPathComponent",	type: urlif),
			M(name: "loadText",			type: .functionType(.nullable(.stringType), []))
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	var isNull: Bool {
		get { return self.absoluteString == "file:///dev/null" }
	}

#if os(OSX)
	static func openPanel(title tl: String, type file: CNFileType, contentTypes ctypes: Array<UTType>, callback cbfunc: @escaping (_ url: URL?) -> Void) {
		CNExecuteInMainThread(doSync: false, execute: {
			openPanelMain(title: tl, type: file, contentTypes: ctypes, callback: cbfunc)
		})
	}

	private static func openPanelMain(title tl: String, type file: CNFileType, contentTypes ctypes: Array<UTType>, callback cbfunc: @escaping (_ url: URL?) -> Void) {
		let panel = NSOpenPanel()
		panel.title = tl
		switch file {
		case .file:
			panel.canChooseFiles       = true
			panel.canChooseDirectories = false
		case .directory:
			panel.canChooseFiles       = false
			panel.canChooseDirectories = true
		}
		panel.allowsMultipleSelection = false

		if ctypes.count > 0 {
			panel.allowedContentTypes = ctypes
		}

		switch panel.runModal() {
		case .OK:
			let urls = panel.urls
			if urls.count >= 1 {
				/* Bookmark this folder */
				let preference = CNPreference.shared.bookmarkPreference
				preference.add(URL: urls[0])
				cbfunc(urls[0])
			} else {
				cbfunc(nil)
			}
		case .cancel:
			cbfunc(nil)
		default:
			CNLog(logLevel: .error, message: "Unsupported result", atFunction: #function, inFile: #file)
			cbfunc(nil)
		}
	}

	static func savePanel(title tl: String, outputDirectory outdir: URL?, callback cbfunc: @escaping ((_: URL?) -> Void)) {
		CNExecuteInMainThread(doSync: false, execute: {
			self.savePanelMain(title: tl, outputDirectory: outdir, callback: cbfunc)
		})
	}

	private static func savePanelMain(title tl: String, outputDirectory outdir: URL?, callback cbfunc: @escaping ((_: URL?) -> Void))
	{
		let panel = NSSavePanel()
		panel.title = tl
		panel.canCreateDirectories = true
		panel.showsTagField = false
		if let odir = outdir {
			panel.directoryURL = odir
		}
		switch panel.runModal() {
		case .OK:
			if let newurl = panel.url {
				if FileManager.default.fileExists(atURL: newurl) {
					/* Bookmark this URL */
					let preference = CNPreference.shared.bookmarkPreference
					preference.add(URL: newurl)
				}
				cbfunc(newurl)
			} else {
				cbfunc(nil)
			}
		case .cancel:
			cbfunc(nil)
		default:
			CNLog(logLevel: .error, message: "Unsupported result", atFunction: #function, inFile: #file)
			cbfunc(nil)
		}
	}
#endif

	func loadContents() -> NSString? {
		var resstr: NSString?
		let issecure = startAccessingSecurityScopedResource()
		do {
			resstr = try NSString(contentsOf: self, encoding: String.Encoding.utf8.rawValue)
		} catch {
			resstr = nil
		}
		if issecure {
			stopAccessingSecurityScopedResource()
		}
		return resstr
	}

	func loadValue() -> Result<CNValue, NSError> {
		if let str = self.loadContents() {
			let parser = CNValueParser()
			switch parser.parse(source: str as String) {
			case .success(let val):
				return .success(val)
			case .failure(let err):
				return .failure(err)
		 	}
		} else {
			let err = NSError.fileError(message: "Failed to read \(self.path)")
			return .failure(err)
		}
	}

	func save(string str: String) -> Bool {
		var result = true
		let issecure = startAccessingSecurityScopedResource()
		do {
			try str.write(toFile: self.path, atomically: false, encoding: .utf8)
		} catch {
			result = false
		}
		if issecure {
			stopAccessingSecurityScopedResource()
		}
		return result
	}

	func save(value val: CNValue) -> Bool {
		let str = val.toScript().toStrings().joined(separator: "\n")
		return self.save(string: str)
	}

	func save(image img: CNImage) -> Bool {
		var result = false
		if let data = img.pngData() {
			do {
				try data.write(to: self)
				result = true
			} catch {
				CNLog(logLevel: .error, message: "Failed to save image", atFunction: #function, inFile: #file)
			}
		}
		return result
	}
}

