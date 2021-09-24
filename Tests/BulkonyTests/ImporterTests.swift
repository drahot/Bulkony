//
// Created by 堀田竜也 on 2021/09/13.
//

import Foundation
import XCTest

@testable import Bulkony

final class ImporterTests: XCTestCase {

    func testsCsvImporter() throws {
        let tempDir = NSTemporaryDirectory()
        let filename = NSUUID().uuidString + ".csv"
        let url: URL = .init(fileURLWithPath: tempDir).appendingPathComponent(filename)
        print("\(url)")
        let content = """
            id,name,email
            1,alice,alice@example.com
            2,bob,bob@example.com
            3,charlie,charlie@example.com
            """
        FileManager.default.createFile(atPath: url.path, contents: content.data(using: .utf8))

        let rowVisitor = TextDictionaryRowVisitor()
        let importer = DictionaryCsvImporter(url, rowVisitor)
        let result = try importer.importData()
        switch result {
        case .success(()):
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
        let csvString = rowVisitor.data
        let expected = """
            1,alice,alice@example.com
            2,bob,bob@example.com
            3,charlie,charlie@example.com
            """
        XCTAssertEqual(expected, csvString)

        try FileManager.default.removeItem(atPath: url.path)
    }

    func testsValidateCsvImporter() throws {
        let tempDir = NSTemporaryDirectory()
        let filename = NSUUID().uuidString + ".csv"
        let url: URL = .init(fileURLWithPath: tempDir).appendingPathComponent(filename)
        print("\(url)")
        let content = """
            id,name,email
            1,alice,alice@example.com
            a,,bobexample.com
            3,charlie,charlie@example.com
            """
        FileManager.default.createFile(atPath: url.path, contents: content.data(using: .utf8))
        let rowVisitor = ValidateDictionaryRowVisitor()
        let importer = DictionaryCsvImporter(url, rowVisitor)
        let result = try importer.importData()
        switch result {
        case .success(()):
            XCTFail()
        case .failure(let importError):
            let errors = importError.errors
            XCTAssertEqual(1, errors.count)
            let rowError = errors.first!
            XCTAssertEqual(3, rowError.count)
        }
    }
}

private class TextDictionaryRowVisitor: DictionaryRowVisitor {

    public private(set) var data: String = ""

    private var columns = ["id", "name", "email"]

    public override func visit(row: Row, lineNumber: UInt32, context: inout Context) throws {
        let values: [String] = columns.map { column in
            row[column]!
        }
        if !data.isEmpty {
            data += "\n"
        }
        data += values.joined(separator: ",")
    }

}

private class ValidateDictionaryRowVisitor: DictionaryRowVisitor {

    public override func visit(row: Row, lineNumber: UInt32, context: inout Context) throws {
    }

    public override func validate(row: Row, lineNumber: UInt32, context: inout Context) throws -> [RowError] {
        var errors = [RowError]()

        let id = row["id"]!
        if UInt32(id) == nil {
            errors.append(
                RowError(
                    header: "id",
                    message: "IDが数値ではありません。。id: \(id) lineNumber: \(lineNumber)"
                )
            )
        }

        let name = row["name"]!
        if name.isEmpty {
            errors.append(
                RowError(
                    header: "name",
                    message: "名前は必須です。id: \(id) lineNumber: \(lineNumber)"
                )
            )
        }

        let email = row["email"]!
        if !validateEmail(email) {
            errors.append(
                RowError(
                    header: "email",
                    message: "メールアドレスが不正です。email: \(email) lineNumber: \(lineNumber)"
                )
            )
        }

        return errors
    }

    public override func onError(
        row: Row,
        lineNumber: UInt32,
        errors: RowErrors,
        context: inout Context
    ) throws -> ErrorContinuation {
        ErrorContinuation.abort
    }

    private func validateEmail(_ email: String) -> Bool {
        let pattern =
            "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}"
            + "[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}"
            + "[a-zA-Z0-9])?)*$"
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        return regex.firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.count)) != nil
    }
}
