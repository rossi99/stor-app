import Foundation

struct Income: Identifiable {
    let id: UUID
    var memberID: UUID
    var memberName: String
    var grossMonthly: Double
    var netMonthly: Double

    var takeHomePercent: Double { netMonthly / grossMonthly }
}
