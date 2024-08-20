/**
 * @file	CNEnvironment.swift
 * @brief	Define CNEnvironment class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

public class CNEnvironment
{
	static let InterfaceName = "EnvironmentIF"

	private static let SetVariableItem              = "setVariable"
	private static let GetVariableItem              = "getVariable"
	private static let GetAllItem                   = "getAll"
	private static let PackageDirectoryItem		= "packageDirectory"
	private static let CurrentDirectoryItem		= "currentDirectory"
        private static let SearchPackageItem            = "searchPackage"

	public static let HomeVariable                  = "HOME"
	public static let PackageDirVariable            = "PKGD"
        public static let PackagePathVariable           = "PKGPATH"
	public static let PwdVariable                   = "PWD"

	private static var mShared: CNEnvironment? = nil

	public static var shared: CNEnvironment { get {
		if let env = mShared {
			return env
		} else {
			let env = CNEnvironment()
			mShared = env
			return env
		}
	}}

	static func allocateInterfaceType(URLIf urlif: CNInterfaceType) -> CNInterfaceType {
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: GetVariableItem,	type: .functionType(.nullable(.stringType), [.stringType])),
			M(name: SetVariableItem,	type: .functionType(.voidType, [.stringType, .stringType])),
			M(name: GetAllItem,		type: .functionType(.dictionaryType(.stringType), [])),
			M(name: PackageDirectoryItem,	type: .interfaceType(urlif)),
			M(name: CurrentDirectoryItem,	type: .interfaceType(urlif)),
                        M(name: SearchPackageItem,      type: .functionType(.nullable(.interfaceType(urlif)), [.stringType]))
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	private var mParentEnvironment:	CNEnvironment?
	private var mDictionary:	    Dictionary<String, String>
	private var mPackageDirectory:	URL?
        private var mPackagePaths:      Array<URL>
	private var mCurrentDirectory:	URL

	private init() {
		mParentEnvironment	= nil
		mDictionary		= [:]
		mPackageDirectory	= nil
		mCurrentDirectory	= FileManager.default.defaultHomeDirectory
        mPackagePaths       = []
	}

	public init(parent par: CNEnvironment) {
		mParentEnvironment	= par
		mDictionary		= [:]
		mPackageDirectory	= nil
		mCurrentDirectory	= FileManager.default.defaultHomeDirectory
                mPackagePaths       = []
	}

	public func setVariable(_ name: String, _ value: String) {
		switch name {
		case CNEnvironment.HomeVariable:
			break
		case CNEnvironment.PwdVariable:
			setCurrentDirectory(path: value)
		case CNEnvironment.PackageDirVariable:
			setPackageDirectory(path: value)
		default:
			mDictionary[name] = value
		}
	}

	public func getVariable(_ name: String) -> String? {
		var result: String? = nil
		switch name {
		case CNEnvironment.HomeVariable:
			result = FileManager.default.defaultHomeDirectory.path
		case CNEnvironment.PwdVariable:
			result = mCurrentDirectory.path
		case CNEnvironment.PackageDirVariable:
			if let url = self.packageDirectory {
				result = url.path
			} else {
				result = nil
			}
		default:
			if let val = mDictionary[name] {
				result = val
			} else if let parent = mParentEnvironment {
				result = parent.getVariable(name)
			} else {
				result = nil
			}
		}
		return result
	}

	public var currentDirectory: URL { get {
		return mCurrentDirectory
	}}

	public var packageDirectory: URL? { get {
		return mPackageDirectory
	}}

	public func setCurrentDirectory(path pth: String) {
                switch FileManager.default.checkFileType(pathString: pth) {
                case .success(let ftype):
                        switch  ftype {
                        case .directory:
                            mCurrentDirectory = URL(fileURLWithPath: pth)
                        case .file:
                            CNLog(logLevel: .error, message: "The file \(pth) is NOT directory", atFunction: #function, inFile: #file)
                        }
                case .failure(let err):
                        CNLog(logLevel: .error, message: err.toString(), atFunction: #function, inFile: #file)
                }
	}

	public func setPackageDirectory(path pth: String) {
                switch FileManager.default.checkFileType(pathString: pth) {
                case .success(let ftype):
                        switch ftype {
                        case .directory:
                            mPackageDirectory = URL(fileURLWithPath: pth)
                        case .file:
                            CNLog(logLevel: .error, message: "The file \(pth) is NOT directory", atFunction: #function, inFile: #file)
                        }
                case .failure(let err):
                        CNLog(logLevel: .error, message: err.toString(), atFunction: #function, inFile: #file)
                }
	}

        public func addPackagePath(path url: URL) {
                let path = url.path
                switch FileManager.default.checkFileType(pathString: path) {
                case .success(let ftype):
                        switch ftype {
                        case .directory:
                            mPackagePaths.append(url)
                        case .file:
                            CNLog(logLevel: .error, message: "The file \(path) is NOT directory", atFunction: #function, inFile: #file)
                        }
                case .failure(let err):
                        CNLog(logLevel: .error, message: err.toString(), atFunction: #function, inFile: #file)
                }
        }

    public func searchPackagePath(packageName pname: String) -> URL? {
        for path in mPackagePaths {
            let purl = path.appending(path: pname)
            if FileManager.default.fileExists(atURL: purl) {
                return purl
            }
        }
        if let parent = mParentEnvironment {
            return parent.searchPackagePath(packageName: pname)
        } else {
            return nil
        }
    }

	public func getAll() -> Dictionary<String, String> {
		return mDictionary
	}
}

