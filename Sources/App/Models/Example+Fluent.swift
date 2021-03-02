import Vapor
import Fluent
import LaoshuModels

extension FieldKey {
    struct Example {
        static var original: FieldKey { .string("original") }
        static var example: FieldKey { .string("example") }
    }
}

final class ExampleModel: Model, Content {
    static let schema: String = "exmaple"

    @ID(custom: FieldKey.Example.original, generatedBy: .user)
    var id: String?
    
    var original: String {
        get {
            return id ?? ""
        }
        set {
            id = newValue
        }
    }

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
}
