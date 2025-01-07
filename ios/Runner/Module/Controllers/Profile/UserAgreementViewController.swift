import UIKit

class UserAgreementViewController: BaseViewController {
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
                轻甜用户协议

        欢迎使用轻甜！请您仔细阅读以下条款，使用我们的服务即表示您同意接受以下所有条款。

        1. 服务条款
        1.1 轻甜是一款基于人工智能的对话应用，为用户提供AI对话服务。
        1.2 您需要确保您具有完全民事行为能力来使用本服务。
        1.3 我们保留随时修改或中断服务的权利，恕不另行通知。

        2. 用户责任与行为规范
        2.1 您同意不使用本服务从事任何违法或不当的活动。
        2.2 禁止发布、传播或储存任何违法、有害、威胁、滥用、骚扰、诽谤、侮辱、仇恨、淫秽或其他不当内容。
        2.3 禁止进行任何可能损害服务正常运行的行为。
        2.4 您应对使用本账号的所有行为负责。

        3. 隐私保护
        3.1 我们重视您的隐私保护，具体详见隐私政策。
        3.2 我们会采取合理措施保护您的个人信息安全。
        3.3 未经您的同意，我们不会向第三方披露您的个人信息。

        4. 知识产权
        4.1 轻甜及其相关的所有知识产权均归我们所有。
        4.2 用户在使用过程中产生的内容，其知识产权归属将根据具体情况而定。
        4.3 未经授权，禁止对本应用进行复制、修改、传播或用于商业用途。

        5. 免责声明
        5.1 我们不对AI生成的内容的准确性、完整性或实用性做出保证。
        5.2 对于因使用本服务而产生的任何直接或间接损失，我们不承担责任。
        5.3 我们不对服务的中断或终止承担责任。

        6. 协议修改
        6.1 我们保留随时修改本协议的权利。
        6.2 修改后的协议将在应用内公布。
        6.3 继续使用本服务将视为接受修改后的协议。

        7. 终止条款
        7.1 我们保留因用户违反协议而终止服务的权利。
        7.2 用户可以随时终止使用本服务。
        7.3 协议终止后，相关条款仍具有法律效力。

        8. 其他
        8.1 本协议受中华人民共和国法律管辖。
        8.2 如本协议的任何条款无效，不影响其他条款的效力。
        8.3 本协议的最终解释权归轻甜所有。

        最后更新日期：2024年3月
        """
        return textView
    }()
   
    override func setupUI() {
        super.setupUI()
        title = "用户协议"
        
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
