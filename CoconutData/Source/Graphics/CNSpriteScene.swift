/*
 * @file	CNSpriteScene.swift
 * @brief	Define CNSpriteScene class
 * @par Copyright
 *   Copyright (C) 2023-2024  Steel Wheels Project
 */

import SpriteKit
import Foundation

public class CNSpriteScene: SKScene
{
	public typealias InitCallback	= () -> Bool
	public typealias FinishCallback	= (_ time: TimeInterval) -> Bool	// true to finish

	private static let InterfaceName	= "SpriteSceneIF"

	private static let CurrentTimeItem	= "currentTime"
	private static let FieldItem		= "field"
	private static let FinishItem		= "finish"
	private static let SizeItem		= "size"
	private static let TriggerItem		= "trigger"

	static func allocateInterfaceType(fieldIf fldif: CNInterfaceType, sizeIF szif: CNInterfaceType, triggerIF trigif: CNInterfaceType) -> CNInterfaceType {
		typealias M = CNInterfaceType.Member

		let members: Array<M> = [
			M(name: CurrentTimeItem, 	type: .numberType),
			M(name: SizeItem, 	 	type: .interfaceType(szif)),
			M(name: TriggerItem,	 	type: .interfaceType(trigif)),
			M(name: FieldItem,	 	type: .interfaceType(fldif)),
			M(name: FinishItem,		type: .functionType(.voidType, []))
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	private var mInitCallback: 	InitCallback?   = nil
	private var mFinishCallback:	FinishCallback? = nil
	private var mBackgroundNode:	SKSpriteNode?   = nil

	public func setupScene() {
		super.setupNode(material: .scene, machine: "<scene>", nodeId: 0)

		self.scaleMode = .aspectFit
		let world      = self.physicsWorld
		world.gravity  = CGVector(dx: 0.0, dy: 0.0)
		world.speed    = 1.0 // default

		// update field size
		self.field = CNSpriteField()
		self.field.size = self.frame.size
	}

	public func setupCallbacks(initCallback ifunc: @escaping InitCallback, finishCallback ffunc: @escaping FinishCallback) {
		mInitCallback   = ifunc
		mFinishCallback = ffunc
	}

	public override var size: CGSize {
		get { return super.size }
		set(newsize){
			super.size = newsize
			self.field.size = newsize
			if let bgnode = mBackgroundNode {
				bgnode.position = CGPoint(x: size.width/2.0, y: size.height/2.0)
			}
		}
	}

	public func setBackground(imageFile file: URL) {
		/* background node */
		let bgnode = SKSpriteNode(imageNamed: file.path)
		bgnode.setupNode(material: .background, machine: "<background>", nodeId: 0)
		bgnode.position = self.frame.center
		self.addChild(bgnode)
		mBackgroundNode = bgnode
	}

	private var mStarted		= false
	private var mIs1stUpdate	= true

	public var isStarted: Bool { get {
		return mStarted
	}}

	public func start() {
		mStarted = true
	}

	public override func update(_ currentTime: TimeInterval) {
		if !mStarted {
			return
		}

		/* check do finish or not */
		if let finfunc = mFinishCallback {
			if finfunc(currentTime) {
				self.isPaused = true
				return
			}
		}

		if mIs1stUpdate {
			/* update field info */
			self.field.clearNodes()

			/* call init function only once */
			if let cbfunc = mInitCallback {
				if !cbfunc() {
					self.isPaused = true
				}
			}
			mIs1stUpdate = false
		} else {
			/* remove retied nodes */
			removeRetiredNodes()

			/* update field info */
			updateAllFieldInfo()

			/* Wait node run  */
			let trigger = self.trigger
			trigger.trigger()
			while trigger.isRunning() {
				/* wait finish running */
				Thread.sleep(forTimeInterval: 0.0001)
			}

			/* Update nodes */
			var runnodes: Array<SKNode> = []
			for node in self.children {
				if node.isMovable {
					node.trigger.trigger()
					runnodes.append(node)
				}
			}
			for node in runnodes {
				while node.trigger.isRunning() {
					/* wait finish running */
					Thread.sleep(forTimeInterval: 0.0001)
				}
				node.execute()
			}
		}
	}

	private func updateAllFieldInfo() {
		self.field.clearNodes()
		for node in self.children {
			if node.isMovable {
				updateFieldInfo(node: node)
			}
		}
	}

	private func updateFieldInfo(node nd: SKNode) {
		let newref = CNSpriteNodeRef(material: nd.material,
					     nodeId: nd.nodeId,
					     position: nd.position)
		self.field.appendNode(nodeRef: newref)
	}

	private func removeRetiredNodes() {
		var removed: Array<SKNode> = []
		for node in self.children {
			if node.isRetired {
				removed.append(node)
			}
		}
		for node in removed {
			node.removeFromParent()
		}
	}
}

