/*
 * @file	CNResource.swift
 * @brief	Define CNResource class
 * @par Copyright
 *   Copyright (C) 2018-2023 Steel Wheels Project
 */

#if os(OSX)
import AppKit
#else
import UIKit
#endif
import Foundation

private class CNResourceValue<T>
{
    private var mValues: Array<T>

    public init() {
        mValues = []
    }

    public func count() -> Int {
        return mValues.count
    }

    public func set(at index: Int, value val: T) -> NSError? {
        let result: NSError?
        if index < mValues.count {
            mValues[index] = val
            result = nil
        } else if index == mValues.count {
            mValues.append(val)
            result = nil
        } else {
            result = NSError.parseError(message: "Index outof bounds: \(index)")
        }
        return result
    }

    public func add(value val: T) {
        mValues.append(val)
    }

    public func value(at index: Int) -> T? {
        if 0<=index && index<mValues.count {
            return mValues[index]
        }
        return nil
    }

    public func values() -> Array<T> {
        return mValues
    }

    public func toText(converter: (_ val: T) -> CNText) -> CNText {
        let result: CNText
        switch mValues.count {
        case 0: result = CNTextLine(string: "")
        case 1: result = converter(mValues[0])
        default:
            let sect = CNTextSection()
            sect.header = "[" ; sect.footer = "]"
            for val in mValues {
                sect.add(text: converter(val))
            }
            result = sect
        }
        return result
    }
}

private class CNResourceElement<T>
{
    private var mElements: Dictionary<String, CNResourceValue<T>>

    public init(){
        mElements = [:]
    }

    public func count(identifier ident: String) -> Int {
        if let elm = mElements[ident] {
            return elm.count()
        } else {
            return 0
        }
    }

    public func set(identifier ident: String, at index: Int, value val: T) -> NSError? {
        if let elm = mElements[ident] {
            return elm.set(at: index, value: val)
        } else {
            let newelm: CNResourceValue<T> = CNResourceValue()
            if let err = newelm.set(at: index, value: val) {
                return err
            } else {
                mElements[ident] = newelm
                return nil
            }
        }
    }

    public func add(identifier ident: String, value val: T) {
        if let elm = mElements[ident] {
            elm.add(value: val)
        } else {
            let newelm: CNResourceValue<T> = CNResourceValue()
            newelm.add(value: val)
            mElements[ident] = newelm
        }
    }

    public func values(identifier ident: String) -> Array<T> {
        if let elm = mElements[ident] {
            return elm.values()
        } else {
            return []
        }
    }

    public func value(identifier ident: String, at index: Int) -> T? {
        if let elm = mElements[ident] {
            return elm.value(at: index)
        } else {
            return nil
        }
    }

    public func toText(converter: (_ val: T) -> CNText) -> CNText {
        let result = CNTextSection()
        for (ident, memb) in mElements {
            let sec = CNTextSection()
            sec.header = ident + " {" ; sec.footer = "}"
            sec.add(text: memb.toText(converter: converter))
            result.add(text: sec)
        }
        return result
    }
}

private class CNResourceCatalog<T>
{
    private var mCatalogs: Dictionary<String, CNResourceElement<T>>

    public init(){
        mCatalogs = [:]
    }

    public func count(category cat: String, identifier ident: String) -> Int {
        if let dict = mCatalogs[cat] {
            return dict.count(identifier: ident)
        } else {
            return 0
        }
    }

    public func set(category cat: String, identifier ident: String, at index: Int, value val: T) -> NSError? {
        if let dict = mCatalogs[cat] {
            return dict.set(identifier: ident, at: index, value: val)
        } else {
            let newdict: CNResourceElement<T> = CNResourceElement()
            if let err = newdict.set(identifier: ident, at: index, value: val) {
                return err
            } else {
                mCatalogs[cat] = newdict
                return nil
            }
        }
    }

    public func add(category cat: String, identifier ident: String, value val: T) {
        if let dict = mCatalogs[cat] {
            return dict.add(identifier: ident, value: val)
        } else {
            let newdict: CNResourceElement<T> = CNResourceElement()
            newdict.add(identifier: ident, value: val)
            mCatalogs[cat] = newdict
        }
    }

    public func value(category cat: String, identifier ident: String, at index: Int) -> T? {
        if let dict = mCatalogs[cat] {
            return dict.value(identifier: ident, at: index)
        } else {
            return nil
        }
    }

    public func values(category cat: String, identifier ident: String) -> Array<T> {
        if let dict = mCatalogs[cat] {
            return dict.values(identifier: ident)
        } else {
            return []
        }
    }

