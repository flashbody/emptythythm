import UIKit

// MARK: - 启动页视图控制器
// 纯代码实现，无需 Storyboard，通过 SceneDelegate 调用
final class LaunchViewController: UIViewController {

    // MARK: - UI
    private let backgroundView  = UIView()
    private let glowLayer       = CAGradientLayer()
    private let ringLayer       = CAShapeLayer()
    private let ringGlowLayer   = CAShapeLayer()
    private let leafLayer       = CAShapeLayer()
    private let appNameLabel    = UILabel()
    private let taglineLabel    = UILabel()
    private let dotStack        = UIStackView()

    // MARK: - 系统语言（用于品牌名双语切换）
    private let systemLang: String = {
        String(Locale.preferredLanguages.first?.prefix(2) ?? "en")
    }()

    // MARK: - Colors
    private let brandGreen   = UIColor(red: 0.298, green: 0.788, blue: 0.600, alpha: 1)  // #4CC999
    private let deepGreen    = UIColor(red: 0.082, green: 0.420, blue: 0.290, alpha: 1)  // #155A4A
    private let lightGreen   = UIColor(red: 0.780, green: 0.957, blue: 0.878, alpha: 1)  // #C7F4E0
    private let goldAccent   = UIColor(red: 0.957, green: 0.843, blue: 0.557, alpha: 1)  // #F4D78E
    private let pureWhite    = UIColor.white

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playEntranceAnimation()
    }

    // MARK: - Build UI
    private func buildUI() {
        view.backgroundColor = deepGreen

        // ── 背景渐变 ──────────────────────────────────────────────────────────
        glowLayer.colors = [
            deepGreen.cgColor,
            UIColor(red: 0.118, green: 0.510, blue: 0.361, alpha: 1).cgColor,  // #1E8261
            deepGreen.cgColor,
        ]
        glowLayer.locations = [0, 0.5, 1]
        glowLayer.startPoint = CGPoint(x: 0, y: 0)
        glowLayer.endPoint   = CGPoint(x: 1, y: 1)
        glowLayer.frame = view.bounds
        view.layer.insertSublayer(glowLayer, at: 0)

        // ── 装饰光晕（中心发光效果）──────────────────────────────────────────
        let haloLayer = CAGradientLayer()
        haloLayer.type = .radial
        haloLayer.colors = [
            brandGreen.withAlphaComponent(0.25).cgColor,
            UIColor.clear.cgColor,
        ]
        haloLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        haloLayer.endPoint   = CGPoint(x: 1, y: 1)
        let haloSize: CGFloat = 360
        haloLayer.frame = CGRect(
            x: (view.bounds.width - haloSize) / 2,
            y: (view.bounds.height - haloSize) / 2 - 60,
            width: haloSize, height: haloSize
        )
        view.layer.insertSublayer(haloLayer, above: glowLayer)

        // ── 外环（装饰细圈）──────────────────────────────────────────────────
        let outerRingSize: CGFloat = 200
        let outerRingOrigin = CGPoint(
            x: (view.bounds.width - outerRingSize) / 2,
            y: (view.bounds.height - outerRingSize) / 2 - 80
        )
        let outerRingLayer = CAShapeLayer()
        outerRingLayer.path = UIBezierPath(
            ovalIn: CGRect(origin: outerRingOrigin, size: CGSize(width: outerRingSize, height: outerRingSize))
        ).cgPath
        outerRingLayer.fillColor   = UIColor.clear.cgColor
        outerRingLayer.strokeColor = brandGreen.withAlphaComponent(0.20).cgColor
        outerRingLayer.lineWidth   = 1
        view.layer.addSublayer(outerRingLayer)

        // ── 主进度环 ──────────────────────────────────────────────────────────
        let ringSize: CGFloat = 160
        let ringCenter = CGPoint(
            x: view.bounds.width / 2,
            y: view.bounds.height / 2 - 80
        )
        let ringPath = UIBezierPath(
            arcCenter: ringCenter,
            radius: ringSize / 2,
            startAngle: -.pi / 2,
            endAngle: .pi * 1.5,
            clockwise: true
        )

        // 轨道
        let trackLayer = CAShapeLayer()
        trackLayer.path        = ringPath.cgPath
        trackLayer.fillColor   = UIColor.clear.cgColor
        trackLayer.strokeColor = pureWhite.withAlphaComponent(0.10).cgColor
        trackLayer.lineWidth   = 10
        trackLayer.lineCap     = .round
        view.layer.addSublayer(trackLayer)

        // 进度弧（金色渐变）
        ringGlowLayer.path        = ringPath.cgPath
        ringGlowLayer.fillColor   = UIColor.clear.cgColor
        ringGlowLayer.strokeColor = goldAccent.cgColor
        ringGlowLayer.lineWidth   = 10
        ringGlowLayer.lineCap     = .round
        ringGlowLayer.strokeEnd   = 0   // 动画起点
        view.layer.addSublayer(ringGlowLayer)

        // 进度弧光晕
        let ringGlow2 = CAShapeLayer()
        ringGlow2.path        = ringPath.cgPath
        ringGlow2.fillColor   = UIColor.clear.cgColor
        ringGlow2.strokeColor = goldAccent.withAlphaComponent(0.30).cgColor
        ringGlow2.lineWidth   = 18
        ringGlow2.lineCap     = .round
        ringGlow2.strokeEnd   = 0
        view.layer.insertSublayer(ringGlow2, below: ringGlowLayer)

        // ── 中心叶片图标 ──────────────────────────────────────────────────────
        let leafPath = UIBezierPath()
        let cx = ringCenter.x
        let cy = ringCenter.y
        // 叶片主体（贝塞尔曲线）
        leafPath.move(to: CGPoint(x: cx, y: cy - 28))
        leafPath.addCurve(
            to: CGPoint(x: cx, y: cy + 28),
            controlPoint1: CGPoint(x: cx + 28, y: cy - 14),
            controlPoint2: CGPoint(x: cx + 28, y: cy + 14)
        )
        leafPath.addCurve(
            to: CGPoint(x: cx, y: cy - 28),
            controlPoint1: CGPoint(x: cx - 28, y: cy + 14),
            controlPoint2: CGPoint(x: cx - 28, y: cy - 14)
        )
        // 叶脉
        leafPath.move(to: CGPoint(x: cx, y: cy - 28))
        leafPath.addLine(to: CGPoint(x: cx, y: cy + 28))

        leafLayer.path        = leafPath.cgPath
        leafLayer.fillColor   = UIColor.clear.cgColor
        leafLayer.strokeColor = pureWhite.withAlphaComponent(0).cgColor  // 动画淡入
        leafLayer.lineWidth   = 2
        leafLayer.lineCap     = .round
        view.layer.addSublayer(leafLayer)

        // ── 装饰小圆点（环绕）────────────────────────────────────────────────
        for i in 0..<8 {
            let angle = CGFloat(i) * .pi / 4 - .pi / 2
            let dotRadius: CGFloat = 96
            let dotX = ringCenter.x + dotRadius * cos(angle)
            let dotY = ringCenter.y + dotRadius * sin(angle)
            let dot = CALayer()
            let dotSize: CGFloat = i % 2 == 0 ? 5 : 3
            dot.frame = CGRect(x: dotX - dotSize/2, y: dotY - dotSize/2, width: dotSize, height: dotSize)
            dot.cornerRadius = dotSize / 2
            dot.backgroundColor = (i % 2 == 0 ? goldAccent : lightGreen).withAlphaComponent(0).cgColor
            dot.opacity = 0
            view.layer.addSublayer(dot)
        }

        // ── App 名称（双语品牌标识）────────────────────────────────────────────
        // 中文系统显示「空律」，其他语言显示「EmptyRhythm」
        let appNameText = systemLang == "zh" ? "空律" : "EmptyRhythm"
        appNameLabel.text          = appNameText
        appNameLabel.font          = UIFont.systemFont(ofSize: 42, weight: .thin)
        appNameLabel.textColor     = pureWhite
        appNameLabel.textAlignment = .center
        appNameLabel.alpha         = 0
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(appNameLabel)

        // ── 英文副标题（品牌名，固定英文）────────────────────────────────────
        // 中文系统额外显示英文品牌名，其他语言不重复显示
        let enLabel = UILabel()
        enLabel.text          = systemLang == "zh" ? "EmptyRhythm" : ""
        enLabel.isHidden      = systemLang != "zh"
        enLabel.font          = UIFont.systemFont(ofSize: 14, weight: .light)
        enLabel.textColor     = pureWhite.withAlphaComponent(0.6)
        enLabel.textAlignment = .center
        enLabel.alpha         = 0
        enLabel.translatesAutoresizingMaskIntoConstraints = false
        enLabel.tag = 101
        view.addSubview(enLabel)

        // ── Tagline（多语言）─────────────────────────────────────────────────
        taglineLabel.text          = L("launch.tagline")
        taglineLabel.font          = UIFont.systemFont(ofSize: 13, weight: .ultraLight)
        taglineLabel.textColor     = lightGreen.withAlphaComponent(0.0)
        taglineLabel.textAlignment = .center
        taglineLabel.alpha         = 0
        taglineLabel.letterSpacing = 2
        taglineLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(taglineLabel)

        // ── 底部装饰线 ────────────────────────────────────────────────────────
        let lineView = UIView()
        lineView.backgroundColor = goldAccent.withAlphaComponent(0.4)
        lineView.alpha = 0
        lineView.tag = 102
        lineView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lineView)

        // ── 约束 ──────────────────────────────────────────────────────────────
        NSLayoutConstraint.activate([
            appNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appNameLabel.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 10),

            enLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            enLabel.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 6),

            taglineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            taglineLabel.topAnchor.constraint(equalTo: enLabel.bottomAnchor, constant: 20),

            lineView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lineView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            lineView.widthAnchor.constraint(equalToConstant: 48),
            lineView.heightAnchor.constraint(equalToConstant: 1),
        ])
    }

    // MARK: - 入场动画
    private func playEntranceAnimation() {
        // 1. 进度环绘制（0 → 0.75）
        let ringAnim = CABasicAnimation(keyPath: "strokeEnd")
        ringAnim.fromValue = 0
        ringAnim.toValue   = 0.75
        ringAnim.duration  = 1.2
        ringAnim.timingFunction = CAMediaTimingFunction(name: .easeOut)
        ringAnim.fillMode  = .forwards
        ringAnim.isRemovedOnCompletion = false
        ringGlowLayer.add(ringAnim, forKey: "ring")
        ringGlowLayer.strokeEnd = 0.75

        // 同步光晕环
        if let glow2 = ringGlowLayer.superlayer?.sublayers?.first(where: { $0 !== ringGlowLayer && ($0 as? CAShapeLayer)?.strokeColor == goldAccent.withAlphaComponent(0.30).cgColor }) as? CAShapeLayer {
            glow2.add(ringAnim, forKey: "ring")
            glow2.strokeEnd = 0.75
        }

        // 2. 叶片淡入
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseOut) {
                self.leafLayer.strokeColor = self.pureWhite.withAlphaComponent(0.9).cgColor
            }
            // 叶片绘制动画
            let leafAnim = CABasicAnimation(keyPath: "strokeEnd")
            leafAnim.fromValue = 0
            leafAnim.toValue   = 1
            leafAnim.duration  = 0.8
            leafAnim.timingFunction = CAMediaTimingFunction(name: .easeOut)
            self.leafLayer.strokeEnd = 0
            let leafPath2 = self.leafLayer.path
            self.leafLayer.strokeEnd = 1
            self.leafLayer.add(leafAnim, forKey: "leaf")
        }

        // 3. 文字淡入上浮
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            self.appNameLabel.transform = CGAffineTransform(translationX: 0, y: 16)
            UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseOut) {
                self.appNameLabel.alpha = 1
                self.appNameLabel.transform = .identity
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            if let enLabel = self.view.viewWithTag(101) {
                enLabel.transform = CGAffineTransform(translationX: 0, y: 12)
                UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut) {
                    enLabel.alpha = 1
                    enLabel.transform = .identity
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            self.taglineLabel.transform = CGAffineTransform(translationX: 0, y: 10)
            UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseOut) {
                self.taglineLabel.alpha = 1
                self.taglineLabel.textColor = self.lightGreen.withAlphaComponent(0.8)
                self.taglineLabel.transform = .identity
            }
            if let line = self.view.viewWithTag(102) {
                UIView.animate(withDuration: 0.6, delay: 0.2, options: .curveEaseOut) {
                    line.alpha = 1
                }
            }
        }
    }
}

// MARK: - UILabel 字间距扩展
private extension UILabel {
    var letterSpacing: CGFloat {
        get { 0 }
        set {
            guard let text = text else { return }
            let attr = NSMutableAttributedString(string: text)
            attr.addAttribute(.kern, value: newValue, range: NSRange(location: 0, length: text.count))
            attributedText = attr
        }
    }
}
