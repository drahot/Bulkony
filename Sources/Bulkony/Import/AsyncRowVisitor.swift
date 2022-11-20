//
// Created by 堀田竜也 on 2022/11/20.
//

import Foundation

public protocol AsyncRowVisitor {
    associatedtype Row
    typealias RowErrors = [RowError]

    func visit(row: Row, lineNumber: UInt64, context: inout Context) async throws
    func validate(row: Row, lineNumber: UInt64, context: inout Context) async throws -> [RowError]
    func onError(row: Row, lineNumber: UInt64, errors: RowErrors, context: inout Context) async throws -> ErrorContinuation
}

public protocol AsyncArrayRowVisitor: AsyncRowVisitor where Row == [String] {
}

public protocol AsyncDictionaryRowVisitor: AsyncRowVisitor where Row == [String: String] {
}
