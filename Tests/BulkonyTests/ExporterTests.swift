//
// Created by 堀田竜也 on 2021/08/12.
//

@testable import Bulkony
import Foundation
import XCTest

final class ExporterTests: XCTestCase {
    func testsExporter() throws {
        let exporter = CsvExporter("/tmp/test.csv", ArrayRowGenerator())
        try exporter.export()
        let fileHandle = FileHandle(forReadingAtPath: "/tmp/test.csv")
        let data = fileHandle?.readDataToEndOfFile()
        XCTAssertNotEqual(nil, data)
        let result = "\u{FEFF}id,name,birthday\r\n1,\"\"\"Tatsuya Hotta\",1974/03/15\r\n2,\"Riho, Yoshioka\",1993/01/15\r\n3,\"Kana\r\nKurashina\",1987/12/23"
        print(String(data: data!, encoding: .utf8)!)
        XCTAssertEqual(result, String(data: data!, encoding: .utf8)!)
    }
}

internal struct ArrayRowGenerator: RowGenerator {
    func getRows() -> AnySequence<[Any]> {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy/MM/dd", options: 0, locale: Locale(identifier: "ja_JP"))
        let data = [
            [1, "\"Tatsuya Hotta", formatter.string(from: formatter.date(from: "1974/03/15")!)],
            [2, "Riho, Yoshioka", formatter.string(from: formatter.date(from: "1993/01/15")!)],
            [3, "Kana\r\nKurashina", formatter.string(from: formatter.date(from: "1987/12/23")!)],
        ]
        return AnySequence(data)
    }

    func getHeaders() -> [String] {
        ["id", "name", "birthday"]
    }
}
