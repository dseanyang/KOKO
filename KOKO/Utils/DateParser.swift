import Foundation

struct DateParser {

    private static let formatter1: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private static let formatter2: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy/MM/dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    static func parse(_ dateString: String) -> Date? {
        formatter1.date(from: dateString) ?? formatter2.date(from: dateString)
    }

    static func isNewer(_ dateString1: String, than dateString2: String) -> Bool {
        guard let d1 = parse(dateString1), let d2 = parse(dateString2) else { return false }
        return d1 > d2
    }
}
