import UIKit

struct HelpItem {
    let title: String
    let detail: String
    var isExpanded: Bool = false
}

class HelpViewController: BaseViewController {
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.backgroundColor = .black
        table.delegate = self
        table.dataSource = self
        table.register(HelpTableViewCell.self, forCellReuseIdentifier: HelpTableViewCell.reuseIdentifier)
        return table
    }()
    
    private var helpItems: [HelpItem] = [
        HelpItem(title: "如何和AI聊天?", detail: "选择一个虚拟角色，进入TA的主页，点击主页的”开始聊天“按钮即可开始对话。"),
        HelpItem(title: "我可以自定义虚拟角色吗？", detail: "目前暂不支持自定义虚拟角色，但我们正在开发这项功能，敬请期待。"),
        HelpItem(title: "隐私安全", detail: "所有聊天数据将本加密保存在本地，不会上传到服务器。")
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
  
    override func setupUI() {
        super.setupUI()
        title = "使用帮助"
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension HelpViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return helpItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HelpTableViewCell.reuseIdentifier, for: indexPath) as? HelpTableViewCell else {
            return UITableViewCell()
        }
        
        let item = helpItems[indexPath.row]
        cell.configure(title: item.title, detail: item.detail, isExpanded: item.isExpanded)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        helpItems[indexPath.row].isExpanded.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
