//
// Created by 堀田竜也 on 2021/09/08.
//

import Foundation

public struct Context: Collection {

    public typealias Index = Array<Any>.Index
    public typealias Element = Any

    public var startIndex: Index {
        storage.startIndex
    }

    public var endIndex: Index {
        storage.endIndex
    }

    private var storage: [Any]

    init() {
        storage = []
    }

    public subscript(position: Index) -> Element {
        storage[position]
    }

    public func index(after i: Index) -> Index {
        storage.index(after: i)
    }

    public mutating func append(_ newElement: Element) {
        storage.append(newElement)
    }
}
