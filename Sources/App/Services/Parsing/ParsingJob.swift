import Vapor
import Foundation
import Queues

struct ParsingJob: Job {
    typealias Payload = ConverterInputModel
    
    private let dictionaryParsingService: DictionaryParsingService
    private let examplesParsingService: ExamplesParsingService
    
    init(dictionaryParsingService: DictionaryParsingService,
         examplesParsingService: ExamplesParsingService) {
        self.dictionaryParsingService = dictionaryParsingService
        self.examplesParsingService = examplesParsingService
    }
    
    func dequeue(_ context: QueueContext, _ payload: ConverterInputModel) -> EventLoopFuture<Void> {
        guard let url = URL(string: payload.url) else {
            return context.eventLoop.future()
        }

        switch payload.entity {
        case .bkrs:
            return dictionaryParsingService.parseDictionary(on: context, url: url, type: .bkrs)
        case .bruks:
            return dictionaryParsingService.parseDictionary(on: context, url: url, type: .bruks)
        case .examples:
            return examplesParsingService.parseExamples(on: context, url: url)
        }
    }
    
    func error(_ context: QueueContext, _ error: Error, _ payload: ConverterInputModel) -> EventLoopFuture<Void> {
        return context.eventLoop.future()
    }
}
