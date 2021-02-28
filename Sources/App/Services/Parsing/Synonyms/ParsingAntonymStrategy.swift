////
////  ParsingAntonymStrategy.swift
////  Parser
////
////  Created by Anton Tkalikov on 03.06.2020.
////  Copyright © 2020 atkalikov. All rights reserved.
////
//
//import Foundation
//import LaoshuModels
//
//public protocol ParsingAntonymStrategy {
//    func parse(from string: String) -> Antonym?
//}
//
//struct ParsingAntonymStrategyImpl: ParsingAntonymStrategy {
//    @discardableResult
//    func parse(from string: String) -> Antonym? {
//        let array = string
//            .split(whereSeparator: \.isWhitespace)
//            .map { String($0) }
//
//        if array.count == 2 {
//            return Antonym(content: array[0], opposite: array[1])
//        } else {
//            return nil
//        }
//    }
//}
