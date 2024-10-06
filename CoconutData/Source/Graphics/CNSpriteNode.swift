/**
 * @file	CNSpriteNode.swift
 * @brief	Define CNSpriteNode class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import SpriteKit
import Foundation

public enum CNSpriteMaterial: Int
{
	public static let EnumName = "SpriteMaterial"

	case scene		= 0
	case background		= 1
	case text		= 2
	case image		= 3

	static func allocateEnumType() -> CNEnumType {
		let spritenode = CNEnumType(typeName: CNSpriteMaterial.EnumName)
		spritenode.add(members: [
			"scene":	.intValue(CNSpriteMaterial.scene.rawValue),
			"background":	.intValue(CNSpriteMaterial.background.rawValue),
			"text":		.intValue(CNSpriteMaterial.text.rawValue),
			"image":	.intValue(CNSpriteMaterial.image.rawValue)
		])
		return spritenode
	}
}

private let MaterialItem	= "material"

public struct CNSpriteNodeDecl
{
	public static let InterfaceName	= "SpriteNodeDeclIF"
	public static let ScriptItem	= "script"
	public static let ValueItem	= "value"
	public static let CountItem	= "count"

	public var material:	CNSpriteMaterial
	public var script:	String		// Path of script file OR identifier of thread script resource
	/*   [material]		[value]
	 *   scene		: not used
	 *   background		: not used
	 *   text		: Text of label
	 *   image		: Image resource namae
	 */
	public var value:	String
	public var count:	Int

	public static func allocateInterfaceType() -> CNInterfaceType {
		typealias M = CNInterfaceType.Member
		let mattype = CNSpriteMaterial.allocateEnumType()
		let members: Array<M> = [
			M(name: MaterialItem,		type: .enumType(mattype)),
			M(name: ValueItem,		type: .stringType),
			M(name: ScriptItem,		type: .stringType),
			M(name: CountItem,		type: .numberType)
		]
		return CNInterfaceType(name: CNSpriteNodeDecl.InterfaceName, base: nil, members: members)
	}

	public init(material m: CNSpriteMaterial, value v: String, script scr: String, count c: Int) {
		self.material	= m
		self.value	= v
		self.script	= scr
		self.count	= c
	}

	public static func fromValue(value val: Dictionary<String, CNValue>) -> Result<CNSpriteNodeDecl, NSError> {
		guard let matval = val[MaterialItem] else {
			return .failure(NSError.parseError(message: "No property named: \(MaterialItem)"))
		}
		guard let matnum = matval.toNumber() else {
			return .failure(NSError.parseError(message: "It does not have number value: \(MaterialItem)"))
		}

		guard let mattype = CNSpriteMaterial(rawValue: matnum.intValue) else {
			return .failure(NSError.parseError(message: "Unknown node type number: \(matnum.intValue)"))
		}

		guard let valval = val[ValueItem] else {
			return .failure(NSError.parseError(message: "It does not have string value: \(ValueItem)"))
		}
		guard let valstr = valval.toString() else {
			return .failure(NSError.parseError(message: "The value string property does not have x number"))
		}

		guard let scrval = val[ScriptItem] else {
			return .failure(NSError.parseError(message: "It does not have string value: \(ScriptItem)"))
		}
		guard let scrpath = scrval.toString() else {
			return .failure(NSError.parseError(message: "The \(ScriptItem) property does not have string value."))
		}
		guard let cntval = val[CountItem] else {
			return .failure(NSError.parseError(message: "It does not have number value: \(CountItem)"))
		}
		guard let cntnum = cntval.toNumber() else {
			return .failure(NSError.parseError(message: "The \(CountItem) property does not have number value."))
		}

		return .success(CNSpriteNodeDecl(material: mattype, value: valstr, script: scrpath, count: cntnum.intValue))
	}
}



private let NodeIdItem		= "nodeId"
private let CurrentTimeItem	= "currentTime"
private let TriggerItem		= "trigger"
private let PositionItem	= "position"
private let SizeItem		= "size"
private let VelocityItem	= "velocity"
private let MassItem		= "mass"
private let DensityItem		= "density"
private let AreaItem		= "area"
private let RetireItem		= "retire"
private let IsMovableItem	= "isMovable"
private let IsRetiredItem	= "isRetired"
private let ActionsItem		= "actions"

private let ScriptContextItem	= "scriptContext"
private let FieldItem		= "field"

public extension SKNode
{
	private static let InterfaceName = "SpriteNodeIF"

	static var interfaceName: String { get {
		return SKNode.InterfaceName
	}}

