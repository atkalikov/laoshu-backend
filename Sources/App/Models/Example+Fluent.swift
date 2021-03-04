import Vapor
import Fluent
import LaoshuCore

extension FieldKey {
    struct Example {
        static var original: FieldKey { .string("original") }
        static var example: FieldKey { .string("example") }
    }
}

final class ExampleModel: Model, Content {
    static let schema: String = "exmaple"

    @ID(custom: .id, generatedBy: .random)
    var id: String?
    
    @Field(key: FieldKey.Example.original)
    var original: String

    @Field(key: FieldKey.Example.example)
    public var example: String

    init() {
        self.original = ""
        self.example = ""
    }

    init(example: Example) {
        self.original = example.original
        self.example = example.example
    }
    
    func update(example: Example) {
        self.original = example.original
        self.example = example.example
    }
}

extension Example: Content { }

extension ExampleModel {
    var output: Example {
        .init(original: original, example: example)
    }
}
