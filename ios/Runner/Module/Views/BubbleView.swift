import UIKit

class BubbleView: UIView {
    enum BubbleType {
        case normal    // 普通气泡（来自topicList）
        case user      // 用户发送的气泡
    }
    
    public let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    var tapHandler: (() -> Void)?
    
    init(text: String, type: BubbleType) {
        super.init(frame: .zero)
        setupView(type: type)
        label.text = text
        
        // 计算文本大小
        let labelSize = text.size(withAttributes: [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ])
        
        // 取文本宽高中的较大值，确保气泡是圆形
        let diameter = max(labelSize.width, labelSize.height) + 40
        
        // 设置为正方形frame以确保是圆形
        frame.size = CGSize(width: diameter, height: diameter)
        
        // 添加点击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleTap() {
        tapHandler?()
    }
    
    private func setupView(type: BubbleType) {
        // 添加背景图片视图
        addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // 设置背景图片
        backgroundImageView.image = UIImage(named: "bubble_me")
        
        // 添加label
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.8),
            label.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, multiplier: 0.8)
        ])
        
        // 初始透明度为0
        alpha = 0
    }
}

private extension UIColor {
    static func random() -> UIColor {
        let colors: [UIColor] = [.systemPink, .systemBlue, .systemGreen, 
                                .systemYellow, .systemPurple, .systemOrange]
        return colors.randomElement() ?? .white
    }
} 
