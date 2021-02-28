//
//  ParsingDictionaryDirectivesStrategy.swift
//  Parser
//
//  Created by Anton Tkalikov on 23.05.2020.
//  Copyright © 2020 atkalikov. All rights reserved.
//

import Foundation
import LaoshuModels

struct ParsingDictionaryDirectivesStrategy {
    private let builder: DictionaryDirectivesBuilder

    init(builder: DictionaryDirectivesBuilder) {
        self.builder = builder
    }

    @discardableResult
    func parse(from string: String) -> DictionaryDirectives? {
        builder.erase()

        string
            .split(whereSeparator: \.isNewline)
            .compactMap { process(string: String($0)) }
            .forEach {
                switch $0.field {
                case .name:
                    builder.set(name: $0.value)
                case .indexLanguage:
                    builder.set(indexLanguage: $0.value)
                case .contentsLanguage:
                    builder.set(contentsLanguage: $0.value)
                }
        }

        return builder.build()
    }
}

extension ParsingDictionaryDirectivesStrategy {
    private enum Fields: CaseIterable {
        case name
        case indexLanguage
        case contentsLanguage

        var key: String {
            switch self {
            case .name: return "#NAME"
            case .indexLanguage: return "#INDEX_LANGUAGE"
            case .contentsLanguage: return "#CONTENTS_LANGUAGE"
            }
        }
    }

    private func process(string: String) -> (field: Fields, value: String)? {
        let range = NSRange(location: 0, length: string.utf16.count)

        for field in Fields.allCases {
            guard let regex = try? NSRegularExpression(pattern: "\(field.key)*") else { continue }
            guard let result = regex.firstMatch(in: string, options: [], range: range) else { continue }
            guard let range = Range(result.range, in: string) else { continue }
            guard let rawValue = String(string[range.upperBound...].utf16) else { continue }
            let value = rawValue
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: .init(charactersIn: "\""))
            return (field: field, value: value)
        }

        return nil
    }
}
