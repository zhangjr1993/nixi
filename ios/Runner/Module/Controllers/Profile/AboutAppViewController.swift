import UIKit

class AboutAppViewController: BaseViewController {
    private lazy var appIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "AppIcon") // 确保在Assets中添加AppIcon图片
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var appNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .center
        label.text = "AIChatGenie"
        return label
    }()
    
    private lazy var versionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.text = "版本号：1.0.0"
        return label
    }()
    
    override func setupUI() {
        super.setupUI()
        title = "关于App"
        
        view.addSubview(appIconImageView)
        view.addSubview(appNameLabel)
        view.addSubview(versionLabel)
        
        appIconImageView.translatesAutoresizingMaskIntoConstraints = false
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // App图标约束
            appIconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appIconImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            appIconImageView.widthAnchor.constraint(equalToConstant: 100),
            appIconImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // App名称约束
            appNameLabel.topAnchor.constraint(equalTo: appIconImageView.bottomAnchor, constant: 20),
            appNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            appNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // 版本号约束
            versionLabel.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 10),
            versionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            versionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            versionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}

