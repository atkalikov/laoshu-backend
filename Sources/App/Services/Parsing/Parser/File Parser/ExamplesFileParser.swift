import Vapor
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif
import LaoshuCore

public protocol ExamplesFileParser: AnyObject {
    @discardableResult
    func onParsingExamples(_ action: (([Example]) -> Void)?) -> Self
    
    @discardableResult
    func onParsingComplete(_ action: ((Result<URL, Error>) -> Void)?) -> Self
    
    func parse(fileAt path: URL)
}

public enum ExamplesFileParserError: Error {
    case cantParseExample(String)
    
    public var localizedDescription: String {
        switch self {
        case .cantParseExample(let example):
            return "Can't parse: \(example)"
        }
    }
}

final class ExamplesFileParserImpl: ExamplesFileParser {
    private let exampleStrategy: ParsingExampleStrategy
    private var examples: [Example] = []

    private var parsingExamplesAction: (([Example]) -> Void)?
    private var parsingCompleteAction: ((Result<URL, Error>) -> Void)?
    
    init(exampleStrategy: ParsingExampleStrategy) {
        self.exampleStrategy = exampleStrategy
    }
    
    @discardableResult
    func onParsingExamples(_ action: (([Example]) -> Void)?) -> Self {
        parsingExamplesAction = action
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
            autoreleasepool {
                guard var content = scanner.scanUpToString("\n\n") else {
                    scanner.currentIndex = scanner.string.index(after: scanner.currentIndex)
                    return
                }
                
                content = content.trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard !content.isEmpty else {
                    scanner.currentIndex = scanner.string.index(after: scanner.currentIndex)
                    return
                }
                
                do {
                    try process(string: content, counter: counter)
                } catch {
                    parsingCompleteAction?(.failure(error))
                    return
                }
                counter += 1
                if let index = string.index(scanner.currentIndex, offsetBy: 1, limitedBy: string.endIndex) {
                    scanner.currentIndex = index
                }
                
                if examples.count % 25 == 0, !examples.isEmpty {
                    parsingExamplesAction?(examples)
                    examples.removeAll()
                }
            }
        }
        
        if !examples.isEmpty {
            parsingExamplesAction?(examples)
        }
        examples.removeAll()
        
        parsingCompleteAction?(.success(path))
    }
    
    private func process(string: String, counter: Int) throws {
        if let example = exampleStrategy.parse(from: string) {
            examples.append(example)
        } else {
            examples.append(.init(original: string, example: ""))
        }
    }
}

extension Application {
    var examplesFileParser: ExamplesFileParser {
        let converter = TextConverter()
        let exampleStrategy = ParsingExampleStrategyImpl(builder: ExampleBuilder(), converter: converter)
        return ExamplesFileParserImpl(exampleStrategy: exampleStrategy)
    }
}
