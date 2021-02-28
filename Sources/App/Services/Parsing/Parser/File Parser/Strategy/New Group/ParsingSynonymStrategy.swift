////
////  ParsingSynonymStrategy.swift
////  Parser
////
////  Created by Anton Tkalikov on 03.06.2020.
////  Copyright © 2020 atkalikov. All rights reserved.
////
//
//import Foundation
//import LaoshuModels
//
//public protocol ParsingSynonymStrategy {
//    func parse(from string: String) -> Synonym?
//}
//
//struct ParsingSynonymStrategyImpl: ParsingSynonymStrategy {
//    @discardableResult
//    func parse(from string: String) -> Synonym? {
//        let array = string
//            .split(whereSeparator: \.isWhitespace)
//            .enumerated()
//            .filter { $0.offset > 0 }
//            .map { String($0.element) }
//        
//        if array.count > 1 {
//            return Synonym(content: array)
//        } else {
//            return nil
//        }
//    }
//}
