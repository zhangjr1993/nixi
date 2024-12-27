import UIKit

class HomeViewController: BaseViewController {
    private var avatars: [AIAvatar] = []
    private var filteredAvatars: [AIAvatar] = []
    private var isSearching: Bool = false
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "搜索你喜欢的AI"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        
        // 设置搜索栏样式
        if #available(iOS 13.0, *) {
            // searchTextField 是直接属性，不需要可选绑定
            let searchTextField = searchController.searchBar.searchTextField
            // 设置背景色
            searchTextField.backgroundColor = UIColor(red: 36/255, green: 41/255, blue: 63/255, alpha: 1.0)
            // 设置文本颜色
            searchTextField.textColor = .white
            // 设置占位符颜色
            searchTextField.attributedPlaceholder = NSAttributedString(
                string: "搜索你喜欢的AI",
                attributes: [.foregroundColor: UIColor.lightGray]
            )
            // 设置搜索图标颜色
            if let leftView = searchTextField.leftView as? UIImageView {
                leftView.tintColor = .lightGray
            }
        }
        
        // 设置搜索栏背景
        searchController.searchBar.backgroundColor = .clear
        searchController.searchBar.barTintColor = UIColor(red: 36/255, green: 41/255, blue: 63/255, alpha: 1.0)
        
        return searchController
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = WaterfallLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(AIAvatarCell.self, forCellWithReuseIdentifier: AIAvatarCell.identifier)
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AI伙伴"
        setupNavigationBar()
        setupUI()
        showLoadingAndFetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupNavigationBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    internal override func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    internal func showLoadingAndFetchData() {
        ProgressHUD.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.loadAvatars()
        }
    }
    
    private func loadAvatars() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let url = Bundle.main.url(forResource: "AIAvatars", withExtension: "json"),
                  let data = try? Data(contentsOf: url) else {
                print("Error: Cannot find or load AIAvatars.json")
                DispatchQueue.main.async {
                    ProgressHUD.dismiss()
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(AIAvatarResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.avatars = response.avatars.shuffled()
                    self?.collectionView.reloadData()
                    ProgressHUD.dismiss()
                }
            } catch {
                print("Error decoding JSON: \(error)")
                DispatchQueue.main.async {
                    ProgressHUD.dismiss()
                }
            }
        }
    }
    
    private func filterAvatars(with searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredAvatars = avatars
        } else {
            isSearching = true
            filteredAvatars = avatars.filter { avatar in
                avatar.name.localizedCaseInsensitiveContains(searchText) ||
                avatar.profession.localizedCaseInsensitiveContains(searchText) ||
                avatar.personalities.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearching ? filteredAvatars.count : avatars.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AIAvatarCell.identifier, for: indexPath) as? AIAvatarCell else {
            return UICollectionViewCell()
        }
        
        let avatar = isSearching ? filteredAvatars[indexPath.item] : avatars[indexPath.item]
        cell.configure(with: avatar)
        
        // 设置单元格背景色和圆角
        cell.contentView.backgroundColor = UIColor(red: 56/255, green: 60/255, blue: 85/255, alpha: 1)
        cell.contentView.layer.cornerRadius = 8
        cell.contentView.clipsToBounds = true
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let avatar = isSearching ? filteredAvatars[indexPath.item] : avatars[indexPath.item]
        let detailVC = AvatarDetailViewController(avatar: avatar)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 初始状态：缩小并且透明
        cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        cell.alpha = 0
        
        // 弹性动画
        UIView.animate(
            withDuration: 0.5,
            delay: 0.05 * Double(indexPath.row), // 错开动画时间，产生波浪效果
            usingSpringWithDamping: 0.6, // 弹性系数，越小弹性越大
            initialSpringVelocity: 0.5,
            options: [],
            animations: {
                cell.transform = .identity  // 恢复原始大小
                cell.alpha = 1             // 完全显示
            }
        )
    }
}

// MARK: - UISearchResultsUpdating
extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        filterAvatars(with: searchText)
    }
}

// MARK: - UISearchBarDelegate
extension HomeViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        collectionView.reloadData()
    }
}
