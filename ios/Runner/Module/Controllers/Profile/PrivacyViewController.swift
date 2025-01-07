import UIKit

class PrivacyViewController: BaseViewController {
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.textColor = .white
        textView.font = .systemFont(ofSize: 16)
        textView.isEditable = false
        textView.showsVerticalScrollIndicator = false
        textView.automaticallyAdjustsScrollIndicatorInsets = false
        textView.contentOffset = .zero
        textView.text = """
隐私政策

更新日期：2024年3月20日

感谢您使用 轻甜！我们非常重视您的隐私保护。本隐私政策旨在向您说明我们如何收集、使用和保护您的个人信息。请您仔细阅读以下内容：

1. 信息收集
我们可能收集以下信息：
• 账户信息：注册时提供的电子邮件地址
• 使用数据：您与AI助手的对话内容
• 设备信息：设备型号、操作系统版本、应用版本等基本信息
• 诊断数据：应用崩溃报告和性能数据

2. 信息使用
我们收集的信息将用于：
• 提供、维护和改进我们的服务
• 个性化您的使用体验
• 发送服务相关通知
• 改进AI模型的回答质量
• 处理您的反馈和请求

3. 信息安全
我们采取多重措施保护您的信息：
• 使用加密技术传输和存储数据
• 定期安全评估和更新
• 严格控制数据访问权限
• 遵守相关法律法规要求

4. 信息共享
我们不会出售您的个人信息。仅在以下情况下可能共享您的信息：
• 经您明确同意
• 法律法规要求
• 保护我们的合法权益

5. 您的权利
您对个人信息享有以下权利：
• 访问、更正您的个人信息
• 删除您的账户和相关数据
• 撤回同意
• 导出您的聊天记录

6. 儿童隐私
我们的服务不面向13岁以下儿童。如果发现误收集了儿童信息，我们将立即删除。

7. Cookie使用
我们使用Cookie改善用户体验，您可以通过浏览器设置控制Cookie。

8. 隐私政策更新
我们可能适时更新本隐私政策，更新后将在应用内通知您。

9. 联系我们
如有任何问题或建议，请通过以下方式联系我们：
邮箱：happym1224@163.com

继续使用我们的服务，即表示您同意本隐私政策的所有条款。
"""
        return textView
    }()
   
    override func setupUI() {
        super.setupUI()
        title = "隐私协议"
        
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.setContentOffset(.zero, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.setContentOffset(.zero, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.textView.setContentOffset(.zero, animated: false)
        }
    }
}
