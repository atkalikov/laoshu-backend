//
//  WordBuilder.swift
//  Parser
//
//  Created by Anton Tkalikov on 23.05.2020.
//  Copyright © 2020 atkalikov. All rights reserved.
//

import Foundation
import LaoshuCore

final class WordBuilder {
    public var original: String?
    public var transcription: String?
    public var description: String?

    func build() -> Word? {
        guard let original = original,
            let description = description else { return nil }
        return Word(original: original.lowercased(), transcription: transcription, description: description)
    }

    func set(original: String) {
        self.original = original
    }

    func set(transcription: String) {
        self.transcription = transcription
    }

    func set(description: String) {
        self.description = description
    }

    func erase() {
        self.original = nil
        self.transcription = nil
        self.description = nil
    }
}
