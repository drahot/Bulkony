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
        try CSV(url: filePath).enumerateAsDictWithIndex { index, row -> Bool in
            if let errors = rowHandler.validate(row: row, lineNumber: index + 1, context: &context) {
                if !rowHandler.onError(row: row, lineNumber: index + 1, rowErrors: errors, context: &context) {
                    return false
                }
            }
            rowHandler.handle(row: row, lineNumber: index + 1, context: &context)
            return true
        }
    }

    public func importData() throws {
        var context = Context()
        try CSV(url: filePath).enumerateAsArrayWithIndex { index, row -> Bool in
            if let errors = rowHandler.validate(row: row, lineNumber: index + 1, context: &context) {
                if !rowHandler.onError(row: row, lineNumber: index + 1, rowErrors: errors,  context: &context) {
                    return false
                }
            }
            rowHandler.handle(row: row, lineNumber: index + 1, context: &context)
            return true
        }
    }

}

fileprivate extension CSV {

    func enumerateAsDictWithIndex(_ block: @escaping ((UInt32, [String: String])) -> Bool) throws {
        var index: UInt32 = 0
        try enumerateAsDict { row in
            if !block((index, row)) {
                return
            }
            index += 1
        }
    }

    func enumerateAsArrayWithIndex(_ block: @escaping ((UInt32, [String])) -> Bool) throws {
        var index: UInt32 = 0
        try enumerateAsArray { row in
            if !block((index, row)) {
                return
            }
            index += 1
        }
    }

}
