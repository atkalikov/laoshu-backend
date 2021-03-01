import Vapor
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif
import LaoshuModels

public protocol AntonymsFileParser: AnyObject {
    @discardableResult
    func onParsingAntonyms(_ action: (([Antonym]) -> Void)?) -> Self

    @discardableResult
    func onParsingComplete(_ action: ((Result<URL, Error>) -> Void)?) -> Self

    func parse(fileAt path: URL)
}

public enum AntonymsFileParserError: Error {
    case cantParseAntonym(String)
}

final class AntonymsFileParserImpl: AntonymsFileParser {
    private let strategy: ParsingAntonymStrategy
    private var antonyms: [Antonym] = []

    private var parsingAntonymsAction: (([Antonym]) -> Void)?
    private var parsingCompleteAction: ((Result<URL, Error>) -> Void)?

    init(strategy: ParsingAntonymStrategy) {
        self.strategy = strategy
    }

    @discardableResult
    func onParsingAntonyms(_ action: (([Antonym]) -> Void)?) -> Self {
        parsingAntonymsAction = action
        return self
    }

    @discardableResult
    func onParsingComplete(_ action: ((Result<URL, Error>) -> Void)?) -> Self {
        parsingCompleteAction = action
        return self
    }

    func parse(fileAt path: URL) {
        var string: String
        do {
            string = try String(contentsOf: path)
        } catch {
            parsingCompleteAction?(.failure(error))
            return
        }

        let scanner = Scanner(string: string)
        scanner.charactersToBeSkipped = nil

        var counter: Int = 0
        while !scanner.isAtEnd {
//            autoreleasepool {
                guard var content = scanner.scanUpToString("\n") else { return }
                content = content.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !content.isEmpty else { return }
                process(string: content, counter: counter)
                counter += 1
                if let index = string.index(scanner.currentIndex, offsetBy: 1, limitedBy: string.endIndex) {
                    scanner.currentIndex = index
                }
                if antonyms.count % 100 == 0 {
                    parsingAntonymsAction?(antonyms)
                    antonyms.removeAll()
                }
//            }
        }

        parsingAntonymsAction?(antonyms)
        antonyms.removeAll()
        parsingCompleteAction?(.success(path))
    }

    private func process(string: String, counter: Int) {
        if let antonym = strategy.parse(from: string) {
            antonyms.append(antonym)
        }
    }
}

extension Application {
    func antonymsFileParser() -> AntonymsFileParser {
        let strategy = ParsingAntonymStrategyImpl()
        return AntonymsFileParserImpl(strategy: strategy)
    }
}
