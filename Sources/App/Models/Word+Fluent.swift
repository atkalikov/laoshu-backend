import Vapor
import Fluent
import LaoshuModels

final class WordModel: Model {
    static let schema: String = "words"

    @ID(custom: "original", generatedBy: .user)
    public var id: String?

    @OptionalField(key: "transcription")
    public var transcription: String?

    @Field(key: "description")
    public var description: String

    var original: String {
       return id ?? ""
    }

    init() {
        self.id = ""
        self.transcription = nil
        self.description = ""
    }

    init(word: Word) {
        self.id = word.original
        self.transcription = word.transcription
        self.description = word.description
    }
}

//public struct Word {
//    public let original: String
//    public let transcription: String?
//    public let description: String
//    public let antonyms: [Antonym]
//    public let synonyms: [Synonym]
//    public var isFavorite: Bool
//
//    public init(original: String,
//                transcription: String?,
//                description: String,
//                antonyms: [Antonym] = [],
//                synonyms: [Synonym] = [],
//                isFavorite: Bool = false) {
//        self.original = original
//        if transcription == "_" {
//            self.transcription = nil
//        } else {
//            self.transcription = transcription
//        }
//        self.description = description
//        self.isFavorite = isFavorite
//        self.antonyms = antonyms
//        self.synonyms = synonyms
//    }
//}
//
//extension Word: Hashable, Equatable {
//    public static func == (lhs: Self, rhs: Self) -> Bool {
//        return lhs.original == rhs.original
//    }
//}
