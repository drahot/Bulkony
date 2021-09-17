//
// Created by 堀田竜也 on 2021/09/05.
//

import Foundation

public enum ErrorContinuation {
    case continuation
    case abort
}

public protocol RowVisitor {
    typealias Row = [String]
    typealias Errors = [Error]
    typealias ErrorsCollection = [Errors]

    func handle(row: Row, lineNumber: UInt32, context: inout Context)
    func validate(row: Row, lineNumber: UInt32, context: inout Context) -> [Error]
    func onError(row: Row, lineNumber: UInt32, rowErrors: Errors, context: inout Context) -> ErrorContinuation
}

public protocol DictionaryRowVisitor {
    typealias Row = [String: String]
    typealias Errors = [Error]
    typealias ErrorsCollection = [Errors]

    func handle(row: Row, lineNumber: UInt32, context: inout Context)
    func validate(row: Row, lineNumber: UInt32, context: inout Context) -> [Error]
    func onError(row: Row, lineNumber: UInt32, rowErrors: Errors, context: inout Context) -> ErrorContinuation
}
