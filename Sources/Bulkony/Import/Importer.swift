//
//  Importer.swift
//  Bulkony
//
//  Created by 堀田竜也 on 2021/09/05.
//

import Foundation

public protocol Importer {
    var filePath: URL { get }
    var rowHandler: RowHandler {get}
    func importDataWithHeader() throws
    func importData() throws
}

