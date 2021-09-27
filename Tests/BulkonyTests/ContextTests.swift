//
//  ContextTests.swift
//  BulkonyTests
//
//  Created by 堀田竜也 on 2021/09/27.
//

import Foundation
import XCTest

@testable import Bulkony

final class ContextTests: XCTestCase {

    public func testsContext() {
        var context = Context()
        context.append("AAAA")
        context.append(1000)
        context.append(["Test": 1000])
        XCTAssertEqual("AAAA", context.first as! String)
        XCTAssertEqual(1000, context[1] as! Int)
        let dict = context[2] as! [String: Int]
        XCTAssertEqual(1000, (dict["Test"] ?? 0) as Int)
        for value in context {
            print("\(value)")
        }
    }
}
