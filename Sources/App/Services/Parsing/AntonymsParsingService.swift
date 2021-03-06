import Vapor
import Queues
import Fluent
import LaoshuCore

protocol AntonymsParsingService: AnyObject {
    var isParsing: Bool { get }

    func parseAntonyms(
        on context: QueueContext,
        url: URL
    ) -> EventLoopFuture<Void>
}

final class AntonymsParsingServiceImpl {
    private let logger: Logger
    private var unpersistedAntonyms: [Antonym] = []
    var isParsing: Bool = false
    
    init(logger: Logger) {
        self.logger = logger
    }
    
    func writeInitial(antonyms: [Antonym], on db: Database) -> EventLoopFuture<Void> {
        antonyms.map { antonym in
            WordModel
                .query(on: db)
                .filter(\.$original == antonym.content)
                .first()
                .unwrap(or: Abort(.notFound))
                .flatMap { (originalWord) -> EventLoopFuture<Void> in
                    WordModel
                        .query(on: db)
                        .filter(\.$original == antonym.opposite)
                        .first()
                        .unwrap(or: Abort(.notFound))
                        .flatMap { oppositeWord in
                            [
                                originalWord.$antonyms.attach(oppositeWord, method: .ifNotExists, on: db),
                                oppositeWord.$antonyms.attach(originalWord, method: .ifNotExists, on: db)
                            ].flatten(on: db.eventLoop)
                        }
                }.flatMapError { [weak self] error in
                    self?.unpersistedAntonyms.append(antonym)
                    self?.logger.error(.init(stringLiteral: error.localizedDescription))
                    return db.eventLoop.future()
                }
        }.flatten(on: db.eventLoop)
    }
}

extension AntonymsParsingServiceImpl: AntonymsParsingService {
    func parseAntonyms(
        on context: QueueContext,
        url: URL
    ) -> EventLoopFuture<Void> {
        let promise = context.eventLoop.makePromise(of: Void.self)
        var futures: [EventLoopFuture<Void>] = []
        var counter: Int = 0
        let db = context.application.db
        
        isParsing = true

        let parser = context.application
            .antonymsFileParser()
            .onParsingAntonyms { [weak self] antonyms in
                guard let self = self else { return }
                self.logger.info("\(Date()): did parse \(antonyms.count) antonyms")
                counter += antonyms.count
                let future = self.writeInitial(antonyms: antonyms, on: db)
                futures.append(future)
            }
            .onParsingComplete { [weak self] in
                self?.logger.info("\(Date()): complete parsing antonyms: \($0)")
                self?.logger.info("\(Date()): total: \(counter)")
                let unpersistedAntonymsString = self?.unpersistedAntonyms.map { "\($0)\n" }.reduce("", +)
                self?.logger.info("\(Date()): unpersisted:\n\(unpersistedAntonymsString ?? "")")
                
                switch $0 {
                case .success:
                    self?.isParsing = false
                    promise.completeWith(futures.flatten(on: context.eventLoop))
                case .failure(let error):
                    self?.isParsing = false
                    promise.completeWith(.failure(error))
                }
                self?.unpersistedAntonyms.removeAll()
        }

        parser.parse(fileAt: url)
        promise.succeed(Void())
        return promise.futureResult
    }
}
