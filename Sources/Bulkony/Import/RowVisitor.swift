//
// Created by 堀田竜也 on 2021/09/05.
//

import Foundation

public enum ErrorContinuation {
    case continuation
    case abort
}

public struct RowError {

    public private(set) var header: String
    public private(set) var message: String

    public init(header: String, message: String) {
        self.header = header
        self.message = message
    }

}

public protocol RowVisitor: AnyObject {
    associatedtype Row
    typealias RowErrors = [RowError]

    func visit(row: Row, lineNumber: UInt32, context: inout Context) throws
    func validate(row: Row, lineNumber: UInt32, context: inout Context) throws -> [RowError]
    func onError(row: Row, lineNumber: UInt32, errors: RowErrors, context: inout Context) throws -> ErrorContinuation
}

open class ArrayRowVisitor: RowVisitor {
    
    public typealias Row = [String]
    
    public func visit(row: Row, lineNumber: UInt32, context: inout Context) throws {
        notImplemented()
   }

    public func validate(row: Row, lineNumber: UInt32, context: inout Context) throws -> [RowError] {
        [RowError]()
    }

    public func onError(row: Row, lineNumber: UInt32, errors: RowErrors, context: inout Context) throws -> ErrorContinuation {
        ErrorContinuation.continuation
    }
}

open class DictionaryRowVisitor: RowVisitor {
    
    public typealias Row = [String: String]
    
    public func visit(row: Row, lineNumber: UInt32, context: inout Context) throws {
        notImplemented()
    }

    public func validate(row: Row, lineNumber: UInt32, context: inout Context) throws -> [RowError] {
        [RowError]()
    }

    public func onError(row: Row, lineNumber: UInt32, errors: RowErrors, context: inout Context) throws -> ErrorContinuation {
        ErrorContinuation.continuation
    }
}

private func notImplemented() {
    print("No Implemented!!!")
    abort()
}
