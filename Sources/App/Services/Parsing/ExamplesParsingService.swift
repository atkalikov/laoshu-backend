import Vapor
import Queues
import Foundation
import LaoshuModels

public protocol ExamplesParsingService: AnyObject {
    var isParsing: Bool { get }
    
    func parseExamples(
        on context: QueueContext,
        url: URL
    ) -> EventLoopFuture<Void>
}

final class ExamplesParsingServiceImpl: ExamplesParsingService {
    private let logger: Logger
    
    init(logger: Logger) {
        self.logger = logger
    }
    
    var isParsing: Bool = false
    
    func parseExamples(
        on context: QueueContext,
        url: URL
    ) -> EventLoopFuture<Void> {
        let promise = context.eventLoop.makePromise(of: Void.self)
        var futures: [EventLoopFuture<Void>] = []
        
        isParsing = true
        
        let parser = context.application
            .examplesFileParser()
            .onParsingExamples { [weak self] examples in
                self?.logger.info("did parse \(examples.count) examples")
                let future = examples
                    .map { example in ExampleModel(example: example) }
                    .create(on: context.application.db)
                futures.append(future)
            }
            .onParsingComplete { [weak self] in
                self?.logger.info("Complete parsing examples: \($0)")
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
