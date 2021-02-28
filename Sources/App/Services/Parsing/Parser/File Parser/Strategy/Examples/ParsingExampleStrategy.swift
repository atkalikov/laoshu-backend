////
////  ParsingExampleStrategy.swift
////  Parser
////
////  Created by Anton Tkalikov on 02.06.2020.
////  Copyright © 2020 atkalikov. All rights reserved.
////
//
//import Foundation
//import LaoshuModels
//
//public protocol ParsingExampleStrategy {
//    func parse(from string: String) -> Example?
//}
//
//struct ParsingExampleStrategyImpl: ParsingExampleStrategy {
//    private let builder: ExampleBuilder
//
//    init(builder: ExampleBuilder) {
//        self.builder = builder
//    }
//
//    @discardableResult
//    func parse(from string: String) -> Example? {
//        builder.erase()
//
//        string
//            .split(whereSeparator: \.isNewline)
//            .filter { !$0.hasPrefix("#") }
//            .enumerated()
//            .compactMap { process(string: String($0.element), at: $0.offset) }
//            .forEach {
//                switch $0.field {
//                case .original:
//                    builder.set(original: $0.value)
//                case .example:
//                    builder.set(example: $0.value)
//                }
//        }
//
//        return builder.build()
//    }
//}
//
//
//extension ParsingExampleStrategyImpl {
//    private enum Fields: CaseIterable {
//        case original
//        case example
//    }
//
//    private func process(string: String, at line: Int) -> (field: Fields, value: String)? {
//        switch line {
//        case 0:
//            guard !string.hasPrefix(" ") else { return nil }
//            return (field: .original, value: string)
//        case 1:
//            guard string.hasPrefix(" ") else { return nil }
//            return (field: .example, value: string.trimmingCharacters(in: .whitespacesAndNewlines))
//        default:
//            return nil
//        }
//    }
//}
