//
//  Importer.swift
//  Bulkony
//
//  Created by 堀田竜也 on 2021/09/05.
//

import Foundation
import SwiftCSV

public struct ImportError: Error {

    public let errors: [[RowError]]

    fileprivate init(errors: [[RowError]]) {
        self.errors = errors
    }

}

public protocol Importer {
    func importData() throws -> Result<(), ImportError>
}

public struct ArrayCsvImporter: Importer {

    private let filePath: URL
    private let rowVisitor: ArrayRowVisitor

    init(_ filePath: String, _ rowVisitor: ArrayRowVisitor) {
        self.init(.init(fileURLWithPath: filePath), rowVisitor)
    }

    init(_ filePath: URL, _ rowVisitor: ArrayRowVisitor) {
        self.filePath = filePath
        self.rowVisitor = rowVisitor
    }
}

extension ArrayCsvImporter {
    public func importData() throws -> Result<(), ImportError> {
        let rows: [[String]] = try CSV(url: filePath).enumeratedRows
        return try processImport(rows, rowVisitor)
    }
}

public struct DictionaryCsvImporter: Importer {

    private let filePath: URL
    private let rowVisitor: DictionaryRowVisitor

    init(_ filePath: String, _ rowVisitor: DictionaryRowVisitor) {
        self.init(.init(fileURLWithPath: filePath), rowVisitor)
    }

    init(_ filePath: URL, _ rowVisitor: DictionaryRowVisitor) {
        self.filePath = filePath
        self.rowVisitor = rowVisitor
    }
}

extension DictionaryCsvImporter {
    public func importData() throws -> Result<(), ImportError> {
        let rows: [[String: String]] = try CSV(url: filePath).namedRows
        return try processImport(rows, rowVisitor)
    }
}

private func processImport<R, V: RowVisitor>(_ rows: [R], _ rowVisitor: V) throws -> Result<(), ImportError> {
    var context = Context()
    var errorList = [[RowError]]()

    for (index, row) in rows.enumerated() {
        let lineNumber = UInt32(index + 1)
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
    }

    return errorList.isEmpty
        ? .success(())
        : .failure(ImportError(errors: errorList))
}
