import UIKit

class AvatarDetailViewController: BaseViewController {
    private let avatar: AIAvatar
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.bounces = true
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let professionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let personalityTagsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let personalityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.text = "性格特征"
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let backstoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ageGenderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private var headerImageHeightConstraint: NSLayoutConstraint?
    private let headerImageHeight: CGFloat = UIScreen.main.bounds.width // 默认高度为屏幕宽度
    
    // 添加自定义导航视图属性
    private let customNavigationView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .white
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 添加底部视图属性
    private let bottomSpaceView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 添加 tagsContainerView 属性
    private let tagsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 添加私信按钮属性
    private let messageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("开始聊天", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        button.backgroundColor = UIColor(hex: "9F5CCB")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(avatar: AIAvatar) {
        self.avatar = avatar
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 隐藏系统导航条
        self.hideNavigationBar = true
        
        setupUI()
        configureUI()
        setupScrollViewDelegate()
    }
    
    internal override func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 配置 scrollView
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.alwaysBounceVertical = true
        
        // 先添加滚动视图及其内容
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(professionLabel)
        contentView.addSubview(infoStackView)
        contentView.addSubview(messageButton)
        contentView.addSubview(bottomSpaceView)
        
        // 设置 infoStackView 的内容
        infoStackView.addArrangedSubview(ageGenderLabel)
        infoStackView.addArrangedSubview(personalityTagsView)
        infoStackView.addArrangedSubview(backstoryLabel)
        
        personalityTagsView.addSubview(personalityLabel)
        personalityTagsView.addSubview(tagsContainerView)
        
        // 设置所有约束
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -20),
            backgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            professionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            professionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            professionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            infoStackView.topAnchor.constraint(equalTo: professionLabel.bottomAnchor, constant: 20),
            infoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            personalityLabel.topAnchor.constraint(equalTo: personalityTagsView.topAnchor),
            personalityLabel.leadingAnchor.constraint(equalTo: personalityTagsView.leadingAnchor),
            
            tagsContainerView.topAnchor.constraint(equalTo: personalityLabel.bottomAnchor, constant: 12),
            tagsContainerView.leadingAnchor.constraint(equalTo: personalityTagsView.leadingAnchor),
            tagsContainerView.trailingAnchor.constraint(equalTo: personalityTagsView.trailingAnchor),
            tagsContainerView.bottomAnchor.constraint(equalTo: personalityTagsView.bottomAnchor),
            
