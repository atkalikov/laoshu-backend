import Foundation
#if os(Linux)
    import CoreFoundation
    import Glibc
#endif

extension String {
    func isIncludeChinese() -> Bool {
        for ch in self.unicodeScalars {
            if (0x4e00 < ch.value  && ch.value < 0x9fff) { return true }
        }
        return false
    }
    
    func transformToPinyin() -> String{
        let chars = Array(self.utf16)
        let cfStr = CFStringCreateWithCharacters(nil, chars, self.utf16.count)
        let str = CFStringCreateMutableCopy(nil, 0, cfStr)!
        if CFStringTransform(str, nil, kCFStringTransformToLatin, false) {
            if CFStringTransform(str, nil, kCFStringTransformStripDiacritics, false) {
                return String(describing: str)
            }
            return self
        }
        return self
    }
}
