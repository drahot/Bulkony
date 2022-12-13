//
// Created by 堀田竜也 on 2021/08/08.
//

import Foundation

public protocol RowGenerator {
    func getHeaders() -> [String]
    func getRows() -> AnySequence<[Any]>
}

public struct ArrayRowGenerator: RowGenerator {
    private var headers: [String]
    private var rows: AnySequence<[Any]>
    public init(headers: [String], rows: AnySequence<[Any]>) {
        self.headers = headers
        self.rows = rows
    }
}

extension ArrayRowGenerator {
    public func getHeaders() -> [String] {
        headers
    }
    public func getRows() -> AnySequence<[Any]> {
        AnySequence(rows)
    }
}
