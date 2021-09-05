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
    public private(set) var rootName: String
    public private(set) var rowName: String

    init(_ filePath: String, _ rowGenerator: RowGenerator, _ rootName: String = "root",
         _ rowName: String = "row") {
        let url = URL(fileURLWithPath: filePath)
        self.init(url, rowGenerator, rootName, rowName)
    }

    init(_ filePath: URL, _ rowGenerator: RowGenerator, _ rootName: String = "root",
         _ rowName: String = "row") {
        self.rootName = rootName
        self.rowName = rowName
        self.filePath = filePath
        self.rowGenerator = rowGenerator
    }

}

extension XmlExporter {
    public func export() throws {
        let root = XMLElement(name: rootName)
        let xml = XMLDocument(rootElement: root)
        xml.characterEncoding = "UTF-8"
        let headers = rowGenerator.getHeaders()
        guard !headers.isEmpty else {
            throw NSError(domain: "headers is empty", code: -2, userInfo: nil)
        }
        try rowGenerator.getRows().forEach { data in
            let row = XMLElement(name: rowName)
            root.addChild(row)
            try _adjustData(headers, data).enumerated().forEach { offset, value in
                let attribute = XMLNode(kind: .attribute)
                attribute.name = headers[offset]
                attribute.stringValue = String(describing: value)
                row.addAttribute(attribute)
            }
        }
        _createFile(filePath.path, xml.xmlString.data(using: .utf8))
    }
}

public struct JsonExporter: Exporter {

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

extension JsonExporter {
    public func export() throws {
        let headers = rowGenerator.getHeaders()
        guard !headers.isEmpty else {
            throw NSError(domain: "headers is empty", code: -2, userInfo: nil)
        }
        let jsonData: [Dictionary<String, Any>] = try rowGenerator.getRows().map { data in
            let pairs: [(String, Any)] = try _adjustData(headers, data).enumerated().map { offset, value in
                (headers[offset], value)
            }
            return Dictionary(pairs, uniquingKeysWith: { (first, _) in first })
        }
        let json = try JSONSerialization.data(withJSONObject: jsonData)
        _createFile(filePath.path, json)
    }
}

private func _createFile(_ path: String, _ data: Data?) {
    FileManager.default.createFile(
            atPath: path,
            contents: data,
            attributes: nil
    )
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
    _createFile(filePath.path, data.data(using: .utf8))
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
