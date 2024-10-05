/**
 * @file	CNTimer.swift
 * @brief	Define CNTimer class
 * @par Copyright
 *   Copyright (C) 2016 Steel Wheels Project
 */

import Foundation

/* Send trigger notification to the other proceess */
@objc public actor CNTrigger: NSObject, Sendable
{
	private static let InterfaceName	= "TriggerIF"
	private static let TriggerItem		= "trigger"
	private static let IsRunningItem	= "isRunning"
	private static let AckItem		= "ack"

	public static func allocateInterfaceType() -> CNInterfaceType {
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: CNTrigger.TriggerItem,		type: .functionType(.voidType, [])),
			M(name: CNTrigger.IsRunningItem,	type: .functionType(.boolType, [])),
			M(name: CNTrigger.AckItem,		type: .functionType(.voidType, []))
		]
		return CNInterfaceType(name: CNTrigger.InterfaceName, base: nil, members: members)
	}

	private var mName:		String
	private var mIsRunning:		Bool

	public var name: String { get { return mName }}

	public init(name nm: String) {
		mName	   = nm
		mIsRunning = false
		super.init()
	}

	private func trigger() {
		if !mIsRunning {
			//NSLog("Trigger: \(mName)")
			mIsRunning = true
		}
	}

        public static func trigger(object obj: CNTrigger) {
                Task.detached { await obj.trigger() }
        }

	private func isRunning() -> Bool {
		return mIsRunning
	}

        public static func isRunning(object obj: CNTrigger) -> Bool {
                var result: Bool = false
                Task { result = await obj.isRunning() }
                return result
        }

	private func ack() {
		if mIsRunning {
			//NSLog("Ack: \(mName)")
			mIsRunning = false
		}
	}

        public static func ack(object obj: CNTrigger) {
                Task.detached { await obj.ack() }
        }
}
