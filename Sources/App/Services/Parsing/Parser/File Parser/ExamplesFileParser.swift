////
////  ExamplesFileParser.swift
////  Parser
////
////  Created by Anton Tkalikov on 02.06.2020.
////  Copyright © 2020 atkalikov. All rights reserved.
////
//
//import Foundation
//import LaoshuModels
//
//public protocol ExamplesFileParser: AnyObject {
//    @discardableResult
//    func onParsingProgress(_ action: ((Double) -> Void)?) -> Self
//    
//    @discardableResult
//    func onParsingExamples(_ action: (([Example]) -> Void)?) -> Self
//    
//    @discardableResult
//    func onParsingComplete(_ action: ((Result<URL, Error>) -> Void)?) -> Self
//    
//    func parse(fileAt path: URL)
//}
//
//public enum ExamplesFileParserError: Error {
//    case cantParseExample(String)
//    
//    public var localizedDescription: String {
//        switch self {
//        case .cantParseExample(let example):
//            return "Can't parse: \(example)"
//        }
//    }
//}
//
//final class ExamplesFileParserImpl: ExamplesFileParser {
//    private let exampleStrategy: ParsingExampleStrategy
//    private var examples: [Example] = []
//    private var timer: RepeatingTimer?
//    
//    private var parsingProgressAction: ((Double) -> Void)?
//    private var parsingExamplesAction: (([Example]) -> Void)?
//    private var parsingCompleteAction: ((Result<URL, Error>) -> Void)?
//    
//    init(exampleStrategy: ParsingExampleStrategy) {
//        self.exampleStrategy = exampleStrategy
//    }
//    
//    @discardableResult
//    func onParsingProgress(_ action: ((Double) -> Void)?) -> Self {
//        parsingProgressAction = action
//        return self
//    }
//    
//    @discardableResult
//    func onParsingExamples(_ action: (([Example]) -> Void)?) -> Self {
//        parsingExamplesAction = action
//        return self
//    }
//    
//    @discardableResult
//    func onParsingComplete(_ action: ((Result<URL, Error>) -> Void)?) -> Self {
//        parsingCompleteAction = action
//        return self
//    }
//    
//    func parse(fileAt path: URL) {
//        let dateFormatterGet = DateFormatter()
//        dateFormatterGet.dateFormat = "HH:mm:ss"
//        Logger.info(message: "Start parsing examples \(path.lastPathComponent) @ \(dateFormatterGet.string(from: Date()))")
//        
//        var string: String
//        do {
//            string = try String(contentsOf: path)
//        } catch {
//            parsingCompleteAction?(.failure(error))
//            return
//        }
//        
//        let total: UInt64 = UInt64(string.count)
//        var read: UInt64 = .zero
//        timer = RepeatingTimer(timeInterval: 1.0) { [weak self] in
//            self?.parsingProgressAction?(Double(read) / Double(total))
//        }
//        timer?.resume()
//        
//        let scanner = Scanner(string: string)
//        scanner.charactersToBeSkipped = nil
//        
//        var counter: Int = 0
//        while !scanner.isAtEnd {
//            autoreleasepool {
//                guard var content = scanner.scanUpTo(string: "\n\n") else {
//                    scanner.set(currentIndex: scanner.string.index(after: scanner.current))
//                    return
//                }
//                read += UInt64(content.count)
//                content = content.trimmingCharacters(in: .whitespacesAndNewlines)
//                guard !content.isEmpty else {
//                    scanner.set(currentIndex: scanner.string.index(after: scanner.current))
//                    return
//                }
//                do {
//                    try process(string: content, counter: counter)
//                } catch {
//                    parsingCompleteAction?(.failure(error))
//                    timer = nil
//                    return
//                }
//                counter += 1
//                if let index = string.index(scanner.current, offsetBy: 1, limitedBy: string.endIndex) {
//                    scanner.set(currentIndex: index)
//                }
//                
//                if examples.count % 10_000 == 0 {
//                    parsingExamplesAction?(examples)
//                    examples.removeAll()
//                }
//            }
//        }
//        
//        parsingExamplesAction?(examples)
//        examples.removeAll()
//        Logger.info(message: "End parsing examples \(counter) string from \(path.lastPathComponent) @ \(dateFormatterGet.string(from: Date()))")
//        timer = nil
//        parsingCompleteAction?(.success(path))
//    }
//    
//    private func process(string: String, counter: Int) throws {
//        if let example = exampleStrategy.parse(from: string) {
//            examples.append(example)
//        } else {
//            throw ExamplesFileParserError.cantParseExample(string)
//        }
//    }
//}
