import Fluent
import Vapor

func routes(_ app: Application) throws {
    let converterController = ConverterController()
    try app.register(collection: converterController)
    
    let searchingController = SearchController()
    try app.register(collection: searchingController)
}
