import Vapor
import Fluent
import LaoshuModels

final class ExampleModel: Model, Content {
    static let schema: String = "exmaple"

    @ID()
    var id: UUID?
    
    @Field(key: "original")
    public var original: String

    @Field(key: "example")
    public var example: String

    init() {
        self.id = UUID()
        self.original = ""
        self.example = ""
    }

    init(example: Example) {
        self.original = example.original
        self.example = example.example
    }
}
