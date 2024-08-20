/**
 * @file	CNPropertyList.swift
 * @brief	Define CNPropertyList class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import Foundation

public class CNPropertyList
{
        private static var mLists: Dictionary<String, CNPropertyList> = [:]

        public static func load(bundleName bname: String?) -> CNPropertyList {
                let rname = bname ?? "<main>"
                if let list = mLists[rname] {
                        return list
                }
                let newlist = CNPropertyList()
                if let name = bname {
                        newlist.load(bundleName: name)
                } else {
                        newlist.load()
                }
                mLists[rname] = newlist
                return newlist
        }

        /*
         <key>UTImportedTypeDeclarations</key>
                 <array>
                         <dict>
                                 <key>UTTypeConformsTo</key>
                                 <array>
                                         <string>com.apple.package</string>
                                 </array>
                                 <key>UTTypeDescription</key>
                                 <string>JavaScript Package</string>
                                 <key>UTTypeIcons</key>
                                 <dict/>
                                 <key>UTTypeIdentifier</key>
                                 <string>gitlab.com.steewheels.jspkg</string>
                                 <key>UTTypeTagSpecification</key>
                                 <dict>
                                         <key>public.filename-extension</key>
                                         <array>
                                                 <string>jspkg</string>
                                         </array>
                                         <key>public.mime-type</key>
                                         <array>
                                                 <string>application</string>
                                         </array>
                                 </dict>
                         </dict>
                 </array>
         */
        public struct TypeDeclaration {
                private var mTypeIdentifier:    String
                private var mFileExtension:     String

                public var typeIdentifier:      String  { get { return mTypeIdentifier  }}
                public var fileExtension:       String  { get { return mFileExtension   }}

                public init(typeIdentifier: String, fileExtension: String) {
                        self.mTypeIdentifier    = typeIdentifier
                        self.mFileExtension     = fileExtension
                }

                public var description: String { get {
                        return "{typeIdentifier: \(mTypeIdentifier), fileExtension: \(mFileExtension)}"
                }}
        }

        private var mVersionString:             String
        private var mMinimumSystemVersion:      String
        private var mTypeDeclarations:          Array<TypeDeclaration>

        public var versionString: String                        { get { return mVersionString           }}
        public var minimumSystemVersion: String                 { get { return mMinimumSystemVersion    }}
        public var typeDeclarations: Array<TypeDeclaration>     { get { return mTypeDeclarations        }}

        private init() {
                mVersionString                  = ""
                mMinimumSystemVersion           = ""
                mTypeDeclarations               = []
        }

        private func load() {
                if let plist = Bundle.main.infoDictionary {
                        load(dictionary: plist)
                } else {
                        CNLog(logLevel: .error, message: "Info.plist is not found", atFunction: #function, inFile: #file)
                }
        }

        private func load(bundleName bname: String) {
                if let bpath = CNPropertyList.mainBundlePath(bundleName: bname) {
                        if let plist = NSDictionary(contentsOfFile: bpath) as? Dictionary<String, Any> {
                                load(dictionary: plist)
                                return
                        }
                }
                CNLog(logLevel: .error, message: "Info.plist is not found", atFunction: #function, inFile: #file)
        }

        private static func mainBundlePath(bundleName bname: String) -> String? {
                if let path = Bundle.main.path(forResource: "Info", ofType: "plist", inDirectory: bname + "/Contents") {
                        return path
                } else {
                        return nil
                }
        }

        private func load(dictionary plist: Dictionary<String, Any>) {
                /* CFBundleShortVersionString:1.0 */
                if let str = plist["CFBundleShortVersionString"] as? String {
                        mVersionString  = str
                }
                /* LSMinimumSystemVersion:14.4 */
                if let str = plist["LSMinimumSystemVersion"] as? String {
                        mMinimumSystemVersion   = str
                }
                /* ImportedTypeDeclarations */
                if let decls = plist["UTImportedTypeDeclarations"] as? Array<Any> {
                        for decl in decls {
                                if let tdecl = decl as? Dictionary<String, Any> {
                                        let result = parseTypeDeclaration(decl: tdecl)
                                        mTypeDeclarations.append(result)
                                }
                        }
                }
        }

        private func parseTypeDeclaration(decl dtype: Dictionary<String, Any>) -> TypeDeclaration {
                var ident: String
                if let str = dtype["UTTypeIdentifier"] as? String {
                        ident = str
                } else {
                        CNLog(logLevel: .error, message: "No UTTypeIdentifier", atFunction: #function, inFile: #file)
                        ident = ""
                }
                var fileext: String = ""
                if let dict = dtype["UTTypeTagSpecification"] as? Dictionary<String, Any> {
                        if let exts = dict["public.filename-extension"] as? Array<String> {
                                if exts.count > 0 {
                                        fileext = exts[0]
                                }
                        }
                } else {
                        CNLog(logLevel: .error, message: "No UTTypeTagSpecification", atFunction: #function, inFile: #file)
                }
                return TypeDeclaration(typeIdentifier: ident, fileExtension: fileext)
         }

        public func dump() {
                NSLog("(CNPList) versionString:         \(mVersionString)")
                NSLog("(CNPlist) minimumSystemVersion:  \(mMinimumSystemVersion)")
                for decl in mTypeDeclarations {
                        NSLog("(CNPlist) typeDecratation: \(decl.description)")
                }
        }
}

