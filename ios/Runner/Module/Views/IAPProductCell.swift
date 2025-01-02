
class IAPProductCell: UITableViewCell {
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.clear.cgColor
        return view
    }()
    
    private let diamondIconView: UIImageView = {
        let imageView = UIImageView()
        if #available(iOS 13.0, *) {
            imageView.image = UIImage(named: "zuanshi_coin")
        }
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white.withAlphaComponent(0.6)
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemBlue
        return label
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(diamondIconView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(priceLabel)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        diamondIconView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            diamondIconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            diamondIconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            diamondIconView.widthAnchor.constraint(equalToConstant: 32),
            diamondIconView.heightAnchor.constraint(equalToConstant: 32),
            
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: diamondIconView.trailingAnchor, constant: 12),
            
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            priceLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        // 不调用super.setSelected，我们自己处理选中状态
        UIView.animate(withDuration: animated ? 0.2 : 0) {
            if selected {
                self.containerView.layer.borderColor = UIColor.systemBlue.cgColor
                self.containerView.layer.borderWidth = 2
                self.containerView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
            } else {
                self.containerView.layer.borderColor = UIColor.clear.cgColor
                self.containerView.layer.borderWidth = 1
                self.containerView.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
            }
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: animated ? 0.2 : 0) {
            self.containerView.alpha = highlighted ? 0.7 : 1.0
        }
    }
    
    func configure(with product: IAPProduct) {
        nameLabel.text = product.name
        descriptionLabel.text = product.description
        
        // 从商品描述中提取价格
        if let priceString = product.description.components(separatedBy: "元").first {
            priceLabel.text = "¥\(priceString)"
        }
    }
} 
