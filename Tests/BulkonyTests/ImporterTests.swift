//
// Created by 堀田竜也 on 2021/09/13.
//

import Foundation
import XCTest

@testable import Bulkony

final class ImporterTests: XCTestCase {

    func testsCsvImporter() throws {
        let content = """
            id,name,email
            1,alice,alice@example.com
            2,bob,bob@example.com
            3,charlie,charlie@example.com
            """
        let url = createCsv(content)

        let rowVisitor = TextArrayRowVisitor()
        let importer = ArrayCsvImporter(url, rowVisitor)
        let result = try importer.importData()
        switch result {
        case .success(let count):
            XCTAssertTrue(true)
            XCTAssertEqual(3, count)
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

    func testsDictionaryCsvImporter() throws {
        let content = """
            id,name,email
            1,alice,alice@example.com
            2,bob,bob@example.com
            3,charlie,charlie@example.com
            """
        let url = createCsv(content)

        let rowVisitor = TextDictionaryRowVisitor()
        let importer = DictionaryCsvImporter(url, rowVisitor)
        let result = try importer.importData()
        switch result {
        case .success(let count):
            XCTAssertTrue(true)
            XCTAssertEqual(3, count)
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

    func testsValidateDictionaryCsvImporter() throws {
        let content = """
            id,name,email
            1,alice,alice@example.com
            a,,bobexample.com
            3,charlie,charlie@example.com
            """
        let url = createCsv(content)

        let rowVisitor = ValidateDictionaryRowVisitor()
        let importer = DictionaryCsvImporter(url, rowVisitor)
        let result = try importer.importData()
        switch result {
        case .success(_):
            XCTFail()
        case .failure(let importError):
            let errors = importError.errors
            XCTAssertEqual(1, errors.count)
            let rowError = errors.first!
            XCTAssertEqual(3, rowError.count)
            XCTAssertEqual("id", rowError[0].header)
            XCTAssertEqual("IDが数値ではありません。id: a lineNumber: 2", rowError[0].message)
            XCTAssertEqual("name", rowError[1].header)
            XCTAssertEqual("名前は必須です。name:  lineNumber: 2", rowError[1].message)
            XCTAssertEqual("email", rowError[2].header)
            XCTAssertEqual("メールアドレスが不正です。email: bobexample.com lineNumber: 2", rowError[2].message)
        }
        let csvString = rowVisitor.data
        let expected = """
            1,alice,alice@example.com
            3,charlie,charlie@example.com
            """
        XCTAssertEqual(expected, csvString)

        try FileManager.default.removeItem(atPath: url.path)
    }

    private func createCsv(_ content: String) -> URL {
        let tempDir = NSTemporaryDirectory()
        let filename = NSUUID().uuidString + ".csv"
        let url: URL = .init(fileURLWithPath: tempDir).appendingPathComponent(filename)
        print("\(url)")
        FileManager.default.createFile(atPath: url.path, contents: content.data(using: .utf8))
        return url
    }
}

private class TextArrayRowVisitor: ArrayRowVisitor {

    public private(set) var data: String = ""

    public override func visit(row: Row, lineNumber: UInt64, context: inout Context) throws {
        if !data.isEmpty {
            data += "\n"
        }
        data += row.joined(separator: ",")
    }
}

private class TextDictionaryRowVisitor: DictionaryRowVisitor {

    public private(set) var data: String = ""

    private let columns = ["id", "name", "email"]

    public override func visit(row: Row, lineNumber: UInt64, context: inout Context) throws {
        data = buildCsv(data, columns: columns, row: row)
    }

}

private class ValidateDictionaryRowVisitor: TextDictionaryRowVisitor {

    public override func validate(row: Row, lineNumber: UInt64, context: inout Context) throws -> [RowError] {
        var errors = [RowError]()

        let id = row["id"]!
        if UInt32(id) == nil {
            errors.append(
                RowError(
                    header: "id",
                    message: "IDが数値ではありません。id: \(id) lineNumber: \(lineNumber)"
                )
            )
        }

        let name = row["name"]!
        if name.isEmpty {
            errors.append(
                RowError(
                    header: "name",
                    message: "名前は必須です。name: \(name) lineNumber: \(lineNumber)"
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
        lineNumber: UInt64,
        errors: RowErrors,
        context: inout Context
    ) throws -> ErrorContinuation {
        ErrorContinuation.continuation
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

private func buildCsv(_ data: String, columns: [String], row: [String: String]) -> String {
    let values: [String] = columns.map { column in
        row[column]!
    }
    return data + (!data.isEmpty ? "\n" : "") + values.joined(separator: ",")
}
