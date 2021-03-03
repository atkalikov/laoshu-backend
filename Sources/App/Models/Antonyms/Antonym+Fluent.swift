import Vapor
import Fluent
import LaoshuCore

//extension FieldKey {
//    struct Antonym {
//        static var content: FieldKey { .string("content") }
//        static var opposite: FieldKey { .string("opposite") }
//    }
//}
//
//final class AntonymModel: Model, Content {
//    static let schema: String = "antonym"
//
//    @ID(custom: FieldKey.Antonym.content, generatedBy: .user)
//    var id: String?
//
//    var content: String {
//        get {
//            return id ?? ""
//        }
//        set {
//            id = newValue
//        }
//    }
//
//    @Field(key: FieldKey.Example.example)
//    public var example: String
////
////    init() {
////        self.original = ""
////        self.example = ""
////    }
////
////    init(example: Example) {
////        self.original = example.original
////        self.example = example.example
////    }
//}
