/**
 * @file	CNReadline.swift
 * @brief	Define CNReadline class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import Foundation

public class CNReadline
{
	private var mLine:	String
	private var mIndex:	String.Index

	public var line: String  { get { return mLine }}
	public var isEmpty: Bool { get { return mLine.isEmpty }}

	public init() {
		self.mLine  = ""
		self.mIndex = mLine.startIndex
	}

	public func insert(string str: String) {
		mLine.insert(contentsOf: str, at: mIndex)
		mIndex = mLine.index(mIndex, offsetBy: str.count)
	}

	public func delete() -> Bool {
		if mLine.startIndex < mIndex {
			let previdx = mLine.index(before: mIndex)
			mLine.remove(at: previdx)
			mIndex = previdx
			return true
		} else {
			return false
		}
	}

	public func cursorForward(_ num: Int) -> Int {
		var movenum = 0
		for _ in 0..<num {
			if mIndex < mLine.endIndex {
				movenum += 1
				mIndex = mLine.index(after: mIndex)
			} else {
				break
			}
		}
		return movenum
	}

	public func cursorBackward(_ num: Int) -> Int {
		var movenum = 0
		for _ in 0..<num {
			if mLine.startIndex < mIndex {
				movenum += 1
				mIndex = mLine.index(before: mIndex)
			} else {
				break
			}
		}
		return movenum
	}

	public func clear(){
		self.mLine  = ""
		self.mIndex = mLine.startIndex
	}
}
