import Vapor
import Queues
import LaoshuModels

protocol DictionaryParsingService: AnyObject {
    var isParsing: Bool { get }

    func parseDictionary(on context: QueueContext, url: URL, type: DictionaryType) -> EventLoopFuture<Void>
}

final class DictionaryParsingServiceImpl: DictionaryParsingService {
    private let logger: Logger
    var isParsing: Bool = false
    
    init(logger: Logger) {
        self.logger = logger
    }
    
    func parseDictionary(
        on context: QueueContext,
        url: URL,
        type: DictionaryType
    ) -> EventLoopFuture<Void> {
        let promise = context.eventLoop.makePromise(of: Void.self)
        var futures: [EventLoopFuture<Void>] = []
        let db = context.application.db
        
        isParsing = true

        let parser = context.application
            .dictionaryFileParser(for: type)
            .onParsingDirectives { [weak self] in
                self?.logger.info("\(Date()): did parse dictionary dirictives: \($0)")
            }
            .onParsingWords { [weak self] words in
                self?.logger.info("\(Date()): did parse \(words.count) words")
                let future = words
                    .map { WordModel(word: $0) }
                    .create(on: db)
                futures.append(future)
            }
            .onParsingComplete { [weak self] in
                self?.logger.info("\(Date()): complete parsing dictionary: \($0)")
                switch $0 {
                case .success:
                    self?.isParsing = false
                    promise.completeWith(futures.flatten(on: context.eventLoop))
                case .failure(let error):
                    self?.isParsing = false
                    promise.completeWith(.failure(error))
                }
        }

        parser.parse(fileAt: url)
        return promise.futureResult
    }
}
