import UIKit

class StarryBackgroundView: UIView {
    private var stars: [CAShapeLayer] = []
    private let starCount = 100
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupStars()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupStars() {
        for _ in 0..<starCount {
            let star = CAShapeLayer()
            let size = CGFloat.random(in: 1...3)
            star.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: size, height: size)).cgPath
            star.fillColor = UIColor.white.cgColor
            star.opacity = Float.random(in: 0.2...0.8)
            star.position = CGPoint(
                x: CGFloat.random(in: 0...frame.width),
                y: CGFloat.random(in: 0...frame.height)
            )
            layer.addSublayer(star)
            stars.append(star)
            
            animateStar(star)
        }
    }
    
    private func animateStar(_ star: CAShapeLayer) {
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = star.opacity
        opacityAnimation.toValue = Float.random(in: 0.2...0.8)
        opacityAnimation.duration = Double.random(in: 1.0...3.0)
        opacityAnimation.autoreverses = true
        opacityAnimation.repeatCount = .infinity
        
        star.add(opacityAnimation, forKey: "starOpacity")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        stars.forEach { star in
            star.position = CGPoint(
                x: CGFloat.random(in: 0...frame.width),
                y: CGFloat.random(in: 0...frame.height)
            )
        }
    }
} 