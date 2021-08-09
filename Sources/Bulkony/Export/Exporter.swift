//
// Created by 堀田竜也 on 2021/08/08.
//

import Foundation

public protocol Exporter {
    var filePath: URL { get }
    var rowGenerator: RowGenerator { get }
    func export() throws -> URL

}

public struct CsvExporter: Exporter {

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

    public func export() throws -> URL {
        let fileHandle = try FileHandle(forWritingTo: filePath)

        defer {
            if #available(macOS 10.15, *) {
                do {
                    try fileHandle.close()
                } catch {
                }
            }
        }

        let newline = "\r\n"
        let header = "\(toCsv(row: rowGenerator.getHeaders()))\(newline)"
        fileHandle.write(header.data(using: .utf8)!)

        let rows = rowGenerator.getRows().map {
            toCsv(row: $0)
        }.joined(separator: newline)
        fileHandle.write(rows.data(using: .utf8)!)

        return filePath
    }

    private func toCsv(row: [Any]) -> String {
        "\(row.map { normalize(any: $0) }.joined(separator: ","))"
    }

    private func normalize(any: Any) -> String {
        switch (true) {
        case any is String:
            var encloseDoubleQuote = false
            var existsCR = false
            var result = ""
            let data = any as! String
            data.forEach { c in
                switch (c) {
                case "\"":
                    result.append("\"")
                    encloseDoubleQuote = true
                case ",":
                    encloseDoubleQuote = true
                case "\r":
                    existsCR = true
                case "\n":
                    if existsCR {
                        existsCR = false
                        encloseDoubleQuote = true
                    }
                default:
                    break
                }
                result.append(c)
            }
            if encloseDoubleQuote {
                result.insert("\"", at: result.startIndex)
                result.append("\"")
            }
            return result
        default:
            return any as! String
        }
    }

}
