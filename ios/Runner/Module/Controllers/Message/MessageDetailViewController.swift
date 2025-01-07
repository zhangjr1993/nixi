import UIKit

class MessageDetailViewController: BaseViewController {
    private let avatar: AIAvatar
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let inputTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 15)
        textView.layer.cornerRadius = 20
        textView.backgroundColor = UIColor(red: 121/255, green: 119/255, blue: 134/255, alpha: 1)
        textView.textColor = .white
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("发送", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var inputContainerHeight: CGFloat {
        // 基础高度 + 底部安全区域
        return 60 + view.safeAreaInsets.bottom
    }
    
    private var currentKeyboardHeight: CGFloat = 0
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // 添加点击手势识别器
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        gesture.cancelsTouchesInView = false
        return gesture
    }()
    
    // 添加占位符标签
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "输入消息..."
        label.font = .systemFont(ofSize: 15)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 添加消息数组
    private var messages: [Message] = []
    
    // 在现有属性之后添加遮罩层属性
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 在类的属性部分添加
    private let chatService = ChatGLMService.shared
    
    init(avatar: AIAvatar) {
        self.avatar = avatar
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardObservers()
        setupGestures()
        setupTableView()
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    internal override func setupUI() {
        title = avatar.name
        view.backgroundColor = .systemBackground
        
        // 添加背景图片
        view.addSubview(backgroundImageView)
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 添加遮罩层
        view.addSubview(overlayView)
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: backgroundImageView.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: backgroundImageView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: backgroundImageView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: backgroundImageView.bottomAnchor)
        ])
        
        // 修正 tableView 约束
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // 修改底部约束，确保与 inputContainerView 对齐
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -inputContainerHeight)
        ])
        
        // 添加输入容器，使用 frame
        inputContainerView.translatesAutoresizingMaskIntoConstraints = true
        view.addSubview(inputContainerView)
        
        // 添加输入框和发送按钮
        inputContainerView.addSubview(inputTextView)
        inputContainerView.addSubview(sendButton)
        
        // 设置输入框和发送按钮的约束
        NSLayoutConstraint.activate([
            inputTextView.topAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 8),
            inputTextView.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 16),
            inputTextView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            // 底部约束改为相对于容器顶部的固定距离
            inputTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            
            sendButton.centerYAnchor.constraint(equalTo: inputTextView.centerYAnchor),
            sendButton.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -16),
            sendButton.widthAnchor.constraint(equalToConstant: 60),
            sendButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // 修改占位符标签的约束
        inputTextView.addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.centerYAnchor.constraint(equalTo: inputTextView.centerYAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: inputTextView.leadingAnchor, constant: 16),
        ])
        
        backgroundImageView.image = UIImage(named: avatar.backgroundImageName) ?? UIImage(named: "default_ai_bg")
        
        updateInputContainerFrame()
        setupActions()
    }
    
    private func setupActions() {
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        inputTextView.delegate = self
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(keyboardWillShow),
                                             name: UIResponder.keyboardWillShowNotification,
                                             object: nil)
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(keyboardWillHide),
                                             name: UIResponder.keyboardWillHideNotification,
                                             object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
        
        currentKeyboardHeight = keyboardFrame.height
        
        UIView.animate(withDuration: duration,
                      delay: 0,
                      options: UIView.AnimationOptions(rawValue: curve)) {
            // 更新 inputContainerView 的位置
            self.updateInputContainerFrame(keyboardHeight: self.currentKeyboardHeight)
            
            // 更新 tableView 的内容偏移
            let bottomInset = self.inputContainerHeight + self.currentKeyboardHeight
            self.tableView.contentInset.bottom = bottomInset
            self.tableView.scrollIndicatorInsets.bottom = bottomInset
            
            // 滚动到底部
            if self.tableView.contentSize.height > self.tableView.bounds.height {
                let bottomOffset = CGPoint(x: 0, y: max(0, self.tableView.contentSize.height - self.tableView.bounds.height + bottomInset))
                self.tableView.setContentOffset(bottomOffset, animated: false)
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
        
        currentKeyboardHeight = 0
        
        UIView.animate(withDuration: duration,
                      delay: 0,
                      options: UIView.AnimationOptions(rawValue: curve)) {
            // 重置 inputContainerView 的位置
            self.updateInputContainerFrame(keyboardHeight: 0)
            
            // 重置 tableView 的内容偏移
            self.tableView.contentInset.bottom = self.inputContainerHeight
            self.tableView.scrollIndicatorInsets.bottom = self.inputContainerHeight
        }
    }
    
    @objc private func sendButtonTapped() {
        guard let message = inputTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !message.isEmpty else { return }
        
        // 检查用户状态
        guard let currentUser = UserManager.shared.currentUser else { return }
        
        // 判断是否是会员
        let isVipValid = UserManager.shared.isVIPValid()
        
        // 如果不是会员，则检查钻石余额
        if !isVipValid && currentUser.diamonds <= 0 {
            // 显示充值页面
            let iapVC = IAPViewController()
            let nav = UINavigationController(rootViewController: iapVC)
            present(nav, animated: true)
            return
        }
        
        // 如果不是会员，扣除钻石
        if !isVipValid {
            UserManager.shared.updateDiamonds(currentUser.diamonds - 1)
            // 通知其他页面更新用户余额
            NotificationCenter.default.post(name: .UserDiamondsDidUpdate, object: nil)
        }
        
        // 原有的发送消息逻辑
        let newMessage = Message(content: message, type: .sent)
        messages.append(newMessage)
        
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        
        // 清空输入框
        inputTextView.text = ""
        updateInputTextViewHeight()
        placeholderLabel.isHidden = false
        
        // 调用AI服务获取回复
        Task {
            do {
                let aiResponse = try await chatService.chat(message: message)
                
                await MainActor.run {
                    let replyMessage = Message(content: aiResponse, type: .received)
                    self.messages.append(replyMessage)
                    
                    let replyIndexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    self.tableView.insertRows(at: [replyIndexPath], with: .automatic)
                    self.tableView.scrollToRow(at: replyIndexPath, at: .bottom, animated: true)
                }
            } catch let error as ChatGLMError {
                await MainActor.run {
                    let errorMessage = Message(content: error.errorDescription ?? "未知错误", type: .received)
                    self.messages.append(errorMessage)
                    
                    let errorIndexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    self.tableView.insertRows(at: [errorIndexPath], with: .automatic)
                    self.tableView.scrollToRow(at: errorIndexPath, at: .bottom, animated: true)
                }
                print("ChatGLM错误: \(error.localizedDescription)")
            } catch {
                await MainActor.run {
                    let errorMessage = Message(content: "网络错误，请检查网络连接后重试", type: .received)
                    self.messages.append(errorMessage)
                    
                    let errorIndexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    self.tableView.insertRows(at: [errorIndexPath], with: .automatic)
                    self.tableView.scrollToRow(at: errorIndexPath, at: .bottom, animated: true)
                }
                print("其他错误: \(error)")
            }
        }
    }
    
    private func updateInputTextViewHeight() {
        let size = inputTextView.sizeThatFits(CGSize(width: inputTextView.bounds.width, height: .greatestFiniteMagnitude))
        let newHeight = min(size.height, 120)
        
        inputTextView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = newHeight
            }
        }
    }
    
    private func setupGestures() {
        // 添加点击手势到 tableView
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !inputContainerView.frame.contains(location) {
            view.endEditing(true)
        }
    }
    
    private func calculateInputOffset() -> CGFloat {
        // 移除额外的偏移量计算，只保留基础间距
        return 0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 更新 frame，考虑当前键盘高度
        updateInputContainerFrame(keyboardHeight: currentKeyboardHeight)
        
        // 更新 tableView 的内容偏移
        let bottomInset = inputContainerHeight + currentKeyboardHeight
        tableView.contentInset.bottom = bottomInset
        tableView.scrollIndicatorInsets.bottom = bottomInset
    }
    
    private func updateInputContainerFrame(keyboardHeight: CGFloat = 0, animated: Bool = false) {
        let containerY = view.bounds.height - (inputContainerHeight + (keyboardHeight > 0 ? keyboardHeight - 20 : keyboardHeight))
        let containerFrame = CGRect(
            x: 0,
            y: containerY,
            width: view.bounds.width,
            height: inputContainerHeight
        )
        
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.inputContainerView.frame = containerFrame
            }
        } else {
            inputContainerView.frame = containerFrame
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: ChatMessageCell.reuseIdentifier)
    }
   
}

// MARK: - UITextViewDelegate
extension MessageDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateInputTextViewHeight()
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension MessageDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatMessageCell.reuseIdentifier, for: indexPath) as? ChatMessageCell else {
            return UITableViewCell()
        }
        
        let message = messages[indexPath.row]
        cell.configure(with: message, receivedImg: avatar.avatarImageName)
        return cell
    }
}
