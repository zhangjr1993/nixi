import UIKit

class TopicDetailViewController: BaseViewController {
    private let topicText: String
    var listArray: [AIAvatar] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.register(AIAvatarCell.self, forCellWithReuseIdentifier: AIAvatarCell.identifier)
        collectionView.register(TopicHeaderView.self,
                              forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                              withReuseIdentifier: TopicHeaderView.reuseIdentifier)
        
        return collectionView
    }()
    
    init(topicText: String) {
        let text = topicText.replacingOccurrences(of: "#", with: "")
        self.topicText = text + "圈子"
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = topicText
        setupUI()
        loadData()
        setupNavigationBar()
        
        // 确保侧滑返回手势可用
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        // 隐藏 tabBar
        hidesBottomBarWhenPushed = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 确保 tabBar 被隐藏
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 显示 tabBar
        tabBarController?.tabBar.isHidden = false
    }
    
    internal override func setupUI() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadData() {
        // 如果没有匹配到任何角色，可以添加一些默认数据
        if listArray.isEmpty {
            // 可以添加一些默认的 AI 角色或保持空数组
        }
        collectionView.reloadData()
    }
    
    private func setupNavigationBar() {
        // 创建自定义返回按钮
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), 
                                       style: .plain, 
                                       target: self, 
                                       action: #selector(backButtonAction))
        backButton.tintColor = .white
        navigationItem.leftBarButtonItem = backButton
        
        // 移除返回按钮标题
        navigationItem.backButtonTitle = ""
    }
    
    @objc private func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension TopicDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AIAvatarCell.identifier,
                                                    for: indexPath) as! AIAvatarCell
        cell.configure(with: listArray[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                       withReuseIdentifier: TopicHeaderView.reuseIdentifier,
                                                                       for: indexPath) as! TopicHeaderView
            header.configure(topic: topicText,
                           participants: listArray.count,
                           description: "在这里探讨关于\(topicText)的话题，与AI角色进行互动交流。")
            return header
        }
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TopicDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 8 * 3 // 左边距 + 右边距 + 中间间距
        let availableWidth = collectionView.bounds.width - padding
        let itemWidth = availableWidth / 2
        
        // 固定高度：头像(正方形) + 名字(24) + 职业(20) + 间距(12)
        let itemHeight = itemWidth + 66
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 150)
    }
}

// 在 UICollectionViewDelegateFlowLayout 扩展中添加点击处理方法
extension TopicDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let avatar = listArray[indexPath.item]
        let detailVC = AvatarDetailViewController(avatar: avatar)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// 添加 UIGestureRecognizerDelegate 扩展
extension TopicDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
