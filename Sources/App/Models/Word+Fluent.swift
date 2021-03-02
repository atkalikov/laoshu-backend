import Vapor
import Fluent
import LaoshuModels

extension FieldKey {
    struct Word {
        static var original: FieldKey { .string("original") }
        static var transcription: FieldKey { .string("transcription") }
        static var description: FieldKey { .string("description") }
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
