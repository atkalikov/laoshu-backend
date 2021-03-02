import Vapor
import Queues
import Fluent
import LaoshuModels

protocol SynonymsParsingService: AnyObject {
    var isParsing: Bool { get }
    
    func parseSynonyms(on context: QueueContext, url: URL, isItInitialParsing: Bool) -> EventLoopFuture<Void>
}

final class SynonymsParsingServiceImpl {
    private let logger: Logger
    var isParsing: Bool = false
    
    init(logger: Logger) {
        self.logger = logger
    }
    
    func writeInitial(synonyms: [Synonym], on db: Database) -> EventLoopFuture<Void> {
        synonyms.map { synonym in
            WordModel
                .query(on: db)
                .filter(\.$original ~~ synonym.content)
                .all()
                .flatMap { (words) -> EventLoopFuture<Void> in
                    if words.isEmpty {
                        return db.eventLoop.future()
                    } else {
                        let synonymModel = SynonymModel()
                        return synonymModel
                            .save(on: db)
                            .flatMap {
                                words
                                    .map { WordSynonyms(wordId: $0.id!, synonymId: synonymModel.id!) }
                                    .create(on: db)
                            }
                    }
                }
        }.flatten(on: db.eventLoop)
    }
}

extension SynonymsParsingServiceImpl: SynonymsParsingService {
    func parseSynonyms(
        on context: QueueContext,
        url: URL,
        isItInitialParsing: Bool
    ) -> EventLoopFuture<Void> {
        let promise = context.eventLoop.makePromise(of: Void.self)
        var futures: [EventLoopFuture<Void>] = []
        let db = context.application.db
        
        isParsing = true
            
        let parser = context.application
            .synonymsFileParser()
            .onParsingSynonyms { [weak self] synonyms in
                guard let self = self else { return }
                self.logger.info("\(Date()): did parse \(synonyms.count) synonyms")
                let future = self.writeInitial(synonyms: synonyms, on: db)
                futures.append(future)
            }
            .onParsingComplete { [weak self] in
                self?.logger.info("\(Date()): complete parsing synonyms: \($0)")
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
        promise.succeed(Void())
        return promise.futureResult
    }
}
