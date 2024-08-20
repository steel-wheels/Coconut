/**
 * @file	CNSpriteField.swift
 * @brief	Define CNSpriteField class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import Foundation

public class CNSpriteNodeRef
{
	public static let InterfaceName = "SpriteNodeRefIF"

	public static let MaterialItem		= "material"
	public static let NodeIdItem		= "nodeId"
	public static let PositionItem		= "position"

	private var mMaterial:		CNSpriteMaterial
	private var mNodeId:		Int
	private var mPosition:		CGPoint

	public static func allocateInterfaceType(pointIF pointif: CNInterfaceType) -> CNInterfaceType {
		typealias M = CNInterfaceType.Member
		let mattype = CNSpriteMaterial.allocateEnumType()
		let members: Array<M> = [
			M(name: MaterialItem,		type: .enumType(mattype)),
			M(name: NodeIdItem,		type: .numberType),
			M(name: PositionItem,		type: .interfaceType(pointif))
		]
		return CNInterfaceType(name: CNSpriteNodeRef.InterfaceName, base: nil, members: members)
	}

	public var material:	CNSpriteMaterial { get { return mMaterial	}}
	public var nodeId:	Int 		 { get { return mNodeId		}}
	public var position:	CGPoint		 { get { return mPosition	}}

	public init(material m: CNSpriteMaterial, nodeId nid: Int, position pos: CGPoint) {
		self.mMaterial		= m
		self.mNodeId		= nid
		self.mPosition		= pos
	}
}

@objc public class CNSpriteField: NSObject
{
	public static let InterfaceName = "SpriteFieldIF"

	private static let SizeItem  = "size"
	private static let NodesItem = "nodes"

	static func allocateInterfaceType(sizeInterface sizeif: CNInterfaceType, nodeRefIF refif: CNInterfaceType) -> CNInterfaceType {
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: CNSpriteField.SizeItem, 	type: .interfaceType(sizeif)),
			M(name: CNSpriteField.NodesItem,	type: .arrayType(.interfaceType(refif)))
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	private var mSize: 	CGSize
	private var mNodes:	Array<CNSpriteNodeRef>

	public var nodes: Array<CNSpriteNodeRef> { get { return mNodes }}

	public var size: CGSize {
		get		{ return mSize }
		set(newsz)	{ mSize = newsz }
	}

	public override init() {
		self.mSize	= CGSize.zero
		self.mNodes	= []
		super.init()
	}

	public func clearNodes() {
		self.mNodes	= []
	}

	public func appendNode(nodeRef nref: CNSpriteNodeRef){
		self.mNodes.append(nref)
	}
}
