////
////  ExampleBuilder.swift
////  Parser
////
////  Created by Anton Tkalikov on 02.06.2020.
////  Copyright © 2020 atkalikov. All rights reserved.
////
//
//import Foundation
//import LaoshuModels
//
//final class ExampleBuilder {
//    public var original: String?
//    public var example: String?
//
//    func build() -> Example? {
//        guard let original = original,
//            let example = example else { return nil }
//        return Example(original: original.lowercased(), example: example)
//    }
//
//    func set(original: String) {
//        self.original = original
//    }
//
//    func set(example: String) {
//        self.example = example
//    }
//
//    func erase() {
//        self.original = nil
//        self.example = nil
//    }
//}
