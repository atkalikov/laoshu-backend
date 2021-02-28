import Foundation
import LaoshuModels

public protocol ParsingWordStrategy {
    func parse(from string: String) -> Word?
}
