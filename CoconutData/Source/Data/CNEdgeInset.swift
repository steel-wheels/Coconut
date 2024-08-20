/*
 * @file    CNEdgeInset.swift
 * @brief   Define CNEdgeInset class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import Foundation
#if os(OSX)
import AppKit
#else
import UIKit
#endif

#if os(OSX)
public typealias CNEdgeInsets    = NSEdgeInsets
#else
public typealias CNEdgeInsets    = UIEdgeInsets
#endif

public func CNEdgeInsetsMake(_ top: CGFloat, _ left: CGFloat, _ bottom: CGFloat, _ right: CGFloat) -> CNEdgeInsets
{
    #if os(OSX)
        return NSEdgeInsetsMake(top, left, bottom, right)
    #else
        return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    #endif
}
