//
// Created by 堀田竜也 on 2021/09/05.
//

import Foundation

public protocol RowHandler {
    typealias RowWithHeader = [String: String]
    typealias Row = [String]
    typealias Errors = [Error]
    typealias ErrorsCollection = [Errors]

    func handle(row: RowWithHeader, lineNumber: UInt32, context: inout Context)
    func handle(row: Row, lineNumber: UInt32, context: inout Context)
    func validate(row: RowWithHeader, lineNumber: UInt32, context: inout Context) -> [Error]
    func validate(row: Row, lineNumber: UInt32, context: inout Context) -> [Error]
    func onError(row: RowWithHeader, lineNumber: UInt32, rowErrors: Errors, context: inout Context)
    func onError(row: Row, lineNumber: UInt32, rowErrors: Errors, context: inout Context)
}
