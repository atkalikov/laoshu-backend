import Vapor
import Queues
import LaoshuModels

protocol AntonymsParsingService: AnyObject {
    var isParsing: Bool { get }

    func parseAntonyms(
        on context: QueueContext,
        url: URL
    ) -> EventLoopFuture<Void>
}

final class AntonymsParsingServiceImpl: AntonymsParsingService {
    var isParsing: Bool = false

    func parseAntonyms(
        on context: QueueContext,
        url: URL
    ) -> EventLoopFuture<Void> {
        let promise = context.eventLoop.makePromise(of: Void.self)
        
        isParsing = true

        let parser = context.application
            .antonymsFileParser()
            .onParsingAntonyms { _ in }
            .onParsingComplete { [weak self] in
                print("Complete parsing antonyms: \($0)")
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
