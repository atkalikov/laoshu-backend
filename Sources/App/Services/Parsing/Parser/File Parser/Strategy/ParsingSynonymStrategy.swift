import Foundation
import LaoshuCore

public protocol ParsingSynonymStrategy {
    func parse(from string: String) -> Synonym?
}

struct ParsingSynonymStrategyImpl: ParsingSynonymStrategy {
    private let converter: TextConverter
    
    init(converter: TextConverter) {
        self.converter = converter
    }
    
    @discardableResult
    func parse(from string: String) -> Synonym? {
        let array = string
            .split(whereSeparator: \.isWhitespace)
            .enumerated()
            .filter { $0.offset > 0 }
            .map { converter.dslToHtml(String($0.element)) }
        
        if array.count > 1 {
            return Synonym(content: array)
        } else {
            return nil
        }
    }
}
