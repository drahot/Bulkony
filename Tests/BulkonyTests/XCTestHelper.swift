//
//  XCTestHelper.swift
//  BulkonyTests
//
//  Created by 堀田竜也 on 2021/09/21.
//

import Foundation

public protocol XCTestHelper {
    
    func getContents(_ path: String) throws -> Data?
    
}

extension XCTestHelper {
    
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
