import UIKit

// MARK: - 环形进度视图（核心 UI 组件）
class RingProgressView: UIView {

    // MARK: - 属性
    var progress: Double = 0 {
        didSet {
            progress = max(0, min(1, progress))
            setNeedsDisplay()
        }
    }

    var progressColor: UIColor = AppColor.mainTint {
        didSet { setNeedsDisplay() }
    }

    var trackColor: UIColor = AppColor.lineSeparator {
        didSet { setNeedsDisplay() }
    }

    var lineWidth: CGFloat = 12 {
        didSet { setNeedsDisplay() }
    }

    var animationDuration: TimeInterval = 0.3

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }

    // MARK: - 绘制
    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = (min(rect.width, rect.height) / 2) - lineWidth / 2
        let startAngle = -CGFloat.pi / 2  // 从 12 点方向开始
        let endAngle = startAngle + 2 * CGFloat.pi

        // 底部轨道
        let trackPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        trackPath.lineWidth = lineWidth
        trackColor.setStroke()
        trackPath.lineCapStyle = .round
        trackPath.stroke()

        // 进度弧
        guard progress > 0 else { return }
        let progressEndAngle = startAngle + CGFloat(progress) * 2 * CGFloat.pi
        let progressPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: progressEndAngle,
            clockwise: true
        )
        progressPath.lineWidth = lineWidth
        progressColor.setStroke()
        progressPath.lineCapStyle = .round
        progressPath.stroke()

        // 进度点（小圆点）
        if progress > 0.01 {
            let dotCenter = CGPoint(
                x: center.x + radius * cos(progressEndAngle),
                y: center.y + radius * sin(progressEndAngle)
            )
            let dotRadius = lineWidth / 2
            let dotPath = UIBezierPath(
                arcCenter: dotCenter,
                radius: dotRadius,
                startAngle: 0,
                endAngle: 2 * CGFloat.pi,
                clockwise: true
            )
            progressColor.setFill()
            dotPath.fill()
        }
    }

    // MARK: - 动画更新
    func setProgress(_ value: Double, animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: animationDuration) {
                self.progress = value
            }
        } else {
            progress = value
        }
    }
}
