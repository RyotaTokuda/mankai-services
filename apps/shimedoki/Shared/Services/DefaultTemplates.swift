import Foundation

enum DefaultTemplates {
    static func create() -> [Template] {
        [
            Template(
                title: "1on1",
                durationMinutes: 30,
                category: .oneOnOne,
                colorHex: "#00A060"
            ),
            Template(
                title: "商談",
                durationMinutes: 45,
                category: .sales,
                colorHex: "#1A6FD4"
            ),
            Template(
                title: "面接",
                durationMinutes: 60,
                category: .meeting,
                colorHex: "#8A3DC0"
            ),
            Template(
                title: "雑談",
                durationMinutes: 15,
                category: .chat,
                colorHex: "#E8A000"
            ),
            Template(
                title: "集中",
                durationMinutes: 25,
                category: .focus,
                colorHex: "#D94020"
            ),
            Template(
                title: "退出準備",
                durationMinutes: 5,
                category: .meeting,
                alertOffsets: [60],
                colorHex: "#7A7A80"
            ),
        ]
    }
}
