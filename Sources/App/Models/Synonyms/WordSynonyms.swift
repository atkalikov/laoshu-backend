import Vapor
import Fluent
import LaoshuCore

extension FieldKey {
    struct WordSynonyms {
        static var wordId: FieldKey { .string("word_id") }
        static var synonymId: FieldKey { .string("synonym_id") }
    }
}

final class WordSynonyms: Model {
    static var schema: String = "word_synonyms"
    
    @ID(custom: .id, generatedBy: .random)
    var id: String?
    
    @Parent(key: FieldKey.WordSynonyms.wordId)
    var word: WordModel
    
    @Parent(key: FieldKey.WordSynonyms.synonymId)
    var synonym: SynonymModel
    
    init() { }
    
    init(word: WordModel, synonym: SynonymModel) {
        self.$word.id = try! word.requireID()
        self.$synonym.id = try! synonym.requireID()
    }
}
