//
// Created by 堀田竜也 on 2021/08/12.
//

@testable import Bulkony
import Foundation
import Yams
import XCTest

final class ExporterTests: XCTestCase {
    func testsCsvExporter() throws {
        let exporter = CsvExporter("/tmp/test.csv", ArrayRowGenerator(headers: getHeaders(), rows: getRows()))
        try exporter.export()
        let data = try getContents("/tmp/test.csv")
        XCTAssertNotEqual(nil, data)
        let result = "\u{FEFF}id,name,birthday\r\n1,\"\"\"Tatsuya Hotta\",1974/03/15\r\n2,\"Riho, Yoshioka\",1993/01/15\r\n3,\"Kana\r\nKurashina\",1987/12/23\r\n4,Kanna Hashimoto,1999/02/03"
        XCTAssertEqual(result, String(data: data!, encoding: .utf8)!)
        try FileManager.default.removeItem(atPath: "/tmp/test.csv")
    }
    
    func testsTsvExporter() throws {
        let exporter = TsvExporter("/tmp/test.tsv", ArrayRowGenerator(headers: getHeaders(), rows: getRows()))
        try exporter.export()
        let data = try getContents("/tmp/test.tsv")
        XCTAssertNotEqual(nil, data)
        let result = "id\tname\tbirthday\n1\t\"\"\"Tatsuya Hotta\"\t1974/03/15\n2\tRiho, Yoshioka\t1993/01/15\n3\t\"Kana\r\nKurashina\"\t1987/12/23\n4\tKanna Hashimoto\t1999/02/03"
        XCTAssertEqual(result, String(data: data!, encoding: .utf8)!)
        try FileManager.default.removeItem(atPath: "/tmp/test.tsv")
    }

    func testsXmlExporter() throws {
        let exporter = XmlExporter("/tmp/test.xml", ArrayRowGenerator(headers: getHeaders(), rows: getRows()))
        try exporter.export()
        let data = try getContents("/tmp/test.xml")
        XCTAssertNotEqual(nil, data)
        let result = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><root><row id=\"1\" name=\"&quot;Tatsuya Hotta\" birthday=\"1974/03/15\"></row><row id=\"2\" name=\"Riho, Yoshioka\" birthday=\"1993/01/15\"></row><row id=\"3\" name=\"Kana\r\nKurashina\" birthday=\"1987/12/23\"></row><row id=\"4\" name=\"Kanna Hashimoto\" birthday=\"1999/02/03\"></row></root>"
        XCTAssertEqual(result, String(data: data!, encoding: .utf8)!)
        try FileManager.default.removeItem(atPath: "/tmp/test.xml")
    }
    
    func testsJsonExporter() throws {
        let exporter = JsonExporter("/tmp/test.json", ArrayRowGenerator(headers: getHeaders(), rows: getRows()))
        try exporter.export()
        let data = try getContents("/tmp/test.json")
        let json = try JSONSerialization.jsonObject(with: data!)
        let rows = json as! [[String: Any]]
        XCTAssertEqual(4, rows.count)

        let first = rows.first!
        XCTAssertEqual(1, first["id"] as! Int)
        XCTAssertEqual("\"Tatsuya Hotta", first["name"] as! String)
        XCTAssertEqual("1974/03/15", first["birthday"] as! String)

        let last = rows.last!
        XCTAssertEqual(4, last["id"] as! Int)
        XCTAssertEqual("Kanna Hashimoto", last["name"] as! String)
        XCTAssertEqual("1999/02/03", last["birthday"] as! String)
        try FileManager.default.removeItem(atPath: "/tmp/test.json")
    }

    private func getHeaders() -> [String] {
        ["id", "name", "birthday"]
    }

    private func getRows() -> AnySequence<[Any]> {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy/MM/dd", options: 0, locale: Locale(identifier: "ja_JP"))
        let data = [
            [1, "\"Tatsuya Hotta", formatter.string(from: formatter.date(from: "1974/03/15")!)],
            [2, "Riho, Yoshioka", formatter.string(from: formatter.date(from: "1993/01/15")!)],
            [3, "Kana\r\nKurashina", formatter.string(from: formatter.date(from: "1987/12/23")!)],
            [4, "Kanna Hashimoto", formatter.string(from: formatter.date(from: "1999/02/03")!)]
        ]
        return AnySequence(data)
    }

    private func getContents(_ path: String) throws -> Data? {
        let fileHandle = FileHandle(forReadingAtPath: path)
        defer {
            do {
                try fileHandle?.close()
            } catch {
            }
        }
        return fileHandle?.readDataToEndOfFile()
    }
}

