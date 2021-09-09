//
// Created by 堀田竜也 on 2021/09/05.
//

import Foundation

public protocol RowHandler {

    func handle(row: [String: String], lineNumber: UInt32, context: inout Context)
    func handle(row: [String], lineNumber: UInt32, context: inout Context)

}
