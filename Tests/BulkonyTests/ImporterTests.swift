//
// Created by 堀田竜也 on 2021/09/13.
//

//@testable import Bulkony
import Foundation
import XCTest

final class ImporterTests: XCTestCase {

    func testsCsvImporter() {
        let tempDir = NSTemporaryDirectory()
        let filename = NSUUID().uuidString + ".csv"
        let url = URL(fileURLWithPath: tempDir).appendingPathComponent(filename)
        let content = """
            id,name,email
            1,alice,alice@example.com
            2,bob,bob@example.com
            3,charlie,charlie@example.com
        """
        FileManager.default.createFile(atPath: url.path, contents: content.data(using: .utf8))

    }

}

fileprivate class RowHandlerImpl: RowHandler {
    func handle<R>(row: [R], lineNumber: UInt32, context: inout Context) {
    }
    
    func validate<R>(row: [R], lineNumber: UInt32, context: inout Context) -> [Error] {
        [Error]()
    }
    
    func onError<R>(row: [R], lineNumber: UInt32, rowErrors: Errors, context: inout Context) -> ErrorContinuation {
        ErrorContinuation.continuation
    }
    
}
