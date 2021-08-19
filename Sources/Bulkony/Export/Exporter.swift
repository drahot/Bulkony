//
// Created by 堀田竜也 on 2021/08/08.
//

import Foundation
import CoreFoundation

public protocol Exporter {
    var filePath: URL { get }
    var rowGenerator: RowGenerator { get }
    func export() throws
}

public struct CsvExporter: Exporter {

    private let NEW_LINE = "\r\n"
    private let SEPARATOR: Character = ","
    public private(set) var filePath: URL
    public private(set) var rowGenerator: RowGenerator

    init(_ filePath: String, _ rowGenerator: RowGenerator) {
        let url = URL(fileURLWithPath: filePath)
        self.init(url, rowGenerator)
    }

    init(_ filePath: URL, _ rowGenerator: RowGenerator) {
        self.filePath = filePath
        self.rowGenerator = rowGenerator
    }

}

extension CsvExporter {
    public func export() throws {
        try _exportCsv(filePath, rowGenerator, SEPARATOR, NEW_LINE, true)
    }
}

public struct TsvExporter: Exporter {

    private let NEW_LINE = "\n"
    private let SEPARATOR: Character = "\t"
    public private(set) var filePath: URL
    public private(set) var rowGenerator: RowGenerator

    init(_ filePath: String, _ rowGenerator: RowGenerator) {
        let url = URL(fileURLWithPath: filePath)
        self.init(url, rowGenerator)
    }

    init(_ filePath: URL, _ rowGenerator: RowGenerator) {
        self.filePath = filePath
        self.rowGenerator = rowGenerator
    }

}

extension TsvExporter {
    public func export() throws {
        try _exportCsv(filePath, rowGenerator, SEPARATOR, NEW_LINE)
    }
}

public struct XmlExporter: Exporter {

    public private(set) var rootElement: String
    public private(set) var filePath: URL
    public private(set) var rowGenerator: RowGenerator

    init(_ filePath: String, _ rowGenerator: RowGenerator, _ rootElement: String) {
        let url = URL(fileURLWithPath: filePath)
        self.init(url, rowGenerator, rootElement)
    }

    init(_ filePath: URL, _ rowGenerator: RowGenerator, _ rootElement: String) {
        self.rootElement = rootElement
        self.filePath = filePath
        self.rowGenerator = rowGenerator
    }

}

extension XmlExporter {

    public func export() throws {
        let root = XMLElement(name: rootElement)
        let xml = XMLDocument(rootElement: root)
        let headers = rowGenerator.getHeaders()
        guard !headers.isEmpty else {
            throw NSError(domain: "headers is empty", code: -1, userInfo: nil)
        }

    }

}

private func _exportCsv(
        _ filePath: URL,
        _ rowGenerator: RowGenerator,
        _ separator: Character,
        _ newLine: String,
        _ withBOM: Bool = false) throws {

    let headers = rowGenerator.getHeaders()

    func toData(row: [Any]) -> String {
        row.map {
            _normalizeCsv($0, separator)
        }.joined(separator: String(separator))
    }

    func getHeader() -> String {
        headers.isEmpty ? "" : toData(row: headers) + newLine
    }

    func getBody() throws -> String {
        try rowGenerator.getRows().map { row in
            let count = row.count - headers.count
            guard count >= 0 else {
                throw NSError(domain: "header count does not match rows", code: -3, userInfo: nil)
            }
            let data = row.dropLast(count).map {
                $0
            }
            return toData(row: data)
        }.joined(separator: newLine)
    }

    let bom = withBOM ? "\u{FEFF}" : ""
    let body = try getBody()
    let data = bom + getHeader() + body
    FileManager.default.createFile(
            atPath: filePath.path,
            contents: data.data(using: .utf8),
            attributes: nil
    )
}

private func _normalizeCsv(_ any: Any, _ separator: Character) -> String {
    guard let str = any as? String else {
        return String(describing: any)
    }

    let (result, enclosedInDoubleQuote) = str.map { c -> (String, Bool) in
        switch c {
        case "\"":
            return (String(c) + "\"", true)
        case separator, "\r\n", "\n":
            return (String(c), true)
        default:
            return (String(c), false)
        }
    }.reduce(("", false)) { current, next -> (String, Bool) in
        (current.0 + next.0, current.1 || next.1)
    }

    return enclosedInDoubleQuote ? "\"\(result)\"" : result
}
