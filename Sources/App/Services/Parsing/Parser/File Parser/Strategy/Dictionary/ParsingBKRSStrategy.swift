import Foundation
import LaoshuCore

final class ParsingBKRSStrategy: ParsingWordStrategy {
    private let builder: WordBuilder
    private let converter: TextConverter

    init(builder: WordBuilder,
         converter: TextConverter) {
        self.builder = builder
        self.converter = converter
    }

    @discardableResult
    func parse(from string: String) -> Word? {
        builder.erase()

        string
            .split(whereSeparator: \.isNewline)
            .enumerated()
            .compactMap { process(string: String($0.element), at: $0.offset) }
            .forEach {
                switch $0.field {
                case .original:
                    builder.set(original: converter.dslToHtml($0.value))
                case .transcription:
                    builder.set(transcription: converter.dslToHtml($0.value))
                case .description:
                    builder.set(description: converter.dslToHtml($0.value))
                }
        }

        if let original = builder.original, let pinyin = builder.transcription,
            (pinyin.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                pinyin == "_" ||
                pinyin == "--" ||
                pinyin == "_ _" ||
                pinyin == "." ||
                pinyin == "-") {
            builder.set(transcription: original.transformToPinyin())
        } else if let original = builder.original, builder.transcription == nil {
            builder.set(transcription: original.transformToPinyin())
        }

        return builder.build()
    }
}


extension ParsingBKRSStrategy {
    private enum Fields: CaseIterable {
        case original
        case transcription
        case description
    }

    private func process(string: String, at line: Int) -> (field: Fields, value: String)? {
        switch line {
        case 0:
            guard !string.hasPrefix(" ") else { return nil }
            return (field: .original, value: string)
        case 1:
            guard string.hasPrefix(" ") else { return nil }
            return (field: .transcription, value: string.trimmingCharacters(in: .whitespacesAndNewlines))
        case 2:
            guard string.hasPrefix(" ") else { return nil }
            return (field: .description, value: string.trimmingCharacters(in: .whitespacesAndNewlines))
        default:
            return nil
        }
    }
}
