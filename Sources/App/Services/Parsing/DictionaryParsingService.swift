import Vapor
import Queues
import Fluent
import LaoshuModels

protocol DictionaryParsingService: AnyObject {
    var isParsing: Bool { get }

    func parseDictionary(
        on context: QueueContext,
        url: URL,
        type: DictionaryType,
        isItInitialParsing: Bool
    ) -> EventLoopFuture<Void>
}

final class DictionaryParsingServiceImpl {
    private let logger: Logger
    var isParsing: Bool = false
    
    init(logger: Logger) {
        self.logger = logger
    }
    
    func writeInitial(words: [Word], on db: Database) -> EventLoopFuture<Void> {
        words
            .map { WordModel(word: $0) }
            .create(on: db)
    }
    
    // Too slowly but safety
    func writeUpdated(words: [Word], on db: Database) -> EventLoopFuture<Void> {
        words
            .map { word in
                WordModel
                    .query(on: db)
                    .filter(\.$original, .equal, word.original)
                    .first()
                    .flatMap {
                    if let model = $0 {
                        model.update(with: word)
                        return model.save(on: db)
                    } else {
                        return WordModel(word: word).save(on: db)
                    }
                }
            }
            .flatten(on: db.eventLoop)
    }
}

extension DictionaryParsingServiceImpl: DictionaryParsingService {
    func parseDictionary(
        on context: QueueContext,
        url: URL,
        type: DictionaryType,
        isItInitialParsing: Bool
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
                guard let self = self else { return }
                self.logger.info("\(Date()): did parse \(words.count) words")
                let future = isItInitialParsing ? self.writeInitial(words: words, on: db) : self.writeUpdated(words: words, on: db)
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
