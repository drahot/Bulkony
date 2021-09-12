//
// Created by 堀田竜也 on 2021/09/05.
//

import Foundation

public enum ErrorContinuation {
    case continuation
    case abort
}

public protocol RowHandler {
    typealias Errors = [Error]
    typealias ErrorsCollection = [Errors]

    func handle<R>(row: [R], lineNumber: UInt32, context: inout Context)
    func validate<R>(row: [R], lineNumber: UInt32, context: inout Context) -> [Error]
    func onError<R>(row: [R], lineNumber: UInt32, rowErrors: Errors, context: inout Context) -> ErrorContinuation
}
