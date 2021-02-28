import Vapor
import Fluent
import LaoshuModels

final class SearchController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let converterBuilder = routes.grouped("search")
        converterBuilder.get(":word", use: search(req:))
    }

    func search(req: Request) throws -> EventLoopFuture<WordModel> {
        guard let word = req.parameters.get("word") else {
            throw Abort(.badRequest)
        }
        
        return WordModel
            .query(on: req.db)
            .filter(\.$original == word)
            .first()
            .unwrap(or: Abort(.notFound))
    }
}