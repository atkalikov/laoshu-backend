import Foundation
import LaoshuCore

public protocol ParsingWordStrategy {
    func parse(from string: String) -> Word?
}
