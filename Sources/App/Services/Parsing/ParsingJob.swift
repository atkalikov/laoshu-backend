import Vapor
import Foundation
import Queues

struct ParsingJob: Job {
    typealias Payload = ConverterInputModel
    
    private let service: DictionaryParsingService
    
    init(service: DictionaryParsingService) {
        self.service = service
    }
    
    func dequeue(_ context: QueueContext, _ payload: ConverterInputModel) -> EventLoopFuture<Void> {
        guard let url = URL(string: payload.url) else {
            return context.eventLoop.future()
        }

        switch payload.entity {
        case .bkrs:
            return service.parseDictionary(on: context, url: url, type: .bkrs)
        case .bruks:
            return service.parseDictionary(on: context, url: url, type: .bruks)
        }
    }
    
    func error(_ context: QueueContext, _ error: Error, _ payload: ConverterInputModel) -> EventLoopFuture<Void> {
        return context.eventLoop.future()
    }
}
