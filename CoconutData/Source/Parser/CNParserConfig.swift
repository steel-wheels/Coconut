/**
 * @file	CNParser.swift
 * @brief	Define CNParser class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import Foundation

public struct CNParserConfig
{
    private var mIgnoreComments             : Bool
	private var mAllowIdentiferHasPeriod	: Bool

    public init(ignoreComments ignorecomm: Bool, allowIdentiferHasPeriod allowp: Bool){
        mIgnoreComments          = ignorecomm
		mAllowIdentiferHasPeriod = allowp
	}

	public var allowIdentiferHasPeriod: Bool { get { return mAllowIdentiferHasPeriod	}}
    public var ignoreComments: Bool { get { return mIgnoreComments }}
}
