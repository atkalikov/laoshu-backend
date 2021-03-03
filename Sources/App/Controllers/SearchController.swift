import Vapor
import Fluent
import LaoshuCore

final class SearchController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let converterBuilder = routes.grouped("search")
        converterBuilder.get(":word", use: search(req:))
    }

    func search(req: Request) throws -> EventLoopFuture<Word> {
        guard let word = req.parameters.get("word") else {
            throw Abort(.badRequest)
        }
        
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
