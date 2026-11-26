import Foundation

/// Calendar facts about the month containing `date`.
struct MonthCalendar {
    let date: Date

    private static var calendar: Calendar { Calendar(identifier: .gregorian) }

    var day: Int { Self.calendar.component(.day, from: date) }

    var daysInMonth: Int { Self.calendar.range(of: .day, in: .month, for: date)?.count ?? 30 }

    /// Counts today, matching how the hero reads "17 days left".
    var daysLeft: Int { daysInMonth - day + 1 }

    /// Monday-first column of the 1st, 0...6.
    var startOffset: Int {
        let start = Self.calendar.date(from: Self.calendar.dateComponents([.year, .month], from: date)) ?? date
        return (Self.calendar.component(.weekday, from: start) + 5) % 7
    }

    var monthName: String { Self.format(date, "MMMM") }

    var todayLabel: String { Self.format(date, "EEE d MMM") }

    func isSameMonth(_ other: Date) -> Bool { Self.calendar.isDate(other, equalTo: date, toGranularity: .month) }

    func isToday(_ other: Date) -> Bool { Self.calendar.isDate(other, inSameDayAs: date) }

    func startOfToday() -> Date { Self.calendar.startOfDay(for: date) }

    func adding(months: Int) -> Date { Self.calendar.date(byAdding: .month, value: months, to: date) ?? date }

    func adding(days: Int) -> Date { Self.calendar.date(byAdding: .day, value: days, to: date) ?? date }

    /// Noon on `day` of this month, so the date survives any timezone shift on display.
    func date(onDay day: Int) -> Date {
        var parts = Self.calendar.dateComponents([.year, .month], from: date)
        parts.day = day
        parts.hour = 12
        return Self.calendar.date(from: parts) ?? date
    }

    /// "Jan" for 1.
    static func monthAbbreviation(_ month: Int) -> String {
        let symbols = DateFormatter().shortMonthSymbols ?? []
        return symbols.indices.contains(month - 1) ? String(symbols[month - 1].prefix(3)) : "\(month)"
    }

    static func day(of date: Date) -> Int { calendar.component(.day, from: date) }

    static func format(_ date: Date, _ pattern: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = pattern
        return formatter.string(from: date)
    }
}
