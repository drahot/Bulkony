//
//  Importer.swift
//  Bulkony
//
//  Created by 堀田竜也 on 2021/09/05.
//

import Foundation
import SwiftCSV

public protocol Importer {
    func importData() throws
}

public struct ArrayCsvImporter: Importer {
    
    private var filePath: URL
    private var rowVisitor: ArrayRowVisitor

    init(_ filePath: String, _ rowVisitor: ArrayRowVisitor) {
        let url = URL(fileURLWithPath: filePath)
        self.init(url, rowVisitor)
    }

    init(_ filePath: URL, _ rowVisitor: ArrayRowVisitor) {
        self.filePath = filePath
        self.rowVisitor = rowVisitor
    }
}

extension ArrayCsvImporter {

    public func importData() throws {
        let rows: [[String]] = try CSV(url: filePath).enumeratedRows
        processImport(rows: rows, rowVisitor: rowVisitor)
    }

}

public struct DictionaryCsvImporter: Importer {
    
    private var filePath: URL
    private var rowVisitor: DictionaryRowVisitor

    init(_ filePath: String, _ rowVisitor: DictionaryRowVisitor) {
        let url = URL(fileURLWithPath: filePath)
        self.init(url, rowVisitor)
    }

    init(_ filePath: URL, _ rowVisitor: DictionaryRowVisitor) {
        self.filePath = filePath
        self.rowVisitor = rowVisitor
    }
}


extension DictionaryCsvImporter {
    
    public func importData() throws {
        let rows: [[String: String]] = try CSV(url: filePath).namedRows
        processImport(rows: rows, rowVisitor: rowVisitor)
    }

}

private func processImport<R, V: RowVisitor>(rows: [R], rowVisitor: V) {
    
    var context = Context()
    for (index, row) in rows.enumerated() {
        let lineNumber = UInt32(index + 1)

        let errors = rowVisitor.validate(row: row as! V.Row, lineNumber: lineNumber, context: &context)
        if !errors.isEmpty {
            if rowVisitor.onError(row: row as! V.Row, lineNumber: lineNumber, rowErrors: errors, context: &context) == .abort {
                return
            }
            continue
        }

        rowVisitor.visit(row: row as! V.Row, lineNumber: lineNumber, context: &context)
    }
    
}
