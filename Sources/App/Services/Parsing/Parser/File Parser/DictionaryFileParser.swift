import Vapor
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif
import LaoshuModels

public protocol DictionaryFileParser: AnyObject {
    @discardableResult
    func onParsingDirectives(_ action: ((DictionaryDirectives) -> Void)?) -> Self
    
    @discardableResult
    func onParsingWords(_ action: (([Word]) -> Void)?) -> Self
    
    @discardableResult
    func onParsingComplete(_ action: ((Result<URL, Error>) -> Void)?) -> Self
    
    func parse(fileAt path: URL)
}

public enum DictionaryFileParserError: Error {
    case cantParseDirectories
    case cantParseWord
}

final class DictionaryFileParserImpl: DictionaryFileParser {
    private let dictionaryDirectivesStrategy: ParsingDictionaryDirectivesStrategy
    private let wordStrategy: ParsingWordStrategy
    private let logger: Logger
    private var words: [Word] = []
    
    private var parsingDirectivesAction: ((DictionaryDirectives) -> Void)?
    private var parsingWordsAction: (([Word]) -> Void)?
    private var parsingCompleteAction: ((Result<URL, Error>) -> Void)?
    
    init(
        dictionaryDirectivesStrategy: ParsingDictionaryDirectivesStrategy,
        wordStrategy: ParsingWordStrategy,
        logger: Logger
    ) {
        self.dictionaryDirectivesStrategy = dictionaryDirectivesStrategy
        self.wordStrategy = wordStrategy
        self.logger = logger
    }
    
    @discardableResult
    func onParsingDirectives(_ action: ((DictionaryDirectives) -> Void)?) -> Self {
        parsingDirectivesAction = action
        return self
    }
    
    @discardableResult
    func onParsingWords(_ action: (([Word]) -> Void)?) -> Self {
        parsingWordsAction = action
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
                guard var content = scanner.scanUpToString("\n\n") else { return }
                content = content.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !content.isEmpty else { return }
                do {
                    try process(string: content, counter: counter)
                } catch {
                    logger.error("Parsing error: \(error.localizedDescription)")
                    parsingCompleteAction?(.failure(error))
                    return
                }
                counter += 1
                if let index = string.index(scanner.currentIndex, offsetBy: 1, limitedBy: string.endIndex) {
                    scanner.currentIndex = index
                }
                
                if words.count % 100 == 0 {
                    parsingWordsAction?(words)
                    words.removeAll()
                }
//            }
        }
        
        parsingWordsAction?(words)
        words.removeAll()
        
        parsingCompleteAction?(.success(path))
    }
    
    private func process(string: String, counter: Int) throws {
        switch counter {
        case 0:
            if let directives = dictionaryDirectivesStrategy.parse(from: string) {
                parsingDirectivesAction?(directives)
            } else {
                logger.error("Can't parse dirictories")
                throw DictionaryFileParserError.cantParseDirectories
            }
        default:
            if let word = wordStrategy.parse(from: string) {
                words.append(word)
            } else {
                logger.error("Can't parse word")
                throw DictionaryFileParserError.cantParseWord
            }
        }
    }
}

extension Application {
    func dictionaryFileParser(
        for type: DictionaryType
    ) -> DictionaryFileParser {
        let dictionaryDirectivesStrategy = ParsingDictionaryDirectivesStrategy(builder: DictionaryDirectivesBuilder())
        var wordStrategy: ParsingWordStrategy
        let converter = TextConverter()

        switch type {
        case .bkrs:
            wordStrategy = ParsingBKRSStrategy(builder: WordBuilder(), converter: converter)
        case .bruks:
            wordStrategy = ParsingBRukSStrategy(builder: WordBuilder(), converter: converter)
        }

        return DictionaryFileParserImpl(
            dictionaryDirectivesStrategy: dictionaryDirectivesStrategy,
            wordStrategy: wordStrategy,
            logger: logger
        )
    }
}
