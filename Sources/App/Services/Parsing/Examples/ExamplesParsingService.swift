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
    var isParsing: Bool = false
    
    func parseExamples(
        on context: QueueContext,
        url: URL
    ) -> EventLoopFuture<Void> {
        let promise = context.eventLoop.makePromise(of: Void.self)
        
        isParsing = true
        
        let parser = context.application
            .examplesFileParser()
            .onParsingExamples {
                let models = $0.map { example in ExampleModel(example: example) }
                _ = context.application.db.transaction { db in
                    models.create(on: db)
                }
            }
            .onParsingComplete { [weak self] in
                switch $0 {
                case .success:
                    self?.isParsing = false
                    promise.completeWith(.success(Void()))
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
