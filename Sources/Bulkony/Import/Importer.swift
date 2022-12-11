//
//  Importer.swift
//  Bulkony
//
//  Created by 堀田竜也 on 2021/09/05.
//

import Foundation
import SwiftCSV

public protocol Importer {
    func importData() throws -> Result<UInt64, ImportError>
}

public struct ArrayCsvImporter: Importer {
    private let filePath: URL
    private let rowVisitor: any ArrayRowVisitor
    private let encoding: String.Encoding
    private let delimiter: CSVDelimiter

    public init(
        _ filePath: String,
        _ rowVisitor: any ArrayRowVisitor,
        delimiter: CSVDelimiter = .comma,
        encoding: String.Encoding = .utf8
    ) {
        self.init(.init(fileURLWithPath: filePath), rowVisitor, delimiter: delimiter, encoding: encoding)
    }

    public init(
        _ filePath: URL,
        _ rowVisitor: any ArrayRowVisitor,
        delimiter: CSVDelimiter = .comma,
        encoding: String.Encoding = .utf8
    ) {
        self.filePath = filePath
        self.rowVisitor = rowVisitor
        self.encoding = encoding
        self.delimiter = delimiter
    }
}

extension ArrayCsvImporter {
    public func importData() throws -> Result<UInt64, ImportError> {
        let rows: [[String]] = try CSV<Enumerated>(url: filePath, delimiter: delimiter, encoding: encoding).rows
        return try processImport(rows, rowVisitor)
    }
}

public struct DictionaryCsvImporter: Importer {
    private let filePath: URL
    private let rowVisitor: any DictionaryRowVisitor
    private let encoding: String.Encoding
    private let delimiter: CSVDelimiter

    public init(
        _ filePath: String,
        _ rowVisitor: any DictionaryRowVisitor,
        delimiter: CSVDelimiter = .comma,
        encoding: String.Encoding = .utf8
    ) {
        self.init(.init(fileURLWithPath: filePath), rowVisitor, delimiter: delimiter, encoding: encoding)
    }

    public init(
        _ filePath: URL,
        _ rowVisitor: any DictionaryRowVisitor,
        delimiter: CSVDelimiter = .comma,
        encoding: String.Encoding = .utf8
    ) {
        self.filePath = filePath
        self.rowVisitor = rowVisitor
        self.encoding = encoding
        self.delimiter = delimiter
    }
}

extension DictionaryCsvImporter {
    public func importData() throws -> Result<UInt64, ImportError> {
        let rows: [[String: String]] = try CSV<Named>(url: filePath, delimiter: delimiter, encoding: encoding).rows
        return try processImport(rows, rowVisitor)
    }
}

private func processImport<R, V: RowVisitor>(
    _ rows: [R], _ rowVisitor: V
) throws -> Result<UInt64, ImportError> {
    var context = Context()
    var errorList = [[RowError]]()
    var successCount: UInt64 = 0

    for (index, row) in rows.enumerated() {
        let lineNumber = UInt64(index + 1)
        let errors = try rowVisitor.validate(row: row as! V.Row, lineNumber: lineNumber, context: &context)
        if !errors.isEmpty {
            errorList.append(errors)
            if try rowVisitor.onError(
                row: row as! V.Row,
                lineNumber: lineNumber,
                errors: errors,
                context: &context
            ) == .abort {
                return .failure(ImportError(errors: errorList))
            }
            continue
        }
        try rowVisitor.visit(row: row as! V.Row, lineNumber: lineNumber, context: &context)
        successCount += 1
    }

    return errorList.isEmpty
        ? .success(successCount)
        : .failure(ImportError(errors: errorList))
}
