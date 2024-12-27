import UIKit

class SquareViewController: BaseViewController {
    
    var topicList: [String] = ["#养鱼", "#万圣节", "#双11", "#音乐", "#美食", "#旅游", "#宠物", "#历史"]
    
    var sendList: [String] = []
    
    private var activeBubbles: [BubbleView] = []
    private var currentTopicIndex = 0
    private let maxBubbles = 6
    
    // 用于记录已占用的区域
    private var occupiedAreas: [CGRect] = []
    
    private var backgroundBubbleView: BackgroundBubbleView!
    
    // 添加背景图片视图属性
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "square_bg"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // 添加自定义标题视图
    private lazy var titleView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "圈子"
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    // 添加新的属性
    private lazy var leftModuleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        
        let label = UILabel()
        label.text = "#AI社区公约"
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .center
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(leftModuleTapped))
        view.addGestureRecognizer(tap)
        
        return view
    }()
    
    private lazy var rightModuleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        
        let label = UILabel()
        label.textColor = .white
        label.text = "#广场"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .center
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(rightModuleTapped))
        view.addGestureRecognizer(tap)
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 移除原来的 title 设置        
        setupUI()
        
        // 延迟一小段时间等待视图布局完成后显示初始气泡
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.createInitialBubbles()
            
            Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] _ in
                self?.createBubbleIfNeeded()
            }
        }
    }
    
    // 确保在视图将要出现时设置导航条样式
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // 确保在视图将要消失时恢复导航条样式（可选）
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    internal override func setupUI() {
        super.setupUI()
        
        // 1. 添加背景图片视图（放在最底层）
        view.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 2. 添加背景气泡视图
        backgroundBubbleView = BackgroundBubbleView(frame: view.bounds)
        view.addSubview(backgroundBubbleView)
        view.sendSubviewToBack(backgroundBubbleView)
        
        // 3. 将背景图片视图移到最底层
        view.sendSubviewToBack(backgroundImageView)
        
        // 4. 添加标题视图
        view.addSubview(titleView)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: view.topAnchor),
            titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleView.heightAnchor.constraint(equalToConstant: UIApplication.shared.statusBarFrame.height + 44),
            
            titleLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -12)
        ])
        
        // 添加左右模块视图
        view.addSubview(leftModuleView)
        view.addSubview(rightModuleView)
        
        leftModuleView.translatesAutoresizingMaskIntoConstraints = false
        rightModuleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // 左模块约束
            leftModuleView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 16),
            leftModuleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            leftModuleView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5, constant: -24),
            leftModuleView.heightAnchor.constraint(equalToConstant: 50),
            
            // 右模块约束
            rightModuleView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 16),
            rightModuleView.leadingAnchor.constraint(equalTo: leftModuleView.trailingAnchor, constant: 16),
            rightModuleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            rightModuleView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // 5. 启动背景动画
        backgroundBubbleView.startAnimating()
    }
    
    private func createBubbleIfNeeded() {
        guard activeBubbles.count < maxBubbles else { return }
        
        let bubble = BubbleView(text: topicList[currentTopicIndex], type: .normal)
        currentTopicIndex = (currentTopicIndex + 1) % topicList.count
        
        if let position = findAvailablePosition(for: bubble.bounds.size) {
            bubble.frame = CGRect(origin: position, size: bubble.bounds.size)
            
            bubble.tapHandler = { [weak self] in
                self?.handleBubbleTap(text: bubble.label.text ?? "")
            }
            
            view.addSubview(bubble)
            activeBubbles.append(bubble)
            
            let occupiedArea = bubble.frame.insetBy(dx: -20, dy: -20)
            occupiedAreas.append(occupiedArea)
            
            animateBubble(bubble)
        }
    }
    
    private func findAvailablePosition(for size: CGSize) -> CGPoint? {
        let padding: CGFloat = 80
        let maxAttempts = 50
        
        // 计算可显示区域的高度（屏幕高度的2/3）
        let availableHeight = (view.bounds.height * 2/3) - padding
        
        for _ in 0..<maxAttempts {
            let randomX = CGFloat.random(in: padding...(view.bounds.width - size.width - padding))
            // 修改Y轴的随机范围，只在顶部2/3区域
            let randomY = CGFloat.random(in: (padding + view.safeAreaInsets.top)...availableHeight)
            
            let proposedFrame = CGRect(x: randomX, y: randomY, width: size.width, height: size.height)
            let expandedFrame = proposedFrame.insetBy(dx: -20, dy: -20) // 检查时增加间距
            
            // 检查是否与现有气泡重叠
            if !occupiedAreas.contains(where: { $0.intersects(expandedFrame) }) {
                return CGPoint(x: randomX, y: randomY)
            }
        }
        
        return nil
    }
    
    private func animateBubble(_ bubble: BubbleView) {
        // 生成随机显示时长（6-8秒）
        let displayDuration = Double.random(in: 6...8)
        
        // 淡入动画
        UIView.animate(withDuration: 0.5, animations: {
            bubble.alpha = 1
        }) { _ in
            self.addShakeAnimation(to: bubble)
            
            // 使用随机时长延迟淡出
            DispatchQueue.main.asyncAfter(deadline: .now() + displayDuration) {
                self.fadeOutBubble(bubble)
            }
        }
    }
    
    private func addShakeAnimation(to bubble: BubbleView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 2.0
        animation.values = [-3.0, 3.0, -3.0]
        animation.repeatCount = .infinity
        animation.autoreverses = true
        bubble.layer.add(animation, forKey: "shake")
    }
    
    private func fadeOutBubble(_ bubble: BubbleView) {
        // 移除抖动动画
        bubble.layer.removeAnimation(forKey: "shake")
        
        // 淡出动画
        UIView.animate(withDuration: 1.0, animations: {
            bubble.alpha = 0
        }) { _ in
            // 移除气泡和占用区域
            if let index = self.activeBubbles.firstIndex(of: bubble) {
                self.activeBubbles.remove(at: index)
                self.occupiedAreas.remove(at: index)
            }
            bubble.removeFromSuperview()
            
            // 如果气泡数量小于3，创建新气泡
            if self.activeBubbles.count < 3 {
                self.createBubbleIfNeeded()
            }
        }
    }
    
    // 新增方法：创建初始气泡
    private func createInitialBubbles() {
        // 第一个气泡立即显示
        createBubbleIfNeeded()
        
        // 0.3秒后显示第二个气泡
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.createBubbleIfNeeded()
        }
        
        // 0.6秒后显示第三个气泡
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.createBubbleIfNeeded()
        }
    }
    
    private func handleBubbleTap(text: String) {
        // 移除 "#" 符号以便进行匹配
        let searchText = text.replacingOccurrences(of: "#", with: "")
        
        // 获取匹配的 AI 角色
        let matchedAvatars = findMatchingAvatars(for: searchText)
        
        let detailVC = TopicDetailViewController(topicText: text)
        detailVC.listArray = matchedAvatars
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // 添加新方法用于查找匹配的 AI 角色
    private func findMatchingAvatars(for searchText: String) -> [AIAvatar] {
        guard let url = Bundle.main.url(forResource: "AIAvatars", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            // 解码为 AIAvatarsResponse
            let response = try decoder.decode(AIAvatarResponse.self, from: data)
            
            // 使用模糊匹配来过滤角色
            return response.avatars.filter { avatar in
                let profession = avatar.profession.lowercased()
                let backstory = avatar.backstory.lowercased()
                let searchLower = searchText.lowercased()
                
                // 使用 contains 进行简单的模糊匹配
                return profession.contains(searchLower) ||
                       backstory.contains(searchLower) ||
                       matchesSimilarMeaning(searchText: searchLower,
                                           targetText: profession + " " + backstory)
            }
        } catch {
            print("Error decoding AIAvatars.json: \(error)")
            return []
        }
    }
    
    // 添加语义相似度匹配方法
    private func matchesSimilarMeaning(searchText: String, targetText: String) -> Bool {
        // 定义相似词组映射
        let similarWords: [String: Set<String>] = [
            "投资": ["投资", "金融", "理财", "股票", "基金", "证券", "经济", "财务"],
            "万圣节": ["万圣节", "节日", "庆典", "装扮", "服装", "化妆"],
            "双11": ["双11", "购物", "消费", "折扣", "商品", "网购", "节日"],
            "音乐": ["音乐","歌曲", "演奏", "乐器", "唱歌", "艺术"],
            "美食": ["美食", "美味", "料理", "烹饪", "餐饮", "厨师", "食物"],
            "旅游": ["旅游", "旅行", "游玩", "观光", "度假", "景点"],
            "宠物": ["宠物", "动物", "猫", "狗", "饲养", "伴侣动物", "园艺", "毛孩子"],
            "历史": ["历史", "古代", "文化", "传统", "过去", "年代"]
        ]
        
        // 检查搜索词是否有相关的同义词组
        if let similarSet = similarWords[searchText] {
            // 检查目标文本是否包含任何相关词
            return similarSet.contains { targetText.contains($0) }
        }
        
        return false
    }
    
    // 添加点击处理方法
    @objc private func leftModuleTapped() {
        let conventionVC = CommunityConventionViewController()
        navigationController?.pushViewController(conventionVC, animated: true)
    }
    
    @objc private func rightModuleTapped() {
        let squareContentVC = SquareContentViewController()
        navigationController?.pushViewController(squareContentVC, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        backgroundBubbleView.stopAnimating()
    }
} 
