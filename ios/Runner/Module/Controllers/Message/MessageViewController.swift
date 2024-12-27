import UIKit

class MessageViewController: BaseViewController {
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 76, bottom: 0, right: 16)
        tableView.rowHeight = 80
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private var avatars: [AIAvatar] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "消息"
        setupUI()
        setupTableView()
        loadData()
    }
    
    internal override func setupUI() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func loadData() {
        guard let url = Bundle.main.url(forResource: "AIAvatars", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Error: Cannot find or load AIAvatars.json")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(AIAvatarResponse.self, from: data)
            self.avatars = response.avatars
            self.tableView.reloadData()
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }
}

// MARK: - UITableViewDataSource
extension MessageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return avatars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.reuseIdentifier, for: indexPath) as? MessageCell else {
            return UITableViewCell()
        }
        
        let avatar = avatars[indexPath.row]
        cell.configure(with: avatar)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MessageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // 初始状态：从下方开始
        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: 0, y: 44) // 使用较小的偏移值使动画更自然
        
        // 执行动画
        UIView.animate(
            withDuration: 0.4,              // 稍微缩短动画时间
            delay: 0.03 * Double(indexPath.row),  // 减小延迟时间使动画更连贯
            usingSpringWithDamping: 0.85,   // 轻微的弹性效果
            initialSpringVelocity: 0.8,
            options: .curveEaseOut,
            animations: {
                cell.alpha = 1
                cell.transform = .identity   // 恢复到原始位置
            }
        )
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let avatar = avatars[indexPath.row]
        let detailVC = MessageDetailViewController(avatar: avatar)
        navigationController?.pushViewController(detailVC, animated: true)
    }
} 
