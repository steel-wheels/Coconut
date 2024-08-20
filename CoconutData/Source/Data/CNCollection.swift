/**
 * @file	CNCollection.swift
 * @brief	Define CNCollection class
 * @par Copyright
 *   Copyright (C) 2021-2022 Steel Wheels Project
 */

import Foundation

public class CNCollectionData
{
    private static let InterfaceName    = "CollectionDataIF"

    private static let CountItem        = "count"
    private static let ItemItem         = "item"
    private static let AddItemItem      = "addItem"
    private static let AddItemsItem     = "addItems"

	private var mIcons: Array<CNIcon>

    public static func allocateInterfaceType(iconIF iconif: CNInterfaceType) -> CNInterfaceType {
        typealias M = CNInterfaceType.Member
        let vtype: CNValueType = .interfaceType(iconif)
        let members: Array<M> = [
            M(name: CountItem,      type: .numberType),
            M(name: ItemItem,       type: .functionType(.nullable(.stringType), [.numberType])),
            M(name: AddItemItem,    type: .functionType(.voidType, [vtype])),
            M(name: AddItemsItem,   type: .functionType(.voidType, [.arrayType(vtype)]))
        ]
        return CNInterfaceType(name: InterfaceName, base: nil, members: members)
    }

	public init(){
		mIcons = []
	}

	public var count: Int { get { return mIcons.count }}

	public func icon(at idx: Int) -> CNIcon? {
        if 0 <= idx && idx < mIcons.count {
            return mIcons[idx]
        } else {
            return nil
        }
	}

    public func set(icons itms: Array<CNIcon>) {
            mIcons = itms
    }

    public func add(icon itm: CNIcon) {
        mIcons.append(itm)
    }

	public func add(icons itms: Array<CNIcon>) {
        mIcons.append(contentsOf: itms)
	}

	public func toText() -> CNText {
		let sect = CNTextSection()
        sect.header = "{" ; sect.footer = "}"
        for icon in mIcons {
            sect.add(text: icon.toText())
        }
		return sect
	}
}


