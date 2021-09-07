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
        try CSV(url: filePath).enumerateAsDictWithIndex { index, row in
            rowHandler.handle(row: row, lineNumber: index)
        }
    }

    public func importData() throws {
        try CSV(url: filePath).enumerateAsArrayWithIndex { index, row in
            rowHandler.handle(row: row, lineNumber: index)
        }
    }

}

fileprivate extension CSV {

    func enumerateAsDictWithIndex(_ block: @escaping ((UInt32, [String : String])) -> ()) throws {
        var index: UInt32 = 0
        try enumerateAsDict { row in
            block((index, row))
            index += 1
        }
    }

    func enumerateAsArrayWithIndex(_ block: @escaping ((UInt32, [String])) -> ()) throws {
        var index: UInt32 = 0
        try enumerateAsArray { row in
            block((index, row))
            index += 1
        }
    }

}