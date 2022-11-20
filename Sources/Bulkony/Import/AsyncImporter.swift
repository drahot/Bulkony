//
// Created by 堀田竜也 on 2022/11/20.
//

import Foundation
import SwiftCSV

public protocol AsyncImporter  {
    func importData() async throws -> Result<UInt64, ImportError>
}

public struct AsyncArrayCsvImporter: AsyncImporter {
    private let filePath: URL
    private let rowVisitor: any AsyncArrayRowVisitor
    private let encoding: String.Encoding
    private let delimiter: CSVDelimiter

    public init(
        _ filePath: String,
        _ rowVisitor: any AsyncArrayRowVisitor,
        delimiter: CSVDelimiter = .comma,
        encoding: String.Encoding = .utf8
    ) {
        self.init(.init(fileURLWithPath: filePath), rowVisitor, delimiter: delimiter, encoding: encoding)
    }

    public init(
        _ filePath: URL,
        _ rowVisitor: any AsyncArrayRowVisitor,
        delimiter: CSVDelimiter = .comma,
        encoding: String.Encoding = .utf8
    ) {
        self.filePath = filePath
        self.rowVisitor = rowVisitor
        self.encoding = encoding
        self.delimiter = delimiter
    }
}

extension AsyncArrayCsvImporter {
    public func importData() async throws -> Result<UInt64, ImportError> {
        let rows: [[String]] = try CSV<Enumerated>(url: filePath, delimiter: delimiter, encoding: encoding).rows
        return try await processImport(rows, rowVisitor)
    }
}

public struct AsyncDictionaryCsvImporter: AsyncImporter {
    private let filePath: URL
    private let rowVisitor: any AsyncDictionaryRowVisitor
    private let encoding: String.Encoding
    private let delimiter: CSVDelimiter

    public init(
        _ filePath: String,
        _ rowVisitor: any AsyncDictionaryRowVisitor,
        delimiter: CSVDelimiter = .comma,
        encoding: String.Encoding = .utf8
    ) {
        self.init(.init(fileURLWithPath: filePath), rowVisitor, delimiter: delimiter, encoding: encoding)
    }

    public init(
        _ filePath: URL,
        _ rowVisitor: any AsyncDictionaryRowVisitor,
        delimiter: CSVDelimiter = .comma,
        encoding: String.Encoding = .utf8
    ) {
        self.filePath = filePath
        self.rowVisitor = rowVisitor
        self.encoding = encoding
        self.delimiter = delimiter
    }
}

extension AsyncDictionaryCsvImporter {
    public func importData() async throws -> Result<UInt64, ImportError> {
        let rows: [[String: String]] = try CSV<Named>(url: filePath, delimiter: delimiter, encoding: encoding).rows
        return try await processImport(rows, rowVisitor)
    }
}

fileprivate func processImport<R, V: AsyncRowVisitor>(_ rows: [R], _ rowVisitor: V) async throws -> Result<UInt64, ImportError> {
    var context = Context()
    var errorList = [[RowError]]()
    var successCount: UInt64 = 0

    for (index, row) in rows.enumerated() {
        let lineNumber = UInt64(index + 1)
        let errors = try await rowVisitor.validate(row: row as! V.Row, lineNumber: lineNumber, context: &context)
        if !errors.isEmpty {
            errorList.append(errors)
            if try await rowVisitor.onError(
                row: row as! V.Row,
                lineNumber: lineNumber,
                errors: errors,
                context: &context
            ) == .abort {
                return .failure(ImportError(errors: errorList))
            }
            continue
        }
        try await rowVisitor.visit(row: row as! V.Row, lineNumber: lineNumber, context: &context)
        successCount += 1
    }

    return errorList.isEmpty
        ? .success(successCount)
        : .failure(ImportError(errors: errorList))
}
