//
// Created by 堀田竜也 on 2021/08/08.
//

import Foundation

public protocol RowGenerator  {
    func getHeaders() -> [String]
    func getRows() -> AnySequence<[Any]>
}

