/*
 * @file	CNUTTypeManager.swift
 * @brief	Define CNUTTypeMamager
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import Foundation
import UniformTypeIdentifiers

public class CNUTTypeManager
{
	private static var mShared: CNUTTypeManager? = nil

	private var mContentTypes: 	Dictionary<String, UTType>	// <identifier, UTI>
	private var mExtensionToType:	Dictionary<String, UTType>	// <file-extension, UTI>

	public static var shared: CNUTTypeManager { get {
		if let mgr = mShared {
			return mgr
		} else {
			let mgr = CNUTTypeManager()
			mgr.loadPlist()
			mShared = mgr
			return mgr
		}
	}}

	private init() {
		mContentTypes    = [:]
		mExtensionToType = [:]
	}

	private func loadPlist() {
                if let plist  = CNPropertyList.loadFromMainBundle() {
                        for decl in plist.typeDeclarations {
                                if let utype = UTType(decl.typeIdentifier) {
                                        add(uniformType: utype, fileExtension: decl.fileExtension)
                                        NSLog("UTI: \(utype.identifier)")
                                } else {
                                        NSLog("Unsupported type identifier: \(decl.typeIdentifier)")
                                }
                        }
                }
	}

        private func add(uniformType ctype: UTType, fileExtension fext: String){
		mContentTypes[ctype.identifier] = ctype
                mExtensionToType[fext] = ctype
	}

	public func extensionToType(extension ext: String) -> UTType? {
		if let stype = UTType(filenameExtension: ext) {
			/* Ignore the type which is genereted by the system */
			if !stype.isDynamic {
				return stype
			}
		}
		if let ctype = mExtensionToType[ext] {
			return ctype
		}
		return nil
	}
}
