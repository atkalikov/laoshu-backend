////
////  AntonymsFileParser.swift
////  Parser
////
////  Created by Anton Tkalikov on 03.06.2020.
////  Copyright © 2020 atkalikov. All rights reserved.
////
//
//import Foundation
//import LaoshuModels
//
//public protocol AntonymsFileParser: AnyObject {
//    @discardableResult
//    func onParsingProgress(_ action: ((Double) -> Void)?) -> Self
//
//    @discardableResult
//    func onParsingAntonyms(_ action: (([Antonym]) -> Void)?) -> Self
//
//    @discardableResult
//    func onParsingComplete(_ action: ((Result<URL, Error>) -> Void)?) -> Self
//
//    func parse(fileAt path: URL)
//}
//
//public enum AntonymsFileParserError: Error {
//    case cantParseAntonym(String)
//}
//
//final class AntonymsFileParserImpl: AntonymsFileParser {
//    private let antonymStrategy: ParsingAntonymStrategy
//    private var antonyms: [Antonym] = []
//    private var timer: RepeatingTimer?
//
//    private var parsingProgressAction: ((Double) -> Void)?
//    private var parsingAntonymsAction: (([Antonym]) -> Void)?
//    private var parsingCompleteAction: ((Result<URL, Error>) -> Void)?
//
//    init(antonymStrategy: ParsingAntonymStrategy) {
//        self.antonymStrategy = antonymStrategy
//    }
//
//    @discardableResult
//    func onParsingProgress(_ action: ((Double) -> Void)?) -> Self {
//        parsingProgressAction = action
//        return self
//    }
//
//    @discardableResult
//    func onParsingAntonyms(_ action: (([Antonym]) -> Void)?) -> Self {
//        parsingAntonymsAction = action
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
//        print("STARTED PARSING ANTONYMS \(path.lastPathComponent) @ \(dateFormatterGet.string(from: Date()))")
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
//                guard var content = scanner.scanUpTo(string: "\n") else { return }
//                read += UInt64(content.count)
//                content = content.trimmingCharacters(in: .whitespacesAndNewlines)
//                guard !content.isEmpty else { return }
//                process(string: content, counter: counter)
//                counter += 1
//                if let index = string.index(scanner.current, offsetBy: 1, limitedBy: string.endIndex) {
//                    scanner.set(currentIndex: index)
//                }
//                if antonyms.count % 10_000 == 0 {
//                    parsingAntonymsAction?(antonyms)
//                    antonyms.removeAll()
//                }
//            }
//        }
//
//        parsingAntonymsAction?(antonyms)
//        antonyms.removeAll()
//        print("ENDED PARSING ANTONYMS \(counter) string from \(path.lastPathComponent) @ \(dateFormatterGet.string(from: Date()))")
//        timer = nil
//        parsingCompleteAction?(.success(path))
//    }
//
//    private func process(string: String, counter: Int) {
//        if let antonym = antonymStrategy.parse(from: string) {
//            antonyms.append(antonym)
//        }
//    }
//}
