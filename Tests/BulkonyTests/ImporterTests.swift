//
// Created by 堀田竜也 on 2021/09/13.
//

@testable import Bulkony
import Foundation
import XCTest

final class ImporterTests: XCTestCase {

    func testsCsvImporter() throws {
        let tempDir = NSTemporaryDirectory()
        let filename = NSUUID().uuidString + ".csv"
        let url: URL = .init(fileURLWithPath: tempDir).appendingPathComponent(filename)
        print("\(url)")
        let content = """
            id,name,email
            1,alice,alice@example.com
            2,bob,bob@example.com
            3,charlie,charlie@example.com
        """
        FileManager.default.createFile(atPath: url.path, contents: content.data(using: .utf8))
        
        let rowVisitor = TextDictionaryRowVisitor()
        let importer = DictionaryCsvImporter(url, rowVisitor)
        try importer.importData()
        let csvString = rowVisitor.data
        let expected = """
            1,alice,alice@example.com
            2,bob,bob@example.com
            3,charlie,charlie@example.com
        """
        XCTAssertEqual(expected, csvString)
        
        try FileManager.default.removeItem(atPath: url.path)
    }
    

}

fileprivate class TextDictionaryRowVisitor: DictionaryRowVisitor {
    
    public private(set) var data: String = ""
    
    public  func visit(row: Row, lineNumber: UInt32, context: inout Context) {
        data += row.values.joined(separator: ",") + "\n"
    }
    
    
}
