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
    var rowHandler: RowHandler { get }
    func importDataWithHeader() throws
    func importData() throws
}

public struct CsvImporter: Importer {
    public private(set) var filePath: URL
    public private(set) var rowHandler: RowHandler

    init(_ filePath: String, _ rowHandler: RowHandler) {
        let url = URL(fileURLWithPath: filePath)
        self.init(url, rowHandler)
    }

    init(_ filePath: URL, _ rowHandler: RowHandler) {
        self.filePath = filePath
        self.rowHandler = rowHandler
    }
}

extension CsvImporter {

    public func importDataWithHeader() throws {
        var context = Context()
        for (index, row) in try CSV(url: filePath).namedRows.enumerated() {
            let lineNumber = UInt32(index + 1)
            if let errors = rowHandler.validate(row: row, lineNumber: lineNumber, context: &context) {
                if !rowHandler.onError(row: row, lineNumber: lineNumber, rowErrors: errors, context: &context) {
                    return
                }
            }
            rowHandler.handle(row: row, lineNumber: lineNumber, context: &context)
        }
    }

    public func importData() throws {
        var context = Context()
        for (index, row) in try CSV(url: filePath).enumeratedRows.enumerated() {
            let lineNumber = UInt32(index + 1)
            if let errors = rowHandler.validate(row: row, lineNumber: lineNumber, context: &context) {
                if !rowHandler.onError(row: row, lineNumber: lineNumber, rowErrors: errors, context: &context) {
                    return
                }
            }
            rowHandler.handle(row: row, lineNumber: lineNumber, context: &context)
        }
    }

}
