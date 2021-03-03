//
//  DictionaryDirectivesBuilder.swift
//  Parser
//
//  Created by Anton Tkalikov on 23.05.2020.
//  Copyright © 2020 atkalikov. All rights reserved.
//

import Foundation
import LaoshuCore

final class DictionaryDirectivesBuilder {
    private var name: String?
    private var indexLanguage: String?
    private var contentsLanguage: String?

    func build() -> DictionaryDirectives? {
        guard let name = name,
            let indexLanguage = indexLanguage,
            let contentsLanguage = contentsLanguage else { return nil }
        return DictionaryDirectives(name: name, indexLanguage: indexLanguage, contentsLanguage: contentsLanguage)
    }

    func set(name: String) {
        self.name = name
    }

    func set(indexLanguage: String) {
        self.indexLanguage = indexLanguage
    }

    func set(contentsLanguage: String) {
        self.contentsLanguage = contentsLanguage
    }

    func erase() {
        self.name = nil
        self.indexLanguage = nil
        self.contentsLanguage = nil
    }
}
