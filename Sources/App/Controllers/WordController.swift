import Vapor
import Fluent
import LaoshuCore

final class WordController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let wordBuilder = routes.grouped("word")
        wordBuilder.get(use: get(req:))
    }
    
    func get(req: Request) throws -> EventLoopFuture<Word> {
        guard let word = try? req.query.get(String.self, at: "word") else { throw Abort(.badRequest) }
        
        return WordModel
            .query(on: req.db)
            .filter(\.$original == word)
            .with(\.$synonyms) { synonyms in synonyms.with(\.$words) }
            .with(\.$antonyms)
            .first()
            .unwrap(or: Abort(.notFound))
            .map { $0.output }
    }
}
