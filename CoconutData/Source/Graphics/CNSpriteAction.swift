/**
 * @file	CNSpriteAction.swift
 * @brief	Define CNSpriteAction class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import Foundation

public enum CNSpriteAction
{
	case setPosition(CGPoint)
	case setVelocity(CGVector)
	case retire
}

@objc public class CNSpriteActions: NSObject
{
	public static let InterfaceName = "SpriteActionsIF"

	private var mActions:	Array<CNSpriteAction>

	static func allocateInterfaceType(pointIF ptif: CNInterfaceType, vectorIF vecif: CNInterfaceType) -> CNInterfaceType {
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: "clear",
			  type: .functionType(.voidType, [])),
			M(name: "setPosition",
			  type: .functionType(.voidType, [.interfaceType(ptif)])),
			M(name: "setVelocity",
			  type: .functionType(.voidType, [.interfaceType(vecif)])),
			M(name: "retire",
			  type: .functionType(.voidType, []))
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	public var actions: Array<CNSpriteAction> { get { return mActions }}

	public override init() {
		mActions = []
		super.init()
	}

	public func clear() {
		mActions.removeAll(keepingCapacity: false)
	}

	public func setPosition(_ pos: CGPoint){
		mActions.append(.setPosition(pos))
	}

	public func setVelocity(_ vec: CGVector){
		mActions.append(.setVelocity(vec))
	}

	public func retire(){
		mActions.append(.retire)
	}
}
