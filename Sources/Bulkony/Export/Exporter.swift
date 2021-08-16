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
        _export(filePath, rowGenerator, SEPARATOR, NEW_LINE, true)
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
        _export(filePath, rowGenerator, SEPARATOR, NEW_LINE)
    }
}

private func _export(
        _ filePath: URL,
        _ rowGenerator: RowGenerator,
        _ separator: Character,
        _ newLine: String,
        _ withBOM: Bool = false) {

    func toData(row: [Any]) -> String {
        row.map {
            _normalize($0, separator)
        }.joined(separator: String(separator))
    }

    func getHeader() -> String {
        let headers = rowGenerator.getHeaders()
        return headers.isEmpty ? "" : toData(row: headers) + newLine
    }

    func getBody() -> String {
        rowGenerator.getRows().map {
            toData(row: $0)
        }.joined(separator: newLine)
    }

    let bom = withBOM ? "\u{FEFF}" : ""
    let data = bom + getHeader() + getBody()
    FileManager.default.createFile(
            atPath: filePath.path,
            contents: data.data(using: .utf8),
            attributes: nil
    )
}

private func _normalize(_ any: Any, _ separator: Character) -> String {
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
