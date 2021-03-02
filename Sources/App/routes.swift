import Fluent
import Vapor

func routes(_ app: Application) throws {
    let converterController = ConverterController()
    try app.register(collection: converterController)
    
    let searchingController = SearchController()
    try app.register(collection: searchingController)
    
    app.get { req in
        return req.view.render("index", ["title": "Hello Vapor!"])
    }
    
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
}
