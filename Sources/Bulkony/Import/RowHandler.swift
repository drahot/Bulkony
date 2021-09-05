//
// Created by 堀田竜也 on 2021/09/05.
//

import Foundation

public protocol RowHandler {

    func handle(_ row: [String: Any], lineNumber: UInt32)

}
