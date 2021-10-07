//
// Created by 堀田竜也 on 2021/09/10.
//

import Foundation

public struct Error {

    public private(set) var header: String
    public private(set) var message: String

    public init(header: String, message: String) {
        self.header = header
        self.message = message
    }

}
