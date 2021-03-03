import Vapor
import Fluent
import LaoshuCore

extension FieldKey {
    struct Synonym {
        static var synonyms: FieldKey { .string("synonyms") }
    }
}

final class SynonymModel: Model, Content {
    static let schema: String = "synonym"

    @ID(custom: .id, generatedBy: .random)
    var id: String?
    
    @Siblings(through: WordSynonyms.self, from: \.$synonym, to: \.$word)
    var words: [WordModel]
}
