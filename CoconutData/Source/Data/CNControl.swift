/**
 * @file	CNControl.swift
 * @brief	Define CNControl class
 * @par Copyright
 *   Copyright (C) 2015-2024 Steel Wheels Project
 */

#if os(OSX)
import AppKit
#else
import UIKit
#endif

/* See UIControl.State */
public enum CNControlState: Int
{
	case normal
	case highlighted
	case disabled
	case selected

	public var description: String { get {
		let result: String
		switch self {
		case .normal:		result = "normal"
		case .highlighted:	result = "highlight"
		case .disabled:		result = "disabled"
		case .selected:		result = "selected"
		}
		return result
	}}

	#if os(iOS)
	public var systemValue: UIControl.State { get {
		let result: UIControl.State
		switch self {
		case .normal:		result = .normal
		case .highlighted:	result = .highlighted
		case .disabled:		result = .disabled
		case .selected:		result = .selected
		}
		return result
	}}
	#endif
}

