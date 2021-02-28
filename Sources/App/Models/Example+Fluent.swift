import Vapor
import Fluent
import LaoshuModels

final class ExampleModel: Model {
    static let schema: String = "exmaples"

    @ID(custom: "original", generatedBy: .user)
    public var id: String?

    @Field(key: "example")
    public var example: String
    
    @Parent(key: "words_original")
    public var word: WordModel
    
    var original: String {
       return id ?? ""
    }

    init() {
        self.id = ""
        self.example = ""
    }

    init(example: Example) {
        self.id = example.original
        self.example = example.example
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
