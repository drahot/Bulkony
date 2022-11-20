//
// Created by 堀田竜也 on 2022/11/20.
//

import Foundation

public struct ImportError: Error {

    public let errors: [[RowError]]

    public init(errors: [[RowError]]) {
        self.errors = errors
    }

}
