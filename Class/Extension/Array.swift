//
//  Array.swift
//  MyData
//
//  Created by UMCios on 2022/02/10.
//

import Foundation
import Combine

extension Array where Element: Publisher {
    func combineAll() -> AnyPublisher<[Element.Output], Element.Failure>? {
        guard let first = first else { return nil }
        return dropFirst()
        .reduce(into: AnyPublisher(first.map { [$0] })) {
            $0 = $0.combineLatest($1) { $0 + [$1] }
            .eraseToAnyPublisher()
        }
    }
}