    public func toText(converter: (_ val: T) -> CNText) -> CNText {
        let result = CNTextSection()
        for (ident, memb) in mCatalogs {
            let sec = CNTextSection()
            sec.header = ident + " {" ; sec.footer = "}"
            sec.add(text: memb.toText(converter: converter))
            result.add(text: sec)
        }
        return result
    }
}

private class CNTypeValue
{
    private var mPath:       String
    private var mType:       CNValueType

    public var path: String      { get { return mPath   }}
    public var type: CNValueType { get { return mType   }}

    public init(path p: String, type t: CNValueType) {
        self.mPath   = p
        self.mType  = t
    }
}

private class CNImageValue
{
    private var mUrl:        URL
    private var mData:       CNImage?

    public init(file u: URL) {
        self.mUrl    = u
        self.mData   = nil
    }

    public var url: URL { get { return mUrl }}

    public var data: CNImage { get {
        if let img = mData {
            return img
        } else {
            if let newimg = CNImage.load(from: self.mUrl) {
                self.mData = newimg
                return newimg
            } else {
                CNLog(logLevel: .error, message: "Failed to load image from \(mUrl.path)",
                      atFunction: #function, inFile: #file)
                return CNImage()
            }
        }
    }}
}

open class CNResource
{
    private var mPackageDirectory:  URL

    private var mStringResource:        CNResourceCatalog<String>
    private var mURLResource:           CNResourceCatalog<URL>
    private var mTypeResource:          CNResourceCatalog<CNTypeValue>
    private var mPropertiesResource:    CNResourceCatalog<CNValueProperties>
    private var mTableResource:         CNResourceCatalog<CNValueTable>
    private var mImageResource:         CNResourceCatalog<CNImageValue>

    private var mApplicationSupportDirectory:   URL

    public var packageDirectory: URL { get { return mPackageDirectory }}
    public var applicationSupportDirectory: URL { get { return mApplicationSupportDirectory }}

    public init(packageDirectory packdir: URL) {
        mPackageDirectory   = packdir
        mStringResource     = CNResourceCatalog()
        mURLResource        = CNResourceCatalog()
        mTypeResource       = CNResourceCatalog()
        mPropertiesResource = CNResourceCatalog()
        mTableResource      = CNResourceCatalog()
        mImageResource      = CNResourceCatalog()

        /* Decide application support directory */
        let pkgname = packdir.lastPathComponent.deletingPathExtension

        /* get application name*/
        let apppath = FileManager.default.applicationPath
        let appname = apppath.lastPathComponent.deletingPathExtension
        //NSLog("application path: \(apppath.path)")

        /* allocate application support directory */
        var supdir = FileManager.default.applicationSupportDirectory
        supdir.append(path: appname)
        supdir.append(path: pkgname)
        supdir.deletePathExtension()
        mApplicationSupportDirectory = supdir
    }

    /*
     * String
     */
    public func countOfStrings(category cat: String, identifier ident: String) -> Int {
        return mStringResource.count(category: cat, identifier: ident)
    }

    public func setString(category cat: String, identifier ident: String, at index: Int, value val: String) -> NSError? {
        return mStringResource.set(category: cat, identifier: ident, at: index, value: val)
    }

    public func addString(category cat: String, identifier ident: String, value val: String) {
        mStringResource.add(category: cat, identifier: ident, value: val)
    }

    public func stringValues(category cat: String, identifier ident: String) -> Array<String> {
        return mStringResource.values(category: cat, identifier: ident)
    }

    public func stringValue(category cat: String, identifier ident: String, at index: Int) -> String? {
        return mStringResource.value(category: cat, identifier: ident, at: index)
    }

    /*
     * URL
     */
    public func countOfURLs(category cat: String, identifier ident: String) -> Int {
        return mURLResource.count(category: cat, identifier: ident)
    }

    public func setURL(category cat: String, identifier ident: String, at index: Int, path pth: String) -> NSError? {
        let url = mPackageDirectory.appending(path: pth)
        return mURLResource.set(category: cat, identifier: ident, at: index, value: url)
    }

    public func addURL(category cat: String, identifier ident: String, path pth: String) {
        let url = mPackageDirectory.appending(path: pth)
        return mURLResource.add(category: cat, identifier: ident, value: url)
    }

    public func urlValues(category cat: String, identifier ident: String) -> Array<URL> {
        return mURLResource.values(category: cat, identifier: ident)
    }

    public func urlValue(category cat: String, identifier ident: String, at index: Int) -> URL? {
        return mURLResource.value(category: cat, identifier: ident, at: index)
    }

