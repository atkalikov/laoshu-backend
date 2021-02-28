import Vapor
import Queues
import LaoshuModels

protocol SynonymsParsingService: AnyObject {
    var isParsing: Bool { get }
    
    func parseSynonyms(
        on context: QueueContext,
        url: URL
    ) -> EventLoopFuture<Void>
}

final class SynonymsParsingServiceImpl: SynonymsParsingService {
    var isParsing: Bool = false
    
    func parseSynonyms(
        on context: QueueContext,
        url: URL
    ) -> EventLoopFuture<Void> {
        let promise = context.eventLoop.makePromise(of: Void.self)
        
        isParsing = true
            
        let parser = context.application
            .synonymsFileParser()
            .onParsingSynonyms { _ in
//                let models = $0.map { example in ExampleModel(example: example) }
//                _ = context.application.db.transaction { db in
//                    models.create(on: db)
//                }
            }
            .onParsingComplete { [weak self] in
                print("Complete parsing synonyms: \($0)")
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
