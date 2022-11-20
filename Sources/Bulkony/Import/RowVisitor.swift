//
// Created by 堀田竜也 on 2021/09/05.
//

import Foundation

public enum ErrorContinuation {
    case continuation
    case abort
}

public struct RowError {

    public let header: String
    public let message: String

    public init(header: String, message: String) {
        self.header = header
        self.message = message
    }

}

public protocol RowVisitor {
    associatedtype Row
    typealias RowErrors = [RowError]

    func visit(row: Row, lineNumber: UInt64, context: inout Context) throws
    func validate(row: Row, lineNumber: UInt64, context: inout Context) throws -> [RowError]
    func onError(row: Row, lineNumber: UInt64, errors: RowErrors, context: inout Context) throws -> ErrorContinuation
}

public protocol ArrayRowVisitor: RowVisitor where Row == [String] {
}

public protocol DictionaryRowVisitor: RowVisitor where Row == [String: String] {
}
