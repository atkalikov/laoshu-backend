import Vapor
import Queues
import LaoshuModels

protocol DictionaryParsingService: AnyObject {
    var isParsing: Bool { get }

    func parseDictionary(
        on context: QueueContext,
        url: URL,
        type: DictionaryType
    ) -> EventLoopFuture<Void>
}

final class DictionaryParsingServiceImpl: DictionaryParsingService {
    private let logger: Logger
    
    init(logger: Logger) {
        self.logger = logger
    }
    
    var isParsing: Bool = false
    
    func parseDictionary(
        on context: QueueContext,
        url: URL,
        type: DictionaryType
    ) -> EventLoopFuture<Void> {
        let promise = context.eventLoop.makePromise(of: Void.self)
        var futures: [EventLoopFuture<Void>] = []
        
        isParsing = true

        let parser = context.application
            .dictionaryFileParser(for: type)
            .onParsingDirectives { [weak self] in
                self?.logger.info("Did parse dictionary dirictives: \($0)")
            }
            .onParsingWords { words in
                let future = words
                    .map { word in WordModel(word: word) }
                    .create(on: context.application.db)
                futures.append(future)
            }
            .onParsingComplete { [weak self] in
                self?.logger.info("Complete parsing dictionary: \($0)")
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
