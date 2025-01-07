import UIKit

// MARK: - MenuItem Model
struct MenuItem {
    let title: String
    let icon: String
}

// MARK: - ProfileTableViewCell
private class ProfileTableViewCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.tintColor = .white
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
            imageView.image = UIImage(systemName: "chevron.right", withConfiguration: config)?
                .withTintColor(.white.withAlphaComponent(0.5), renderingMode: .alwaysOriginal)
        }
        return imageView
    }()
    
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .white.withAlphaComponent(0.7)
        label.textAlignment = .right
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(arrowImageView)
        containerView.addSubview(detailLabel)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        iconContainerView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            iconContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            iconContainerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 32),
            iconContainerView.heightAnchor.constraint(equalToConstant: 32),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            arrowImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            arrowImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 12),
            arrowImageView.heightAnchor.constraint(equalToConstant: 20),
            
            detailLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -8),
            detailLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8)
        ])
    }
    
    func configure(with item: MenuItem) {
        titleLabel.text = item.title
        
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
            iconImageView.image = UIImage(systemName: item.icon, withConfiguration: config)?
                .withTintColor(.white, renderingMode: .alwaysOriginal)
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.2) {
            self.containerView.alpha = highlighted ? 0.7 : 1.0
            self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        }
    }
    
    var detailText: String? {
        get { detailLabel.text }
        set { detailLabel.text = newValue }
    }
}

class ProfileViewController: BaseViewController {
    
    // MARK: - Properties
    private let avatarSize: CGFloat = 80
    private let avatarBorderWidth: CGFloat = 2
    private let headerHeight: CGFloat = 200
    
    private let menuItems: [[MenuItem]] = [
        [
            MenuItem(title: "钻石充值", icon: "cart.fill"),
            MenuItem(title: "用户协议", icon: "doc.text.fill"),
            MenuItem(title: "隐私协议", icon: "lock.shield.fill")
        ],
        [
            MenuItem(title: "使用帮助", icon: "questionmark.circle.fill"),
            MenuItem(title: "反馈", icon: "envelope.fill")
        ],
        [
            MenuItem(title: "关于我们", icon: "info.circle.fill"),
            MenuItem(title: "关于app", icon: "app.badge.fill"),
            MenuItem(title: "音乐播放", icon: "music.note")
        ]
    ]
    
    // 添加当前头像属性
    
    // MARK: - UI Components
    private lazy var headerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: headerHeight))
        view.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        // 添加渐变背景
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor(white: 0.15, alpha: 1.0).cgColor,
            UIColor.black.cgColor
        ]
        view.layer.insertSublayer(gradientLayer, at: 0)
        return view
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = avatarSize / 2
        imageView.layer.borderWidth = avatarBorderWidth
        imageView.layer.borderColor = UIColor.white.cgColor
        
        // 添加阴影
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        imageView.layer.shadowRadius = 4
        imageView.layer.shadowOpacity = 0.3
        
        // 使用AI头像
        imageView.image = UIImage(named: "default_avatar")
        return imageView
    }()
    
    private lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "非凡大师"
        return label
    }()
    
    private lazy var membershipLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.isHidden = true // 默认隐藏
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = .black
        table.separatorStyle = .none
        table.contentInsetAdjustmentBehavior = .never
        table.register(ProfileTableViewCell.self, forCellReuseIdentifier: "Cell")
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        return table
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAvatarTapGesture()
        // 添加钻石余额更新通知监听
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleDiamondsUpdate),
                                               name: .UserDiamondsDidUpdate,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        updateMembershipStatus()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - UI Setup
    override func setupUI() {
        super.setupUI()
        
        // 设置headerView
        headerView.addSubview(avatarImageView)
        headerView.addSubview(nicknameLabel)
        headerView.addSubview(membershipLabel)
        
        // 设置tableView
        tableView.tableHeaderView = headerView
        view.addSubview(tableView)
        
        // 设置约束
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        membershipLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // 头像约束 - 调整垂直位置
            avatarImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: avatarSize),
            avatarImageView.heightAnchor.constraint(equalToConstant: avatarSize),
            
            // 昵称约束 - 减小与头像的间距
            nicknameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
            nicknameLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            nicknameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            nicknameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            // 会员标签约束
            membershipLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 8),
            membershipLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            membershipLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            membershipLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            // 表格约束
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Helper Methods
    private func generateRandomNickname() -> String {
        let adjectives = ["快乐的", "可爱的", "聪明的", "活泼的", "善良的"]
        let nouns = ["小猫", "小狗", "小兔", "小鸟", "小熊"]
        let randomAdjective = adjectives.randomElement() ?? ""
        let randomNoun = nouns.randomElement() ?? ""
        return randomAdjective + randomNoun
    }
    
    // 可以添加点击头像查看详情的功能
    private func setupAvatarTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func avatarTapped() {
        // 这里可以添加显示头像详情的逻辑
    }
    
    @objc private func handleDiamondsUpdate() {
        // 刷新包含钻石余额的cell
        tableView.visibleCells.forEach { cell in
            if let profileCell = cell as? ProfileTableViewCell,
               let indexPath = tableView.indexPath(for: cell) {
                let menuItem = menuItems[indexPath.section][indexPath.row]
                if menuItem.title == "钻石充值" {
                    if let diamonds = UserManager.shared.currentUser?.diamonds {
                        profileCell.detailText = "\(diamonds)钻石"
                    }
                }
            }
        }
    }
    
    // 添加更新会员状态的方法
    private func updateMembershipStatus() {
        if let user = UserManager.shared.currentUser, user.isMembershipValid {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            if let expiryDate = user.membershipExpiryDate {
                membershipLabel.text = "会员有效期：\(dateFormatter.string(from: expiryDate))"
                membershipLabel.isHidden = false
            }
        } else {
            membershipLabel.isHidden = true
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ProfileTableViewCell
        let menuItem = menuItems[indexPath.section][indexPath.row]
        cell.configure(with: menuItem)
        
        if menuItem.title == "钻石充值" {
            if let diamonds = UserManager.shared.currentUser?.diamonds {
                cell.detailText = "\(diamonds)钻石"
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let menuItem = menuItems[indexPath.section][indexPath.row]
        let viewController: UIViewController
        
        switch menuItem.title {
        case "钻石充值":
            viewController = IAPViewController()
        case "用户协议":
            viewController = UserAgreementViewController()
        case "隐私协议":
            viewController = PrivacyViewController()
        case "使用帮助":
            viewController = HelpViewController()
        case "反馈":
            viewController = FeedbackViewController()
        case "关于我们":
            viewController = AboutUsViewController()
        case "关于app":
            viewController = AboutAppViewController()
        case "音乐播放":
            viewController = MusicPlayerViewController()
        default:
            return
        }
        
        navigationController?.pushViewController(viewController, animated: true)
    }
} 
