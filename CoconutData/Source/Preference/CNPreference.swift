/**
 * @file	CNPreference.swift
 * @brief	Define CNPreference class
 * @par Copyright
 *   Copyright (C) 2019-2024 Steel Wheels Project
 */

#if os(OSX)
import AppKit
#else
import UIKit
#endif
import Foundation

public class CNPreference
{
	public static let InterfaceName = "PreferenceIF"

	public static var mShared: CNPreference? = nil

	public static var shared: CNPreference { get {
		if let obj = mShared {
			return obj
		} else {
			let newobj = CNPreference()
			mShared = newobj
			return newobj
		}
	}}

	private var mTable:		Dictionary<String, CNPreferenceTable>
	private var mUserDefaults:	UserDefaults

	private init(){
		mTable		= [:]
		mUserDefaults	= UserDefaults.standard
	}

	static func allocateInterfaceType(systemPreferenceIF spref: CNInterfaceType, userPreferenceIF upref: CNInterfaceType, viewPreferenceIF vpref: CNInterfaceType) -> CNInterfaceType {
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: "system",	type: .interfaceType(spref)),
			M(name: "user",		type: .interfaceType(upref)),
			M(name: "view",		type: .interfaceType(vpref))
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	public func get<T: CNPreferenceTable>(name nm: String, allocator alloc: () -> T) -> T {
		if let anypref = mTable[nm] as? T {
			return anypref
		} else {
			let newpref = alloc()
			mTable[nm]  = newpref
			return newpref
		}
	}

	/* This method will be accessed by sub class*/
	public func peekTable(name nm: String) -> CNPreferenceTable? {
		return mTable[nm]
	}

	/* This method will be accessed by sub class*/
	public func pokeTable(name nm: String, table tbl: CNPreferenceTable) {
		mTable[nm] = tbl
	}
}

public class CNSystemPreference: CNPreferenceTable
{
	public typealias LogLevel = CNConfig.LogLevel

	public static let InterfaceName		= "SystemPreferenceIF"

	private static let StyleItem		= "style"
	private static let VersionItem		= "version"
	private static let DeviceItem		= "device"
	private static let LogLevelItem		= "logLevel"

	public typealias StyleListenerFunction = (_ style: CNInterfaceStyle) -> Void

