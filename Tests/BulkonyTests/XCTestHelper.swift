//
//  XCTestHelper.swift
//  BulkonyTests
//
//  Created by 堀田竜也 on 2021/09/21.
//

import Foundation

public protocol XCTestsHelper {
    
    func getContents(_ path: String) throws -> Data?
    
}

extension XCTestsHelper {
    
    public func getContents(_ path: String) throws -> Data? {
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
