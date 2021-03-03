import Vapor
import LaoshuCore

struct ConverterInputModel: Content {
    let url: String
    let entity: Entity
    let mode: ParsingMode
    
    enum Entity: String, Content {
        case bkrs
        case bruks
        case examples
        case antonyms
        case synonyms
    }
}

final class ConverterController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let converterBuilder = routes.grouped("converter")
        converterBuilder.put(use: convert(req:))
    }

    func convert(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let body = try req.content.decode(ConverterInputModel.self)

        return req
            .queue
            .dispatch(ParsingJob.self, body)
            .map { HTTPStatus.ok }
    }
}
