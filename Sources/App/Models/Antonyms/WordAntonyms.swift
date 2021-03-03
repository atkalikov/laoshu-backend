import Vapor
import Fluent
import LaoshuModels

extension FieldKey {
    struct WordAntonyms {
        static var wordId: FieldKey { .string("word_id") }
        static var antonymId: FieldKey { .string("antonym_id") }
    }
}

final class WordAntonyms: Model {
    static var schema: String = "word_antonyms"
    
    @ID(custom: .id, generatedBy: .random)
    var id: String?
    
    @Parent(key: FieldKey.WordAntonyms.wordId)
    var word: WordModel
    
    @Parent(key: FieldKey.WordAntonyms.antonymId)
    var antonym: WordModel
    
    init() { }
    
    init(word: WordModel, antonym: WordModel) {
        self.$word.id = try! word.requireID()
        self.$antonym.id = try! antonym.requireID()
    }
}
