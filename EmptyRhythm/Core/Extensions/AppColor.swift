import UIKit

// MARK: - 全局颜色系统（单一来源）
struct AppColor {

    // MARK: 主色 — 治愈青绿
    static let mainTint = UIColor(hex: "#4CC999")
    static let mainTintDark = UIColor(hex: "#3AB585")

    // MARK: 辅助色
    static let warningOrange = UIColor(hex: "#FF9549")   // 饥饿提醒 / 窗口预警
    static let aiBlue = UIColor(hex: "#5AA8FF")          // AI 专属
    static let disabledGray = UIColor(hex: "#8E8E93")    // 断食中断 / 失效

    // MARK: 语义色
    static let success = mainTint
    static let warning = warningOrange
    static let danger = UIColor(hex: "#FF3B30")
    static let info = aiBlue

    // MARK: 背景色（自动适配深浅模式）
    static let bgPage = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(hex: "#000000")
            : UIColor(hex: "#F8F9FA")
    }

    static let bgCard = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(hex: "#1C1C1E")
            : UIColor(hex: "#FFFFFF")
    }

    static let bgSecondary = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(hex: "#2C2C2E")
            : UIColor(hex: "#F2F2F7")
    }

    // MARK: 文字色
    static let textMain = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(hex: "#F5F5F7")
            : UIColor(hex: "#1D1D1F")
    }

    static let textSub = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(hex: "#86868B")
            : UIColor(hex: "#6E6E73")
    }

    static let textPlaceholder = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(hex: "#48484A")
            : UIColor(hex: "#C7C7CC")
    }

    // MARK: 分割线
    static let lineSeparator = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(hex: "#38383A")
            : UIColor(hex: "#E5E5EA")
    }
}

// MARK: - UIColor Hex 扩展
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
