import Fluent
import Vapor

func routes(_ app: Application) throws {
    let converterController = ConverterController()
    let searchingController = SearchController()
    let wordController = WordController()
    let exampleController = ExampleController()
    
    try app.register(collection: converterController)
    try app.register(collection: searchingController)
    try app.register(collection: wordController)
    try app.register(collection: exampleController)
}