    /*
     * Type
     */
    public func countOfTypess(category cat: String, identifier ident: String) -> Int {
        return mTypeResource.count(category: cat, identifier: ident)
    }

    public func setType(category cat: String, identifier ident: String, at index: Int, path pth: String, type vtype: CNValueType) -> NSError? {
        let tval = CNTypeValue(path: pth, type: vtype)
        keepValueType(type: vtype)
        return mTypeResource.set(category: cat, identifier: ident, at: index, value: tval)
    }

    public func addType(category cat: String, identifier ident: String, path pth: String, type vtype: CNValueType) {
        let tval = CNTypeValue(path: pth, type: vtype)
        keepValueType(type: vtype)
        return mTypeResource.add(category: cat, identifier: ident, value: tval)
    }

    public func typeValues(category cat: String, identifier ident: String) -> Array<CNValueType> {
        let tvals = mTypeResource.values(category: cat, identifier: ident)
        return tvals.map{ $0.type }
    }

    public func typePaths(category cat: String, identifier ident: String) -> Array<String> {
        let tvals = mTypeResource.values(category: cat, identifier: ident)
        return tvals.map{ $0.path }
    }

    public func typeValue(category cat: String, identifier ident: String, at index: Int) -> CNValueType? {
        if let tval = mTypeResource.value(category: cat, identifier: ident, at: index) {
            return tval.type
        } else {
            return nil
        }
    }

    private func keepValueType(type vtype: CNValueType) {
        let vmgr = CNValueTypeManager.shared
        switch vtype {
        case .enumType(let etype):          vmgr.add(enumType: etype)
        case .interfaceType(let iftype):    vmgr.add(interfaceType: iftype)
        default:                            NSLog("Failed to register the value type")
        }
    }

    /*
     * Properties
     */
    public func countOfProperties(category cat: String, identifier ident: String) -> Int {
        return mPropertiesResource.count(category: cat, identifier: ident)
    }

    public func setProperties(category cat: String, identifier ident: String, typePath tpath: String, dataPath vpath: String) -> NSError? {
        let iftype: CNInterfaceType
        switch loadPropertyType(typePath: tpath) {
        case .success(let typ):
            iftype = typ
        case .failure(let err):
            return err
        }

        let value: Dictionary<String, CNValue>
        switch loadPropertyValue(dataPath: vpath) {
        case .success(let val):
            value = val
        case .failure(let err):
            return err
        }

        let newprop = CNValueProperties(type: iftype)
        for (key, val) in value {
            newprop.set(value: val, forName: key)
        }

        return mPropertiesResource.set(category: cat, identifier: ident, at: 0, value: newprop)
    }

        private func loadPropertyType(typePath tpath: String) -> Result<CNInterfaceType, NSError> {
                let turl = mPackageDirectory.appendingPathComponent(tpath)
                guard let ttxt = turl.loadContents() as? String else {
                    return .failure(NSError.fileError(message: "Failed to load type file: \(turl.path)"))
                }

                let parser = CNValueTypeParser()
                switch parser.parse(source: ttxt) {
                case .success(let vtypes):
                    if vtypes.count == 1 {
                        switch vtypes[0] {
                        case .interfaceType(let iftype):
                            return .success(iftype)
                        default:
                            return .failure(NSError.fileError(message: "Interface type declaration is required: \(vtypes.count)"))
                        }
                    } else {
                        return .failure(NSError.fileError(message: "One interface type declaration is required: \(vtypes.count)"))
                    }
                case .failure(let err):
                    return .failure(err)
                }
        }

        private func loadPropertyValue(dataPath dpath: String) -> Result<Dictionary<String, CNValue>, NSError> {
                let durl = mPackageDirectory.appendingPathComponent(dpath)
                guard let dtxt = durl.loadContents() as? String else {
                        return .failure(NSError.fileError(message: "Failed to load data file: \(durl.path)"))
                }
                let parser = CNValueParser()
                switch parser.parse(source: dtxt) {
                case .success(let val):
                        switch val {
                        case .dictionaryValue(let dict):
                                return .success(dict)
                        default:
                                return .failure(NSError.parseError(message: "Dictionary type value is required"))
                        }
                case .failure(let err):
                        return .failure(err)
                }
    }

    public func propertiesValue(category cat: String, identifier ident: String) -> CNValueProperties? {
        let props = mPropertiesResource.values(category: cat, identifier: ident)
        if props.count > 0 {
            return props[0]
        } else {
            return nil
        }
    }

