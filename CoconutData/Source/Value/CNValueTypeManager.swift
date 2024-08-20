/*
 * @file	CNValueTypeManager.swift
 * @brief	Define CNValueTypeManager class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

#if os(iOS)
import UIKit
#endif
import SpriteKit
import Foundation

public class CNValueTypeManager
{
	private static var mSharedManager: CNValueTypeManager? = nil

	private static let EnumSection		= "enum"
	private static let InterfaceSection	= "interface"

	private var mTypes:  Dictionary<String, CNValueType>
	private var mParent: CNValueTypeManager?

	public static var shared: CNValueTypeManager { get {
		if let mgr = mSharedManager {
			return mgr
		} else {
			let newmgr = CNValueTypeManager()
			newmgr.setupEnumTypes()
			mSharedManager = newmgr

			/* The following operation will call this to
			 * access this manager. So the mSharedManager must be set
			 * before calling this methiod.
			 */
			newmgr.setupInterfaceTypes()

			return newmgr
		}
	}}

	private init() {
		mTypes  = [:]
		mParent = nil
	}

	public init(parent par: CNValueTypeManager){
		mTypes  = [:]
		mParent = par
	}

	public var typeNames: Array<String> { get {
		var result: Array<String> = []
		if let parent = mParent {
			result.append(contentsOf: parent.typeNames)
		}
		result.append(contentsOf: mTypes.keys)
		return result
	}}

	public func search(byName name: String) -> CNValueType? {
		if let typ = mTypes[name] {
			return typ
		} else if let parent = mParent {
			return parent.search(byName: name)
		} else {
			return nil
		}
	}

	public func searchEnumType(byTypeName name: String) -> CNEnumType? {
		if let type = search(byName: name) {
			switch type {
			case .enumType(let etype):
				return etype
			default:
				break
			}
		}
		return nil
	}

	public func searchEnums(byMemberName name: String) -> Array<CNEnum> {
		var result: Array<CNEnum> = []
		for type in self.typeNames {
			if let etype = searchEnumType(byTypeName: type) {
				if let eobj = etype.allocate(name: name) {
					result.append(eobj)
				}
			}
		}
		return result
	}

	public func searchInterfaceType(byTypeName name: String) -> CNInterfaceType? {
		if let type = search(byName: name) {
			switch type {
			case .interfaceType(let iftype):
				return iftype
			default:
				break
			}
		}
		return nil
	}

	public func add(enumType etype: CNEnumType) {
		guard mTypes[etype.typeName] == nil else {
			CNLog(logLevel: .error, message: "Multiple define enum name: \(etype.typeName)", atFunction: #function, inFile: #file)
			return
		}
		mTypes[etype.typeName] = .enumType(etype)
	}

	public func add(interfaceType iftype: CNInterfaceType) {
		guard mTypes[iftype.name] == nil else {
			CNLog(logLevel: .error, message: "Multiple define interface name: \(iftype.name)", atFunction: #function, inFile: #file)
			return
		}
		mTypes[iftype.name] = .interfaceType(iftype)
	}

	private func setupEnumTypes() {
		self.add(enumType: CNAlertType.allocateEnumType())
		self.add(enumType: CNDevice.allocateEnumType())
		self.add(enumType: CNExitCode.allocateEnumType())
		self.add(enumType: CNLanguage.allocateEnumType())
		self.add(enumType: CNConfig.LogLevel.allocateEnumType())
		self.add(enumType: CNFileType.allocateEnumType())
		self.add(enumType: CNFileAccessType.allocateEnumType())
		self.add(enumType: CNAxis.allocateEnumType())
		self.add(enumType: CNAlignment.allocateEnumType())
		self.add(enumType: CNButtonState.allocateEnumType())
		self.add(enumType: CNDistribution.allocateEnumType())
		self.add(enumType: CNFont.Size.allocateEnumType())
		self.add(enumType: CNFont.Style.allocateEnumType())
		self.add(enumType: CNSymbol.allocateEnumType())
		self.add(enumType: CNSymbolSize.allocateEnumType())
		self.add(enumType: CNAuthorizeState.allocateEnumType())
		self.add(enumType: CNAnimationState.allocateEnumType())
		self.add(enumType: CNProcessStatus.allocateEnumType())
		self.add(enumType: ComparisonResult.allocateEnumType())
		self.add(enumType: CNSortOrder.allocateEnumType())
		self.add(enumType: CNSpriteMaterial.allocateEnumType())
		self.add(enumType: CNTokenId.allocateEnumType())
		self.add(enumType: CNInterfaceStyle.allocateEnumType())
	}

	private func setupInterfaceTypes() {
		var newifs: Array<CNInterfaceType> = []

		let frameIF = CNInterfaceType(name: "FrameIF", base: nil, members: [])
		newifs.append(frameIF)

		let consoleIF = CNDefaultConsole.allocateInterfaceType()
		newifs.append(consoleIF)

		let characterIF = Character.allocateInterfaceType()
		newifs.append(characterIF)

		let menuItemIF = CNMenuItem.allocateInterfaceType()
		newifs.append(menuItemIF)

		let urlIF = URL.allocateInterfaceType()
		newifs.append(urlIF)

		let fileIF = CNFile.allocateInterfaceType()
		newifs.append(fileIF)

		let pipeIF = Pipe.allocateInterfaceType(fileIF: fileIF)
		newifs.append(pipeIF)

		let fileManagerIF = FileManager.allocateInterfaceType(fileIF: fileIF, urlIF: urlIF)
		newifs.append(fileManagerIF)

		let pointIF = CGPoint.allocateInterfaceType()
		newifs.append(pointIF)

		let sizeIF = CGSize.allocateInterfaceType()
		newifs.append(sizeIF)

		let rectIF = CGRect.allocateInterfaceType()
		newifs.append(rectIF)

		let ovalIF = CNOval.allocateInterfaceType(pointIF: pointIF)
		newifs.append(ovalIF)

		let vectorIF = CGVector.allocateInterfaceType()
		newifs.append(vectorIF)

		let imageIF = CNImage.allocateInterfaceType(sizeIF: sizeIF, frameIF: frameIF)
		newifs.append(imageIF)

		let dateIF = Date.allocateInterfaceType(sizeIF: sizeIF)
		newifs.append(dateIF)

		let rangeIF = NSRange.allocateInterfaceType()
		newifs.append(rangeIF)

		let colorIF = CNColor.allocateInterfaceType()
		newifs.append(colorIF)

		let colorsIF  = CNColors.allocateInterfaceType(colorIF: colorIF)
		newifs.append(colorsIF)

		let graphicsContextIF = CNGraphicsContext.allocateInterfaceType(rectIF: rectIF, colorIF: colorIF)
		newifs.append(graphicsContextIF)

		let bitmapContextIF = CNBitmapContext.allocateInterfaceType(colorIF: colorIF)
		newifs.append(bitmapContextIF)

		let symbolIF = CNSymbol.allocateInterfaceType()
		newifs.append(symbolIF)

		let recordIF = CNValueRecord.allocateInterfaceType()
		newifs.append(recordIF)

		let tableIF = CNValueTable.allocateInterfaceType()
		newifs.append(tableIF)

		let propertiesIF = CNValueProperties.allocateInterfaceType()
		newifs.append(propertiesIF)

        let iconIF = CNIcon.allocateInterfaceType(symbolIF: symbolIF)
        newifs.append(iconIF)

        let collectionIF = CNCollectionData.allocateInterfaceType(iconIF: iconIF)
        newifs.append(collectionIF)

		let escapeSequenceIF = CNEscapeSequence.allocateInterfaceType()
		newifs.append(escapeSequenceIF)

		let escapeSequencesIF = CNEscapeSequences.allocateInterfaceType(escapeSequenceIF: escapeSequenceIF, colorIF: colorIF)
		newifs.append(escapeSequencesIF)

		let escapEcodesIF = CNEscapeCodes.allocateInterfaceType(colorIF: colorIF)
		newifs.append(escapEcodesIF)

		let cursesIF = CNCurses.allocateInterfaceType(colorIF: colorIF)
		newifs.append(cursesIF)

		let tokenIF = CNToken.allocateInterfaceType()
		newifs.append(tokenIF)

		let stringStreamIF = CNStringStream.allocateInterfaceType()
		newifs.append(stringStreamIF)

		let threadIF = CNThread.allocateInterfaceType()
		newifs.append(threadIF)

		let triggerIF = CNTrigger.allocateInterfaceType()
		newifs.append(triggerIF)

		let environmentIF = CNEnvironment.allocateInterfaceType(URLIf: urlIF)
		newifs.append(environmentIF)

		let systemPreferenceIF = CNSystemPreference.allocateInterfaceType()
		newifs.append(systemPreferenceIF)

		let userPreferenceIF = CNUserPreference.allocateInterfaceType(urlIF: urlIF)
		newifs.append(userPreferenceIF)

		let viewPreferenceIF = CNViewPreference.allocateInterfaceType(colorIF: colorIF)
		newifs.append(viewPreferenceIF)

		let preferenceIF = CNPreference.allocateInterfaceType(systemPreferenceIF: systemPreferenceIF, userPreferenceIF: userPreferenceIF, viewPreferenceIF: viewPreferenceIF)
		newifs.append(preferenceIF)

		/* Sprite node operation */
		let spriteNodeDeclIF = CNSpriteNodeDecl.allocateInterfaceType()
		newifs.append(spriteNodeDeclIF)

		let spriteNodeRefIF = CNSpriteNodeRef.allocateInterfaceType(pointIF: pointIF)
		newifs.append(spriteNodeRefIF)

		let spriteFieldIF = CNSpriteField.allocateInterfaceType(sizeInterface: sizeIF, nodeRefIF: spriteNodeRefIF)
		newifs.append(spriteFieldIF)

		let spriteActionsIF = CNSpriteActions.allocateInterfaceType(pointIF: pointIF, vectorIF: vectorIF)
		newifs.append(spriteActionsIF)

		let spriteNodeIF = SKNode.allocateInterfaceType(pointIf: pointIF, sizeIF: sizeIF, vectorIF: vectorIF, triggerIF: triggerIF, actionsIF: spriteActionsIF)
		newifs.append(spriteNodeIF)

		let spriteSceneIF = CNSpriteScene.allocateInterfaceType(fieldIf: spriteFieldIF, sizeIF: sizeIF, triggerIF: triggerIF)
		newifs.append(spriteSceneIF)

		#if os(OSX)
		let procif  = CNProcess.allocateInterfaceType()
		newifs.append(procif)
		#endif

		for iftype in newifs {
			add(interfaceType: iftype)
		}

	}
}
