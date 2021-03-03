import Vapor
import Foundation
import Fluent
import LaoshuModels

extension FieldKey {
    struct Word {
        static var original: FieldKey { .string("original") }
        static var transcription: FieldKey { .string("transcription") }
        static var description: FieldKey { .string("description") }
        static var synonymsId: FieldKey { .string("synonymsId") }
    }
}

final class WordModel: Model, Content {
    static let schema: String = "word"

    @ID(custom: .id, generatedBy: .random)
    var id: String?
    
    @Field(key: FieldKey.Word.original)
    var original: String

    @OptionalField(key: FieldKey.Word.transcription)
    var transcription: String?

    @Field(key: FieldKey.Word.description)
    var description: String
    
    @Siblings(through: WordSynonyms.self, from: \.$word, to: \.$synonym)
    var synonyms: [SynonymModel]
    
    @Siblings(through: WordAntonyms.self, from: \.$word, to: \.$antonym)
    var antonyms: [WordModel]

    init() {
        self.original = ""
        self.transcription = nil
        self.description = ""
    }

    init(word: Word) {
        self.original = word.original
        self.transcription = word.transcription
        self.description = word.description
    }
    
    func update(with word: Word) {
        self.transcription = word.transcription
        self.description = word.description
    }
}

extension Word: Content { }

extension WordModel {
    var output: Word {
        .init(
            original: self.original,
            transcription: self.transcription,
            description: self.description,
            antonyms: self.antonyms.map {
                Antonym(content: self.original, opposite: $0.original)
            },
            synonyms: self.synonyms.map { synonym in
                Synonym(content: synonym.words.map { $0.original })
            },
            isFavorite: false
        )
    }
}
