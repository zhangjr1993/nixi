override func viewDidLoad() {
    super.viewDidLoad()
    setupViewControllers()
    setupDefaultUser()
}

private func setupDefaultUser() {
    // 如果当前没有用户，创建默认用户
    if UserManager.shared.currentUser == nil {
        UserManager.shared.createNewUser(
            uid: "100000",
            nickname: "非凡大师",
            avatar: "default_avatar"
        )
    }
} 