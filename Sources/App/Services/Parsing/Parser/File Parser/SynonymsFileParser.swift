import Vapor
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif
import LaoshuModels

public protocol SynonymsFileParser: AnyObject {
    @discardableResult
    func onParsingSynonyms(_ action: (([Synonym]) -> Void)?) -> Self

    @discardableResult
    func onParsingComplete(_ action: ((Result<URL, Error>) -> Void)?) -> Self

    func parse(fileAt path: URL)
}

public enum SynonymsFileParserError: Error {
    case cantParseSynonyms(String)
}

final class SynonymsFileParserImpl: SynonymsFileParser {
    private let strategy: ParsingSynonymStrategy
    private var synonyms: [Synonym] = []
    
    private var parsingSynonymsAction: (([Synonym]) -> Void)?
    private var parsingCompleteAction: ((Result<URL, Error>) -> Void)?

    init(strategy: ParsingSynonymStrategy) {
        self.strategy = strategy
    }

    @discardableResult
    func onParsingSynonyms(_ action: (([Synonym]) -> Void)?) -> Self {
        parsingSynonymsAction = action
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
            guard var content = scanner.scanUpToString("\n") else { return }
            content = content.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !content.isEmpty else { return }
            process(string: content, counter: counter)
            counter += 1
            if let index = string.index(scanner.currentIndex, offsetBy: 1, limitedBy: string.endIndex) {
                scanner.currentIndex = index
            }
            if synonyms.count % 100 == 0 {
                parsingSynonymsAction?(synonyms)
                synonyms.removeAll()
            }
        }

        parsingSynonymsAction?(synonyms)
        synonyms.removeAll()
        parsingCompleteAction?(.success(path))
    }

    private func process(string: String, counter: Int) {
        if let synonym = strategy.parse(from: string) {
            synonyms.append(synonym)
        }
    }
}

extension Application {
    func synonymsFileParser() -> SynonymsFileParser {
        let converter = TextConverter()
        let strategy = ParsingSynonymStrategyImpl(converter: converter)
        return SynonymsFileParserImpl(strategy: strategy)
    }
}