	public init(){
		super.init(sectionName: "SystemPreference")

		/* Set initial value */
		if let logval = super.loadIntValue(forKey: CNSystemPreference.LogLevelItem) {
			if let _ = LogLevel(rawValue: logval) {
				super.set(intValue: logval, forKey: CNSystemPreference.LogLevelItem)
			} else {
				CNLog(logLevel: .error, message: "Unknown log level", atFunction: #function, inFile: #file)
				super.set(intValue: LogLevel.defaultLevel.rawValue, forKey: CNSystemPreference.LogLevelItem)
			}
		} else {
			super.set(intValue: LogLevel.defaultLevel.rawValue, forKey: CNSystemPreference.LogLevelItem)
		}

		/* Interface style */
		let style = CNSystemPreference.currentStyle()
		setStyle(style: style)

		/* Watch interface style switching */
		#if os(OSX)
			let center = DistributedNotificationCenter.default()
			center.addObserver(self,
					   selector: #selector(interfaceModeChanged(sender:)),
					   name: NSNotification.Name(rawValue: "AppleInterfaceThemeChangedNotification"),
					   object: nil)
		#endif
	}

	@objc public func interfaceModeChanged(sender: NSNotification) {
		let style = CNSystemPreference.currentStyle()
		setStyle(style: style)
	}

	deinit {
		#if os(OSX)
			let center = DistributedNotificationCenter.default()
			center.removeObserver(self)
		#endif
	}

	static func allocateInterfaceType() -> CNInterfaceType {
		typealias M = CNInterfaceType.Member

		let devtype: CNValueType   = .enumType(CNDevice.allocateEnumType())
		let styletype: CNValueType = .enumType(CNInterfaceStyle.allocateEnumType())
		let members: Array<M> = [
			M(name: CNSystemPreference.VersionItem,  type: .stringType),
			M(name: CNSystemPreference.LogLevelItem, type: .numberType),
			M(name: CNSystemPreference.DeviceItem,   type: devtype),
			M(name: CNSystemPreference.StyleItem,	 type: styletype)
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	public var version: String { get {
		if let str = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
			return str
		} else {
			return "unknown"
		}
	}}

	public var device: CNDevice { get {
		return CNDevice.device()
	}}

	public var logLevel: LogLevel {
		get {
			if let ival = super.intValue(forKey: CNSystemPreference.LogLevelItem) {
				if let level = CNConfig.LogLevel(rawValue: ival) {
					return level
				}
			}
			return CNConfig.LogLevel.defaultLevel
		}
		set(level){
			super.set(intValue: level.rawValue, forKey: CNSystemPreference.LogLevelItem)
		}
	}

	private func setStyle(style stl: CNInterfaceStyle){
		super.set(intValue: stl.rawValue, forKey: CNSystemPreference.StyleItem)
	}

	public var style: CNInterfaceStyle { get {
		let result: CNInterfaceStyle
		if let ival = super.intValue(forKey: CNSystemPreference.StyleItem) {
			if let style = CNInterfaceStyle(rawValue: ival) {
				result = style
			} else {
				NSLog("Failed to get interface style")
				result = .light
			}
		} else {
			NSLog("Interface style is NOT found")
			result = .light
		}
		return result
	}}

	public func addObsertverForStyle(callback cbfunc: @escaping CNSystemPreference.StyleListenerFunction) -> CNObserverDictionary.ListnerHolder {
		return super.addObserver(forKey: CNSystemPreference.StyleItem, listnerFunction: {
			(_ val: Any?) -> Void in
			if let num = val as? NSNumber {
				if let style = CNInterfaceStyle(rawValue: num.intValue) {
					cbfunc(style)
					return
				}
			}
			CNLog(logLevel: .error, message: "Failed to get style", atFunction: #function, inFile: #file)
		})
	}

	private static func currentStyle() -> CNInterfaceStyle {
		let result: CNInterfaceStyle
		#if os(OSX)
			let app = NSApplication.shared.effectiveAppearance
			switch app.name {
			case .darkAqua:
				result = .dark
			default:
				result = .light
			}
		#elseif os(iOS)
			switch UIScreen.main.traitCollection.userInterfaceStyle {
			case .dark:
				result = .dark
			default:
				result = .light
			}
		#endif
		return result
	}
}

public class CNUserPreference: CNPreferenceTable
{
	public static let InterfaceName		= "UserPreferenceIF"
	public static let HomeDirectoryItem	= "homeDirectory"
	public static let LanguageItem		= "language"

	public init() {
		super.init(sectionName: "UserPreference")

		/* set homedirectory */
		if let homedir = super.loadStringValue(forKey: CNUserPreference.HomeDirectoryItem) {
			super.set(stringValue: homedir, forKey: CNUserPreference.HomeDirectoryItem)
		} else {
			let defdir = FileManager.default.defaultHomeDirectory
			let homedir: URL
			#if os(OSX)
				homedir = defdir.appending(component: NSUserName())
			#else
				homedir = defdir
			#endif
			super.set(stringValue: homedir.path, forKey: CNUserPreference.HomeDirectoryItem)
		}

		/* set language */
		super.set(intValue: self.language.rawValue, forKey: CNUserPreference.LanguageItem)
	}

	static func allocateInterfaceType(urlIF urlif: CNInterfaceType) -> CNInterfaceType {
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: CNUserPreference.HomeDirectoryItem, type: .interfaceType(urlif)),
			M(name: CNUserPreference.LanguageItem, type: .enumType(CNLanguage.allocateEnumType()))
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	public var homeDirectory: URL {
		get {
			if let homedir = super.stringValue(forKey: CNUserPreference.HomeDirectoryItem) {
				let pref = CNPreference.shared.bookmarkPreference
				if let homeurl = pref.search(pathString: homedir) {
					return homeurl
				} else {
					let homeurl = URL(fileURLWithPath: homedir)
					return homeurl
				}
			}
			fatalError("Can not happen at function \(#function) in file \(#file)")
		}
		set(newval){
			let homedir = newval.path
                        switch FileManager.default.checkFileType(pathString: homedir) {
                        case .success(let ftype):
                                switch ftype {
                                case .directory:
                                    super.storeStringValue(stringValue: homedir, forKey: CNUserPreference.HomeDirectoryItem)
                                    super.set(stringValue: homedir, forKey: CNUserPreference.HomeDirectoryItem)
                                    let pref = CNPreference.shared.bookmarkPreference
                                    pref.add(URL: URL(filePath: homedir))
                                case .file:
                                    CNLog(logLevel: .error, message: "\(homedir) is NOT directory", atFunction: #function, inFile: #file)
                                }
                        case .failure(let err):
                                CNLog(logLevel: .error, message: err.toString(), atFunction: #function, inFile: #file)
                        }
		}
	}

	public var language: CNLanguage { get {
		let result: CNLanguage
		let locale = Locale.current
		if let lcode = locale.language.languageCode {
			switch lcode {
			case .chinese:	result = .chinese
			case .german:	result = .deutsch
			case .english:	result = .english
			case .italian:	result = .italian
			case .korean:	result = .korean
			case .russian:	result = .russian
			case .spanish:	result = .spanish
			default:	result = .others
			}
		} else {
			result = .others
		}
		return result
	}}
}

public class CNBookmarkPreference: CNPreferenceTable
{
	public let BookmarkItem		= "bookmark"

	public init() {
		super.init(sectionName: "BookmarkPreference")
		if let dict = super.loadDataDictionaryValue(forKey: BookmarkItem) {
			super.set(dataDictionaryValue: dict, forKey: BookmarkItem)
		} else {
			super.set(dataDictionaryValue: [:], forKey: BookmarkItem)
		}
	}

	public func add(URL url: URL) {
		if var dict = super.dataDictionaryValue(forKey: BookmarkItem) {
			let data = URLToData(URL: url)
			dict[url.path] = data
			super.set(dataDictionaryValue: dict, forKey: BookmarkItem)
			super.storeDataDictionaryValue(dataDictionaryValue: dict, forKey: BookmarkItem)
		} else {
			CNLog(logLevel: .error, message: "Can not happen", atFunction: #function, inFile: #file)
		}
	}

	public func search(pathString path: String) -> URL? {
		if let dict = super.dataDictionaryValue(forKey: BookmarkItem) {
			if let data = dict[path] {
				return dataToURL(bookmarkData: data)
			}
		}
		return nil
	}

	public func clear() {
		let empty: Dictionary<String, Data> = [:]
		super.set(dataDictionaryValue: empty, forKey: BookmarkItem)
		super.storeDataDictionaryValue(dataDictionaryValue: empty, forKey: BookmarkItem)
	}

	private func URLToData(URL url: URL) -> Data {
		do {
			#if os(OSX)
				let data = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
			#else
				let data = try url.bookmarkData(options: .suitableForBookmarkFile, includingResourceValuesForKeys: nil, relativeTo: nil)
			#endif
			return data
		} catch {
			let err = error as NSError
			fatalError("\(err.description)")
		}
	}

	private func dataToURL(bookmarkData bmdata: Data) -> URL? {
		do {
			var isstale: Bool = false
			#if os(OSX)
				let newurl = try URL(resolvingBookmarkData: bmdata, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isstale)
			#else
				let newurl = try URL(resolvingBookmarkData: bmdata, options: .withoutUI, relativeTo: nil, bookmarkDataIsStale: &isstale)
			#endif
			return newurl
		}
		catch {
			let err = error as NSError
			CNLog(logLevel: .error, message: err.description, atFunction: #function, inFile: #file)
			return nil
		}
	}
}

public class CNViewPreference: CNPreferenceTable
{
	public static let InterfaceName			        = "ViewPreferenceIF"

    private static let RootBackgroundColorItem      = "rootBackgroundColor"
    private static let ControlBackgroundColorItem   = "controlBackgroundColor"
    private static let LabelColorItem               = "labelColor"
    private static let TextColorItem                = "textColor"
    private static let ControlColorItem             = "controlColor"
    private static let TerminalForegroundColorItem  = "terminalForegroundColor"
    private static let TerminalBackgroundColorItem  = "terminalBackgroundColor"
    private static let GraphicsForegroundColorItem  = "graphicsForegroundColor"
    private static let GraphicsBackgroundColorItem  = "graphiceBackgroundColor"

	static func allocateInterfaceType(colorIF colif: CNInterfaceType) -> CNInterfaceType {
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: CNViewPreference.RootBackgroundColorItem,       type: .interfaceType(colif)),
            M(name: CNViewPreference.ControlBackgroundColorItem,    type: .interfaceType(colif)),
			M(name: CNViewPreference.LabelColorItem,	            type: .interfaceType(colif)),
            M(name: CNViewPreference.TextColorItem,                 type: .interfaceType(colif)),
			M(name: CNViewPreference.ControlColorItem,	            type: .interfaceType(colif)),
			M(name: CNViewPreference.TerminalForegroundColorItem,   type: .interfaceType(colif)),
            M(name: CNViewPreference.TerminalBackgroundColorItem,   type: .interfaceType(colif)),
            M(name: CNViewPreference.GraphicsForegroundColorItem,   type: .interfaceType(colif)),
            M(name: CNViewPreference.GraphicsBackgroundColorItem,   type: .interfaceType(colif))
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

    private var mRootBackgroundColor:       CNColor?
    private var mControlBackgroundColor:    CNColor?
    private var mLabelColor:                CNColor?
    private var mTextColor:                 CNColor?
    private var mControlColor:              CNColor?
    private var mTerminalForegroundColor:   CNColor?
    private var mTerminalBackgroundColor:   CNColor?
    private var mGraphicsForegroundColor:   CNColor?
    private var mGraphicsBackgroundColor:   CNColor?

	public init() {
		super.init(sectionName: "ViewPreference")

                mRootBackgroundColor        = super.loadColorValue(forKey: CNViewPreference.RootBackgroundColorItem)
                mControlBackgroundColor     = super.loadColorValue(forKey: CNViewPreference.ControlBackgroundColorItem)
                mLabelColor                 = super.loadColorValue(forKey: CNViewPreference.LabelColorItem)
		mTextColor                  = super.loadColorValue(forKey: CNViewPreference.TextColorItem)
                mControlColor               = super.loadColorValue(forKey: CNViewPreference.ControlColorItem)
                mTerminalForegroundColor    = super.loadColorValue(forKey: CNViewPreference.TerminalForegroundColorItem)
                mTerminalBackgroundColor    = super.loadColorValue(forKey: CNViewPreference.TerminalForegroundColorItem)
                mGraphicsForegroundColor    = super.loadColorValue(forKey: CNViewPreference.GraphicsForegroundColorItem)
                mGraphicsBackgroundColor    = super.loadColorValue(forKey: CNViewPreference.GraphicsBackgroundColorItem)
	}

        public func rootBackgroundColor(status stat: CNControlState) -> CNColor {
            if let col = mRootBackgroundColor {
                return col
            } else {
                let style = CNPreference.shared.systemPreference.style
                return CNUIElementColors.rootBackgroundColor.color(for: style)
            }
        }

        public func controlBackgroundColor(status stat: CNControlState) -> CNColor {
                if let col = mControlBackgroundColor {
                        return col
                } else {
                        let style = CNPreference.shared.systemPreference.style
                        return CNUIElementColors.controlBackgroundColor.color(for: style)
                }
        }

        public func labelColor(status stat: CNControlState) -> CNColor {
                if let col = mLabelColor {
                        return col
                } else {
                        let style = CNPreference.shared.systemPreference.style
                        return CNUIElementColors.labelColor.color(for: style)
                }
        }

        public func textColor(status stat: CNControlState) -> CNColor {
                if let col = mTextColor {
                        return col
                } else {
                        let style = CNPreference.shared.systemPreference.style
                        return CNUIElementColors.textColor.color(for: style)
                }
        }

        public func controlColor(status stat: CNControlState) -> CNColor {
                if let col = mControlColor {
                        return col
                } else {
                        let style = CNPreference.shared.systemPreference.style
                        return CNUIElementColors.controlColor.color(for: style)
                }
        }

        public func terminalForegroundColor() -> CNColor {
                if let col = mTerminalForegroundColor {
                        return col
                } else {
                        let style = CNPreference.shared.systemPreference.style
                        return CNUIElementColors.terminalForegroundColor.color(for: style)
                }
        }

        public func setTerminalForegroundColor(color col: CNColor) {
                super.set(colorValue: col, forKey: CNViewPreference.TerminalForegroundColorItem)
        }

        public func terminalBackgroundColor() -> CNColor {
                if let col = mTerminalBackgroundColor {
                        return col
                } else {
                        let style = CNPreference.shared.systemPreference.style
                        return CNUIElementColors.terminalBackgroundColor.color(for: style)
                }
        }

        public func setTerminalBackgroundColor(color col: CNColor) {
                super.set(colorValue: col, forKey: CNViewPreference.TerminalBackgroundColorItem)
        }

        public func graphicsForegroundColor() -> CNColor {
                if let col = mGraphicsForegroundColor {
                        return col
                } else {
                        let style = CNPreference.shared.systemPreference.style
                        return CNUIElementColors.graphicsForegroundColor.color(for: style)
                }
        }

        public func graphicsBackgroundColor() -> CNColor {
                if let col = mGraphicsBackgroundColor {
                        return col
                } else {
                        let style = CNPreference.shared.systemPreference.style
                        return CNUIElementColors.graphicsBackgroundColor.color(for: style)
                }
        }
}

public class CNTerminalPreference: CNPreferenceTable
{
	public typealias IntListenerFunction  = (_ value: Int) -> Void
	public typealias FontStyleListenerFunction = (_ value: CNFont.Style) -> Void
	public typealias FontSizeListenerFunction = (_ value: CNFont.Size) -> Void

	private static let WidthItem		= "width"
	private static let HeightItem		= "height"
	private static let FontStyleItem	= "fontStyle"
	private static let FontSizeItem		= "fontSize"

	private var mWidth:			Int
	private var mHeight:			Int
	private var mFontStyle:			CNFont.Style
	private var mFontSize:			CNFont.Size

	public init() {
		mWidth		= 80
		mHeight		= 20
		mFontStyle	= .monospace
		mFontSize	= .regular
		super.init(sectionName: "TerminalPreference")

		if let num = super.loadIntValue(forKey: CNTerminalPreference.WidthItem) {
			mWidth = num
		}
		if let num = super.loadIntValue(forKey: CNTerminalPreference.HeightItem) {
			mHeight = num
		}
		if let fstyle = super.loadIntValue(forKey: CNTerminalPreference.FontStyleItem) {
			if let style = CNFont.Style(rawValue: fstyle) {
				mFontStyle = style
			}
		}
		if let fsize = super.loadIntValue(forKey: CNTerminalPreference.FontSizeItem) {
			if let size = CNFont.Size(rawValue: fsize) {
				mFontSize = size
			}
		}
	}

	public var width: Int {
		get { return mWidth }
		set(newwidth) {
			super.set(intValue: newwidth, forKey: CNTerminalPreference.WidthItem)
			mWidth = newwidth
		}
	}

	public func addObsertverForWidth(callback cbfunc: @escaping CNTerminalPreference.IntListenerFunction) -> CNObserverDictionary.ListnerHolder {
		return super.addObserver(forKey: CNTerminalPreference.WidthItem, listnerFunction: {
			(_ val: Any?) -> Void in
			if let num = val as? NSNumber {
				cbfunc(num.intValue)
				return
			}
			CNLog(logLevel: .error, message: "Failed to get width", atFunction: #function, inFile: #file)
		})
	}

	public var height: Int {
		get { return mHeight }
		set(newheight) {
			super.set(intValue: newheight, forKey: CNTerminalPreference.HeightItem)
			mHeight = newheight
		}
	}

	public func addObsertverForHeight(callback cbfunc: @escaping CNTerminalPreference.IntListenerFunction) -> CNObserverDictionary.ListnerHolder {
		return super.addObserver(forKey: CNTerminalPreference.HeightItem, listnerFunction: {
			(_ val: Any?) -> Void in
			if let num = val as? NSNumber {
				cbfunc(num.intValue)
				return
			}
			CNLog(logLevel: .error, message: "Failed to get height", atFunction: #function, inFile: #file)
		})
	}

	public var fontStyle: CNFont.Style {
		get { return mFontStyle }
		set(newfont) {
			super.set(intValue: newfont.rawValue, forKey: CNTerminalPreference.FontStyleItem)
			mFontStyle = newfont
		}
	}

	public func addObsertverForFontStyle(callback cbfunc: @escaping CNTerminalPreference.FontStyleListenerFunction) -> CNObserverDictionary.ListnerHolder {
		return super.addObserver(forKey: CNTerminalPreference.FontStyleItem, listnerFunction: {
			(_ val: Any?) -> Void in
			if let num = val as? NSNumber {
				if let style = CNFont.Style(rawValue: num.intValue) {
					cbfunc(style)
					return
				}
			}
			CNLog(logLevel: .error, message: "Failed to get font style", atFunction: #function, inFile: #file)
		})
	}

	public var fontSize: CNFont.Size {
		get { return mFontSize}
		set(newfont) {
			super.set(intValue: newfont.rawValue, forKey: CNTerminalPreference.FontSizeItem)
			mFontSize = newfont
		}
	}

	public func addObsertverForFontSize(callback cbfunc: @escaping CNTerminalPreference.FontSizeListenerFunction) -> CNObserverDictionary.ListnerHolder {
		return super.addObserver(forKey: CNTerminalPreference.FontStyleItem, listnerFunction: {
			(_ val: Any?) -> Void in
			if let num = val as? NSNumber {
				if let size = CNFont.Size(rawValue: num.intValue) {
					cbfunc(size)
					return
				}
			}
			CNLog(logLevel: .error, message: "Failed to get font size", atFunction: #function, inFile: #file)
		})
	}
}

extension CNPreference
{
	public var systemPreference: CNSystemPreference { get {
		return get(name: "system", allocator: {
			() -> CNSystemPreference in
				return CNSystemPreference()
		})
	}}

	public var userPreference: CNUserPreference { get {
		return get(name: "user", allocator: {
			() -> CNUserPreference in
				return CNUserPreference()
		})
	}}

	public var bookmarkPreference: CNBookmarkPreference { get {
		return get(name: "bookmark", allocator: {
			() -> CNBookmarkPreference in
				return CNBookmarkPreference()
		})
	}}

	public var viewPreference: CNViewPreference { get {
		return get(name: "view", allocator: {
			() -> CNViewPreference in
				return CNViewPreference()
		})
	}}

	public var terminalPreference: CNTerminalPreference { get {
		return get(name: "terminal", allocator: {
			() -> CNTerminalPreference in
				return CNTerminalPreference()
		})
	}}
}

