//
// Created by 堀田竜也 on 2021/09/05.
//

import Foundation

public protocol RowHandler {

    typealias Errors = [Error]
    typealias ErrorsCollection = [Errors]

    func handle(row: [String: String], lineNumber: UInt32, context: inout Context)
    func handle(row: [String], lineNumber: UInt32, context: inout Context)
    func onError(row: [String: String], lineNumber: UInt32, rowErrors: Errors, context: inout Context)
    func onError(row: [String], lineNumber: UInt32, rowErrors: Errors, context: inout Context)
    
}

extension RowHandler {

    func validate(row: [String: String], lineNumber: UInt32, context: inout Context) -> [Error] {
        []
    }

    func validate(row: [String], lineNumber: UInt32, context: inout Context) -> [Error] {
        []
    }

}
