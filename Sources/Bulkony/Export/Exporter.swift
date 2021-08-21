//
// Created by 堀田竜也 on 2021/08/08.
//

import Foundation

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

    public private(set) var filePath: URL
    public private(set) var rowGenerator: RowGenerator
    public private(set) var rootElement: String
    public private(set) var rowElement: String

    init(_ filePath: String, _ rowGenerator: RowGenerator, _ rootElement: String = "root",
         _ rowElement: String = "row") {
        let url = URL(fileURLWithPath: filePath)
        self.init(url, rowGenerator, rootElement, rowElement)
    }

    init(_ filePath: URL, _ rowGenerator: RowGenerator, _ rootElement: String = "root",
         _ rowElement: String = "row") {
        self.rootElement = rootElement
        self.rowElement = rowElement
        self.filePath = filePath
        self.rowGenerator = rowGenerator
    }

}

extension XmlExporter {

    public func export() throws {
        let root = XMLElement(name: rootElement)
        let xml = XMLDocument(rootElement: root)
        xml.characterEncoding = "UTF-8"
        let headers = rowGenerator.getHeaders()
        guard !headers.isEmpty else {
            throw NSError(domain: "headers is empty", code: -2, userInfo: nil)
        }
        try rowGenerator.getRows().forEach { data in
            let row = XMLElement(name: rowElement)
            root.addChild(row)
            try _adjustData(headers, data).enumerated().forEach { offset, value in
                let attribute = XMLNode(kind: .attribute)
                attribute.name = headers[offset]
                attribute.stringValue = String(describing: value)
                row.addAttribute(attribute)
            }
        }
        FileManager.default.createFile(
                atPath: filePath.path,
                contents: xml.xmlString.data(using: .utf8),
                attributes: nil
        )
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
            let data = try _adjustData(headers, row)
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

private func _adjustData(_ headers: [String], _ data: [Any]) throws -> [Any] {
    let count = data.count - headers.count
    if count < 0 {
        throw NSError(domain: "header count does not match rows", code: -1, userInfo: nil)
    }
    return data.dropLast(count).map {
        $0
    }
}
