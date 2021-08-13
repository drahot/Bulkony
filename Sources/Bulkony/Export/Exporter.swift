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
        func getHeader() -> String {
            let headers = rowGenerator.getHeaders()
            if headers.isEmpty {
                return ""
            }
            return toCsv(row: headers) + NEW_LINE
        }

        func getBody() -> String {
            rowGenerator.getRows().map {
                toCsv(row: $0)
            }.joined(separator: NEW_LINE)
        }

        let bom = "\u{FEFF}"
        let data = bom + getHeader() + getBody()
        FileManager.default.createFile(
                atPath: filePath.path,
                contents: data.data(using: .utf8),
                attributes: nil
        )
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
