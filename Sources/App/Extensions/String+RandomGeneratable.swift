import Foundation
import FluentKit

extension String: RandomGeneratable {
    public static func generateRandom() -> String {
        UUID().uuidString.lowercased()
    }
}
