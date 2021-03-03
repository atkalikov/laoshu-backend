import Vapor
import Queues
import Fluent
import LaoshuCore

protocol ExamplesParsingService: AnyObject {
    var isParsing: Bool { get }
    func parseExamples(on context: QueueContext, url: URL, mode: ParsingMode) -> EventLoopFuture<Void>
}

final class ExamplesParsingServiceImpl {
    private let logger: Logger
    var isParsing: Bool = false
    
    init(logger: Logger) {
        self.logger = logger
    }
    
    func writeInitial(examples: [Example], on db: Database) -> EventLoopFuture<Void> {
        examples
            .map { ExampleModel(example: $0) }
            .create(on: db)
    }
    
    // Too slowly but safety
    func writeUpdated(examples: [Example], on db: Database) -> EventLoopFuture<Void> {
        examples
            .map { example in
                ExampleModel
                    .query(on: db)
                    .filter(\.$original, .equal, example.original)
                    .first()
                    .flatMap {
                    if let model = $0 {
                        model.update(example: example)
                        return model.save(on: db)
                    } else {
                        return ExampleModel(example: example).save(on: db)
                    }
                }
            }
            .flatten(on: db.eventLoop)
    }
}

extension ExamplesParsingServiceImpl: ExamplesParsingService {
    func parseExamples(
        on context: QueueContext,
        url: URL,
        mode: ParsingMode
    ) -> EventLoopFuture<Void> {
        let promise = context.eventLoop.makePromise(of: Void.self)
        var futures: [EventLoopFuture<Void>] = []
        var counter: Int = 0
        let db = context.application.db
        
        isParsing = true
        
        let parser = context.application
            .examplesFileParser
            .onParsingExamples { [weak self] examples in
                guard let self = self else { return }
                self.logger.info("\(Date()): did parse \(examples.count) examples")
                counter += examples.count
                let future = mode == .fast ?
                    self.writeInitial(examples: examples, on: db) : self.writeUpdated(examples: examples, on: db)
                futures.append(future)
            }
            .onParsingComplete { [weak self] in
                self?.logger.info("\(Date()): complete parsing examples: \($0)\nTotal: \(counter)")
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
