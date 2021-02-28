import Vapor
import Fluent
import LaoshuModels

final class WordModel: Model, Content {
    static let schema: String = "word"

    @ID()
    var id: UUID?
    
    @Field(key: "original")
    public var original: String

    @OptionalField(key: "transcription")
    public var transcription: String?

    @Field(key: "description")
    public var description: String

    init() {
        self.id = UUID()
        self.original = ""
        self.transcription = nil
        self.description = ""
    }

    init(word: Word) {
        self.original = word.original
        self.transcription = word.transcription
        self.description = word.description
    }
}