	static func allocateInterfaceType(pointIf pif: CNInterfaceType,
					  sizeIF szif: CNInterfaceType,
					  vectorIF vecif: CNInterfaceType,
					  triggerIF trigif: CNInterfaceType,
					  actionsIF actif: CNInterfaceType) -> CNInterfaceType {
		typealias M = CNInterfaceType.Member

		let mattype = CNSpriteMaterial.allocateEnumType()
		let members: Array<M> = [
			M(name: MaterialItem,	type: .enumType(mattype)),
			M(name: NodeIdItem,	type: .numberType),
			M(name: CurrentTimeItem,type: .numberType),
			M(name: TriggerItem,	type: .interfaceType(trigif)),
			M(name: PositionItem,	type: .interfaceType(pif)),
			M(name: SizeItem,	type: .interfaceType(szif)),
			M(name: VelocityItem,	type: .interfaceType(vecif)),
			M(name: MassItem,	type: .numberType),
			M(name: DensityItem,	type: .numberType),
			M(name: AreaItem,	type: .numberType),

			M(name: ActionsItem,	type: .interfaceType(actif))
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	func setupNode(material mat: CNSpriteMaterial, machine mcn: String, nodeId nid: Int) {
		let nodename = "\(mat.rawValue)_\(mcn)_\(nid)"
		self.name = nodename

		let NoBitMask: UInt32		= 0x0
		let BackgroundBitMask: UInt32	= 0x1
		let SceneBitMask: UInt32	= 0x2
		let ImageBitMask: UInt32	= 0x4

		switch mat {
		case .scene:
			let body = SKPhysicsBody(edgeLoopFrom: self.frame)
			body.velocity           = CGVector(dx: 0.0, dy: 0.0)
			body.affectedByGravity = false
			body.allowsRotation    = false
			body.linearDamping     = 0
			body.restitution       = 1
			body.isDynamic		= false
			body.friction		= 1
			body.categoryBitMask	= SceneBitMask
			body.contactTestBitMask	= ImageBitMask | SceneBitMask
			self.physicsBody = body
		case .background, .text:
			let body   = SKPhysicsBody(rectangleOf: self.frame.size)
			body.velocity           = CGVector(dx: 0.0, dy: 0.0)
			body.affectedByGravity = false
			body.allowsRotation    = false
			body.linearDamping     = 0
			body.restitution       = 1
			body.isDynamic		= false
			body.friction		= 0
			body.categoryBitMask	= BackgroundBitMask
			body.contactTestBitMask	= NoBitMask
			self.physicsBody = body
		case .image:
			let body   = SKPhysicsBody(rectangleOf: self.frame.size)
			body.velocity           = CGVector(dx: 0.0, dy: 0.0)
			body.affectedByGravity = false
			body.allowsRotation    = false
			body.linearDamping     = 0
			body.restitution       = 1
			body.isDynamic  	= true
			body.friction  		= 0
			body.categoryBitMask	= ImageBitMask
			body.contactTestBitMask	= ImageBitMask | SceneBitMask
			self.physicsBody = body
		}

		let movable: Bool
		switch mat {
		case .scene, .text, .background:
			movable = false
		case .image:
			movable = true
		}

		/* set user data */
		let _ = userProperties() // Init properties
		setUserData(name: MaterialItem,  value: NSNumber(integerLiteral: mat.rawValue))
		setUserData(name: NodeIdItem, value: NSNumber(integerLiteral: nid))
		setUserData(name: TriggerItem, value: CNTrigger(name: nodename))
		setUserData(name: IsMovableItem, value: NSNumber(booleanLiteral: movable))
		setUserData(name: IsRetiredItem, value: NSNumber(booleanLiteral: false))
	}

	private var getPhysicsBody: SKPhysicsBody? { get {
		if let body = self.physicsBody {
			return body
		} else {
			CNLog(logLevel: .error, message: "Have no velocity", atFunction: #function, inFile: #file)
			return nil
		}
	}}

	var isMovable: Bool { get {
		if let num = userData(name: IsMovableItem) as? NSNumber {
			return num.boolValue
		} else {
			return false
		}
	}}

	var isRetired: Bool { get {
		if let num = userData(name: IsRetiredItem) as? NSNumber {
			return num.boolValue
		} else {
			return false
		}
	}}

	private func userProperties() -> NSMutableDictionary {
		if let dict = self.userData {
			return dict
		} else {
			let newdict   = NSMutableDictionary(capacity: 16)
			self.userData = newdict

			newdict.setObject(NSNumber(floatLiteral: 0.0), forKey: CurrentTimeItem as NSString)
			newdict.setObject(CNSpriteActions(), forKey: ActionsItem as NSString)
                        newdict.setObject(CNSpriteField.zero, forKey: FieldItem as NSString)
			newdict.setObject(NSNull(), forKey: ScriptContextItem as NSString)

			return newdict
		}
	}

	private func setUserData(name nm: String, value obj: NSObject) {
		let dict = userProperties()
		dict.setObject(obj, forKey: nm as NSString)
	}

	private func userData(name nm: String) -> NSObject? {
		let dict = userProperties()
		if let value = dict.object(forKey: nm as NSString) as? NSObject {
			return value
		} else {
			return nil
		}
	}

	var nodeId: Int { get {
		if let numobj = userData(name: NodeIdItem) as? NSNumber {
			return numobj.intValue
		} else {
			CNLog(logLevel: .error, message: "No valid nodeId", atFunction: #function, inFile: #file)
			return 0
		}
	}}

	var material: CNSpriteMaterial { get {
		if let matnum = userData(name: MaterialItem) as? NSNumber {
			if let mattype = CNSpriteMaterial(rawValue: matnum.intValue) {
				return mattype
			} else {
				CNLog(logLevel: .error, message: "Not material", atFunction: #function, inFile: #file)
				return .text
			}
		} else {
			CNLog(logLevel: .error, message: "No valid material", atFunction: #function, inFile: #file)
			return .text
		}
	}}

	var currentTime: TimeInterval {
		get {
			if let numobj = userData(name: CurrentTimeItem) as? NSNumber {
				return numobj.doubleValue
			} else {
				CNLog(logLevel: .error, message: "No valid current time", atFunction: #function, inFile: #file)
				return 0.0
			}
		}
		set(newval){
			setUserData(name: CurrentTimeItem, value: NSNumber(floatLiteral: newval))
		}
	}

	var trigger: CNTrigger { get {
		if let trigobj = userData(name: TriggerItem) as? CNTrigger {
			return trigobj
		}
		CNLog(logLevel: .error, message: "No valid status", atFunction: #function, inFile: #file)
		return CNTrigger(name: "<error>")
	}}

	var actions: CNSpriteActions { get {
		if let acts = userData(name: ActionsItem) as? CNSpriteActions {
			return acts
		}
		CNLog(logLevel: .error, message: "No node actions", atFunction: #function, inFile: #file)
		return CNSpriteActions()
	}}

	var field: CNSpriteField {
		get {
			if let fldobj = userData(name: FieldItem) as? CNSpriteField {
				return fldobj
			} else {
				CNLog(logLevel: .error, message: "No valid field item", atFunction: #function, inFile: #file)
                                return CNSpriteField.zero()
			}
		}
		set(fld){
			setUserData(name: FieldItem, value: fld)
		}
	}

	var scriptContext: NSObject? {
		get {
			if let obj = userData(name: ScriptContextItem) {
				if let _ = obj as? NSNull {
					return nil // No valid object
				} else {
					return obj
				}
			} else {
				CNLog(logLevel: .error, message: "No valid \(ScriptContextItem) item", atFunction: #function, inFile: #file)
				return nil
			}
		}
		set(objp){
			if let obj = objp {
				setUserData(name: ScriptContextItem, value: obj)
			} else {
				setUserData(name: ScriptContextItem, value: NSNull())
			}
		}
	}

	var velocity: CGVector {
		get {
			if let body = self.getPhysicsBody {
				return body.velocity
			} else {
				return CGVector(dx: 0, dy: 0)
			}
		}
		set(newval){
			if let body = self.getPhysicsBody {
				body.velocity = newval
			}
		}
	}

	var collisionBitMask: UInt32 {
		get {
			if let body = self.getPhysicsBody {
				return body.collisionBitMask
			} else {
				return 0xffffffff // all bit set
			}
		}
		set(newval){
			if let body = self.getPhysicsBody {
				body.collisionBitMask = newval
			}
		}
	}

	var contactTestBitMask: UInt32 {
		get {
			if let body = self.getPhysicsBody {
				return body.contactTestBitMask
			} else {
				return 0xffffffff // all bit set
			}
		}
		set(newval){
			if let body = self.getPhysicsBody {
				body.contactTestBitMask = newval
			}
		}
	}

	var mass: CGFloat {
		get {
			if let body = self.getPhysicsBody {
				return body.mass
			} else {
				return 0.0
			}
		}
		set(newval){
			if let body = self.physicsBody {
				body.mass = newval
			}
		}
	}

	var density: CGFloat {
		get {
			if let body = self.getPhysicsBody {
				return body.density
			} else {
				return 0.0
			}
		}
		set(newval){
			if let body = self.physicsBody {
				body.density = newval
			}
		}
	}

	var area: CGFloat { get {
		if let body = self.getPhysicsBody {
			return body.area
		} else {
			return 0.0
		}
	}}

	func execute() {
		//let name = self.name ?? "?"
		for act in self.actions.actions {
			switch act {
			case .setPosition(let pos):
				//NSLog("execute: \(name) set_position: \(pos.description)")
				self.position = pos
			case .setVelocity(let vec):
				//NSLog("execute: \(name) set_velocity: \(vec.description)")
				self.velocity = vec
			case .retire:
				setUserData(name: IsRetiredItem, value: NSNumber(booleanLiteral: true))
			}
		}
		self.actions.clear()
	}
}

