import UIKit

class BackgroundBubbleView: UIView {
    
    private let minBubbleSize: CGFloat = 5
    private let maxBubbleSize: CGFloat = 40
    private let horizontalPadding: CGFloat = 30
    private var isAnimating = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createBubble() {
        // 随机气泡大小
        let bubbleSize = CGFloat.random(in: minBubbleSize...maxBubbleSize)
        
        // 创建图片视图
        let bubble = UIImageView(frame: CGRect(x: 0, y: 0, width: bubbleSize, height: bubbleSize))
        bubble.image = UIImage(named: "bubble_nor")
        bubble.contentMode = .scaleAspectFit
        bubble.alpha = 0.8
        
        // 计算中心区域的范围
        let centerAreaWidth = frame.width * 0.75 // 中心区域宽度为屏幕宽度的50%
        let centerX = frame.width / 2
        let centerY = frame.height * 0.9 // 在屏幕75%的位置
        
        // 在中心区域随机生成起始位置
        let startX = centerX + CGFloat.random(in: -centerAreaWidth/2...centerAreaWidth/2)
        let startY = centerY + CGFloat.random(in: -10...10) // 垂直方向小范围随机
        bubble.center = CGPoint(x: startX, y: startY)
        
        addSubview(bubble)
        
        // 计算结束位置：只向上移动，带有轻微的水平偏移
        let endX = startX + CGFloat.random(in: -30...30) // 轻微的水平偏移
        let endY = startY - CGFloat.random(in: 400...500) // 向上移动的距离
        
        // 计算目标缩放比例
        let targetScale = 60 / bubbleSize
        
        // 创建位置动画
        let path = UIBezierPath()
        path.move(to: CGPoint(x: startX, y: startY))
        
        // 添加波浪形路径点
        let steps = 8
        let stepY = (endY - startY) / CGFloat(steps)
        let waveWidth: CGFloat = 8.0 // 波浪宽度
        
        for i in 1...steps {
            let y = startY + stepY * CGFloat(i)
            let x = startX + sin(CGFloat(i) * .pi) * waveWidth
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        // 创建路径动画
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        pathAnimation.path = path.cgPath
        pathAnimation.duration = 3.5
        pathAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        pathAnimation.fillMode = .forwards
        
        // 创建缩放和透明度动画
        UIView.animate(withDuration: 3.5, delay: 0, options: [.curveEaseOut]) {
            bubble.transform = CGAffineTransform(scaleX: targetScale, y: targetScale)
            bubble.alpha = 0
        } completion: { _ in
            bubble.removeFromSuperview()
        }
        
        // 添加路径动画
        bubble.layer.add(pathAnimation, forKey: "moveAnimation")
    }
    
    func startAnimating() {
        guard !isAnimating else { return }
        isAnimating = true
        
        DispatchQueue.main.async { [weak self] in
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
                guard let self = self, self.isAnimating else {
                    timer.invalidate()
                    return
                }
                self.createBubble()
            }
        }
    }
    
    func stopAnimating() {
        isAnimating = false
    }
} 