    /*
     * Table
     */
    public func countOfTables(category cat: String, identifier ident: String) -> Int {
        return mTableResource.count(category: cat, identifier: ident)
    }

    public func setTable(category cat: String, identifier ident: String, typePath tpath: String, dataPath vpath: String) -> NSError? {
        let iftype: CNInterfaceType
        switch loadPropertyType(typePath: tpath) {
        case .success(let typ):
            iftype = typ
        case .failure(let err):
            return err
        }

        let value: Array<CNValue>
        switch loadTableValue(dataPath: vpath) {
        case .success(let val):
            value = val
        case .failure(let err):
            return err
        }

        let newtable = CNValueTable(recordType: iftype)
        if let err = newtable.load(value: value, from: vpath) {
            return err
        }

        return mTableResource.set(category: cat, identifier: ident, at: 0, value: newtable)
    }

        private func loadTableValue(dataPath dpath: String) -> Result<Array<CNValue>, NSError> {
            let durl = mPackageDirectory.appendingPathComponent(dpath)
                guard let dtxt = durl.loadContents() as? String else {
                        return .failure(NSError.fileError(message: "Failed to load data file: \(durl.path)"))
                }
                let parser = CNValueParser()
                switch parser.parse(source: dtxt) {
                case .success(let val):
                        if let arr = val.toArray() {
                                return .success(arr)
                        } else {
                                return .failure(NSError.fileError(message: "The table value must be array"))
                        }
                case .failure(let err):
                        return .failure(err)
                }
        }

    public func tableValue(category cat: String, identifier ident: String) -> CNValueTable? {
        let tbls = mTableResource.values(category: cat, identifier: ident)
        if tbls.count > 0 {
            return tbls[0]
        } else {
            return nil
        }
    }

    /*
     * Image
     */
    public func countOfImages(category cat: String, identifier ident: String) -> Int {
        return mImageResource.count(category: cat, identifier: ident)
    }

    public func setImage(category cat: String, identifier ident: String, at index: Int, path pth: String) -> NSError? {
        let url = mPackageDirectory.appending(path: pth)
        let img = CNImageValue(file: url)
        return mImageResource.set(category: cat, identifier: ident, at: index, value: img)
    }

    public func addImage(category cat: String, identifier ident: String, path pth: String) {
        let url = mPackageDirectory.appending(path: pth)
        let img = CNImageValue(file: url)
        mImageResource.add(category: cat, identifier: ident, value: img)
    }

    public func imageValues(category cat: String, identifier ident: String) -> Array<CNImage> {
        let imgs = mImageResource.values(category: cat, identifier: ident)
        return imgs.map{ $0.data }
    }

    public func imageURLs(category cat: String, identifier ident: String) -> Array<URL> {
        let imgs = mImageResource.values(category: cat, identifier: ident)
        return imgs.map{ $0.url }
    }

    public func imageValues(category cat: String, identifier ident: String, at index: Int) -> CNImage? {
        if let img = mImageResource.value(category: cat, identifier: ident, at: index) {
            return img.data
        } else {
            return nil
        }
    }

    /*
     * To text
     */
    public func toText() -> CNText {
        let stringConverter = {
            (_ val: String) -> CNText in return CNTextLine(string: val)
        }
        let urlConverter = {
            (_ val: URL) -> CNText in return CNTextLine(string: val.path)
        }
        let typeConverter = {
            (_ val: CNTypeValue) -> CNText in return CNTextLine(string: val.type.typeName)
        }
        let propConverter = {
            (_ val: CNProperties) -> CNText in return val.toText()
        }
        let tableConverter = {
            (_ val: CNTable) -> CNText in return val.toText()
        }
        let imgConverter = {
            (_ val: CNImageValue) -> CNText in return CNTextLine(string: val.url.path)
        }

        let root = CNTextSection()
        root.header = "{" ; root.footer = "}"

        let pkgtxt = CNTextLine(string: "package: \(mPackageDirectory.path)")
        root.add(text: pkgtxt)

        let strtxt = mStringResource.toText(converter: stringConverter)
        root.add(text: strtxt)

        let urltxt = mURLResource.toText(converter: urlConverter)
        root.add(text: urltxt)

        let typetxt = mTypeResource.toText(converter: typeConverter)
        root.add(text: typetxt)

        let proptxt = mPropertiesResource.toText(converter: propConverter)
        root.add(text: proptxt)

        let tbltxt = mTableResource.toText(converter: tableConverter)
        root.add(text: tbltxt)

        let imgtxt = mImageResource.toText(converter: imgConverter)
        root.add(text: imgtxt)

        return root
    }
}
