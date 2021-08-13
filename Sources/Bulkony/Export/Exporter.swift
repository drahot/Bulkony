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
        FileManager.default.createFile(atPath: filePath.path, contents: nil, attributes: nil)
        let fileHandle = try FileHandle(forWritingTo: filePath)
        defer {
            if #available(macOS 10.15, *) {
                do {
                    try fileHandle.close()
                } catch {
                }
            }
        }

        func write(_ str: String, using encoding: String.Encoding = .utf8) {
            if let data = str.data(using: encoding) {
                fileHandle.write(data)
            }
        }

        write("\u{FEFF}")
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
            let tuples = (any as! String).map { c -> (String, Bool) in
                switch c {
                case "\"":
                    return (String(c) + "\"", true)
                case ",", "\r\n", "\n":
                    return (String(c), true)
                default:
                    return (String(c), false)
                }
            }

            let (result, enclosedInDoubleQuote) = tuples.reduce(("", false)) { prev, current -> (String, Bool) in
                (prev.0 + current.0, prev.1 || current.1)
            }

            if enclosedInDoubleQuote {
                return "\"\(result)\""
            }
            return result
        } else {
            return String(describing: any)
        }
    }

}