            // 私信按钮约束
            messageButton.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 32),
            messageButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            messageButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 64),
            messageButton.heightAnchor.constraint(equalToConstant: 50),
            
            // 底部空间约束
            bottomSpaceView.topAnchor.constraint(equalTo: messageButton.bottomAnchor, constant: 20),
            bottomSpaceView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomSpaceView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomSpaceView.heightAnchor.constraint(equalToConstant: 100),
            bottomSpaceView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // 修改这里：确保 contentView 的底部与 bottomSpaceView 的底部对齐
            contentView.bottomAnchor.constraint(equalTo: bottomSpaceView.bottomAnchor)
        ])
        
        headerImageHeightConstraint = backgroundImageView.heightAnchor.constraint(equalToConstant: headerImageHeight)
        headerImageHeightConstraint?.isActive = true
        
        // 最后添加导航视图
        setupCustomNavigationView()
        
        // 添加按钮点击事件
        messageButton.addTarget(self, action: #selector(messageButtonTapped), for: .touchUpInside)
        
        // 添加按钮触摸效果
        messageButton.addTarget(self, action: #selector(messageButtonTouchDown), for: .touchDown)
        messageButton.addTarget(self, action: #selector(messageButtonTouchUpOutside), for: .touchUpOutside)
        messageButton.addTarget(self, action: #selector(messageButtonTouchUpOutside), for: .touchCancel)
    }
    
    private func configureUI() {
        titleLabel.text = avatar.name
        
        backgroundImageView.image = UIImage(named: avatar.backgroundImageName) ?? UIImage(named: "default_ai_header")
        nameLabel.text = avatar.name
        professionLabel.text = avatar.profession
        ageGenderLabel.text = "\(avatar.age)岁 · \(avatar.gender.localizedString)"
        
        // 清除现有的标签
        tagsContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        // 设置标签布局
        let maxWidth = UIScreen.main.bounds.width - 40 // 考虑左右边距
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        let horizontalSpacing: CGFloat = 10
        let verticalSpacing: CGFloat = 10
        var rowHeight: CGFloat = 0
        
        // 创并布局标签
        avatar.personalities.forEach { personality in
            let tagView = createTagView(with: personality)
            tagsContainerView.addSubview(tagView)
            
            // 计算标签大小
            let label = tagView.subviews.first as? UILabel
            let labelSize = label?.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude)) ?? .zero
            let tagSize = CGSize(
                width: labelSize.width + 24, // 左右各12点内边距
                height: labelSize.height + 16 // 上下各8点内边距
            )
            
            // 检查是否需要换行
            if currentX > 0 && (currentX + tagSize.width) > maxWidth {
                currentX = 0
                currentY += rowHeight + verticalSpacing
                rowHeight = 0
            }
            
            // 设置标签位置
            tagView.frame = CGRect(
                x: currentX,
                y: currentY,
                width: tagSize.width,
                height: tagSize.height
            )
            
            // 更新位置追踪
            currentX += tagSize.width + horizontalSpacing
            rowHeight = max(rowHeight, tagSize.height)
        }
        
        // 更新容器视图高度
        let containerHeight = currentY + rowHeight
        tagsContainerView.heightAnchor.constraint(equalToConstant: containerHeight).isActive = true
        
        // 格式化背景故事文本
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.paragraphSpacing = 10
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let attributedString = NSMutableAttributedString(
            string: "背景故事：\n\(avatar.backstory)",
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.label
            ]
        )
        
        // 设置"背景故事："的字体为粗体
        attributedString.addAttributes(
            [.font: UIFont.systemFont(ofSize: 18, weight: .medium)],
            range: NSRange(location: 0, length: 5)
        )
        
        backstoryLabel.attributedText = attributedString
        
        // 调整 infoStackView 的间距
        infoStackView.setCustomSpacing(24, after: ageGenderLabel)
        infoStackView.setCustomSpacing(24, after: personalityTagsView)
        
        // 确保所有子视图都设置了正确的间距
        infoStackView.arrangedSubviews.forEach { view in
            view.setContentHuggingPriority(.required, for: .vertical)
            view.setContentCompressionResistancePriority(.required, for: .vertical)
        }
    }
    
    private func createTagView(with text: String) -> UIView {
        let container = UIView()
        container.layer.cornerRadius = 12
        
        // 生成柔和的随机背景色
        let hue = CGFloat.random(in: 0...1)
        let pastelColor = UIColor(hue: hue,
                                saturation: 0.1,
                                brightness: 0.95,
                                alpha: 1.0)
        container.backgroundColor = pastelColor
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray6
        
        container.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12)
        ])
        
        return container
    }
    
    private func setupScrollViewDelegate() {
        scrollView.delegate = self
    }
    
    // 改导航栏高度计算属性
    private var navigationBarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            let topPadding = window?.safeAreaInsets.top ?? 0
            return topPadding + 44 // 44 是标准导航栏高度
        } else {
            return UIApplication.shared.statusBarFrame.height + 44
        }
    }
    
    // 修改 setupCustomNavigationView 方法中的约束
    private func setupCustomNavigationView() {
        view.addSubview(customNavigationView)
        customNavigationView.addSubview(backButton)
        customNavigationView.addSubview(titleLabel)
        
        let window = UIApplication.shared.windows.first
        let topPadding = window?.safeAreaInsets.top ?? 0
        
        NSLayoutConstraint.activate([
            customNavigationView.topAnchor.constraint(equalTo: view.topAnchor),
            customNavigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavigationView.heightAnchor.constraint(equalToConstant: navigationBarHeight),
            
            backButton.leadingAnchor.constraint(equalTo: customNavigationView.leadingAnchor, constant: 16),
            // 调整返回按钮位置，考虑状态栏高度
            backButton.topAnchor.constraint(equalTo: customNavigationView.topAnchor, constant: topPadding),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.centerXAnchor.constraint(equalTo: customNavigationView.centerXAnchor),
            // 调整标题位置，与返回按钮对齐
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor)
        ])
        
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
    }

    @objc private func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    // 在 viewDidLayoutSubviews 中更新渐变层的frame
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 确保内容大小正确
        let contentHeight = bottomSpaceView.frame.maxY
        let minContentHeight = scrollView.bounds.height
        scrollView.contentSize = CGSize(
            width: scrollView.bounds.width,
            height: max(contentHeight, minContentHeight)
        )
    }
    
    // 修改 messageButtonTapped 方法
    @objc private func messageButtonTapped() {
        // 添加按钮点击反馈动画
        UIView.animate(withDuration: 0.15, animations: {
            self.messageButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.messageButton.transform = .identity
            } completion: { _ in
                // 处理点击事件
                self.showChatViewController()
            }
        }
    }

    // 添加跳转到聊天页面的方法
    private func showChatViewController() {        
         let chatVC = MessageDetailViewController(avatar: avatar)
         navigationController?.pushViewController(chatVC, animated: true)
    }

    // 添加按钮触摸反馈方法
    @objc private func messageButtonTouchDown() {
        UIView.animate(withDuration: 0.1) {
            self.messageButton.alpha = 0.9
        }
    }

    @objc private func messageButtonTouchUpOutside() {
        UIView.animate(withDuration: 0.1) {
            self.messageButton.alpha = 1.0
            self.messageButton.transform = .identity
        }
    }
}

extension AvatarDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        
        // 下拉放大效果
        if offsetY < 0 {
            let scale = 1 + abs(offsetY) / headerImageHeight
            backgroundImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
            // 调整位置以保持顶部对齐，并添加一个初始偏移
            let newHeight = headerImageHeight * scale
            let deltaY = (newHeight - headerImageHeight) / 2
            let initialOffset: CGFloat = -20 // 添加一个初始偏移量
            backgroundImageView.frame.origin.y = offsetY + deltaY + initialOffset
        } else {
            // 重置变换，但保持初始偏移
            backgroundImageView.transform = .identity
            backgroundImageView.frame.origin.y = -20 // 保持初始偏移
        }
        
        // 导航栏动画
        let maxOffset: CGFloat = 100
        let alpha = min(max(offsetY / maxOffset, 0), 1)
        
        customNavigationView.backgroundColor = .systemBackground.withAlphaComponent(alpha)
        titleLabel.alpha = alpha
        
        if alpha > 0.5 {
            backButton.tintColor = .label
            titleLabel.textColor = .label
        } else {
            backButton.tintColor = .white
            titleLabel.textColor = .white
        }
    }
}
