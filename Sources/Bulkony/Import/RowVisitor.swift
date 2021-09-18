//
// Created by 堀田竜也 on 2021/09/05.
//

import Foundation

public enum ErrorContinuation {
    case continuation
    case abort
}

public protocol RowVisitor {
    associatedtype Row
    typealias Errors = [Error]
    typealias ErrorsCollection = [Errors]

    func handle(row: Row, lineNumber: UInt32, context: inout Context)
    func validate(row: Row, lineNumber: UInt32, context: inout Context) -> [Error]
    func onError(row: Row, lineNumber: UInt32, rowErrors: Errors, context: inout Context) -> ErrorContinuation
}

open class ArrayRowVisitor: RowVisitor {
    public typealias Row = [String]

    public func handle(row: Row, lineNumber: UInt32, context: inout Context) {
    }
    
    public func validate(row: Row, lineNumber: UInt32, context: inout Context) -> [Error] {
        [Error]()
    }
    
    public func onError(row: Row, lineNumber: UInt32, rowErrors: Errors, context: inout Context) -> ErrorContinuation {
        ErrorContinuation.continuation
    }

}

public class EchoArrayRowVisitor: ArrayRowVisitor {
    
    public override func handle(row: Row, lineNumber: UInt32, context: inout Context) {
        print("\(row)")
    }

}

