//
//  Importer.swift
//  Bulkony
//
//  Created by 堀田竜也 on 2021/09/05.
//

import Foundation
import SwiftCSV

public protocol Importer {
    var filePath: URL { get }
    var rowHandler: RowVisitor { get }
    func importData() throws
}

public struct CsvImporter: Importer {
    public private(set) var filePath: URL
    public private(set) var rowHandler: RowVisitor

    init(_ filePath: String, _ rowHandler: RowVisitor) {
        let url = URL(fileURLWithPath: filePath)
        self.init(url, rowHandler)
    }

    init(_ filePath: URL, _ rowHandler: RowVisitor) {
        self.filePath = filePath
        self.rowHandler = rowHandler
    }
}

extension CsvImporter {

    public func importData() throws {
        let rows: [[String]] = try CSV(url: filePath).enumeratedRows
        processImport(rows: rows)
    }
    
    private func processImport(rows: [[String]]) {
        var context = Context()
        for (index, row) in rows.enumerated() {
            let lineNumber = UInt32(index + 1)

            let errors = rowHandler.validate(row: row, lineNumber: lineNumber, context: &context)
            if !errors.isEmpty {
                if rowHandler.onError(row: row, lineNumber: lineNumber, rowErrors: errors, context: &context) == .abort {
                    return
                }
                continue
            }

            rowHandler.handle(row: row, lineNumber: lineNumber, context: &context)
        }
    }

}

final class RowVisitorImpl: RowVisitor {
    func handle(row: [String], lineNumber: UInt32, context: inout Context) {
    }
    
    func validate(row: [String], lineNumber: UInt32, context: inout Context) -> [Error] {
        [Error]()
    }
    
    func onError(row: [String], lineNumber: UInt32, rowErrors: Errors, context: inout Context) -> ErrorContinuation {
        ErrorContinuation.continuation
    }
}
