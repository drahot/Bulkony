//
// Created by 堀田竜也 on 2021/08/08.
//

import Foundation

public protocol Exporter {
    var filePath: URL { get }
    var rowGenerator: RowGenerator { get }
    func export() throws
}

@available(macCatalyst 13.0, *)
public struct CsvExporter: Exporter {

    private let NEW_LINE = "\r\n"
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

@available(macCatalyst 13.0, *)
extension CsvExporter {

    public func export() throws {
        let fileHandle = try FileHandle(forWritingTo: filePath)
        defer {
            if #available(macOS 10.15, *) {
                do {
                    try fileHandle.close()
                } catch {
                }
            }
        }

        func write(_ str: String) {
            if let data = str.data(using: .utf8) {
                fileHandle.write(data)
            }
        }

        let headers = rowGenerator.getHeaders()
        if !headers.isEmpty {
            let header = toCsv(row: headers) + NEW_LINE
            write(header)
        }

        let body = rowGenerator.getRows().map {
            toCsv(row: $0)
        }.joined(separator: NEW_LINE)

        if !body.isEmpty {
            write(body)
        }
    }

    private func toCsv(row: [Any]) -> String {
        row.map {
            normalize(any: $0)
        }.joined(separator: ",")
    }

    private func normalize(any: Any) -> String {
        if any is String {
            var enclosedInDoubleQuote = false
            var result = ""
            (any as! String).forEach { c in
                switch c {
                case "\"":
                    result.append("\"")
                    enclosedInDoubleQuote = true
                case ",", "\r", "\n":
                    enclosedInDoubleQuote = true
                default:
                    break
                }
                result.append(c)
            }
            if enclosedInDoubleQuote {
                result.insert("\"", at: result.startIndex)
                result.append("\"")
            }
            return result
        } else {
            return any as! String
        }
    }

}
