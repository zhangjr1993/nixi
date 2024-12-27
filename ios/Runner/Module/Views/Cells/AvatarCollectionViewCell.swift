import UIKit

class AvatarCollectionViewCell: UICollectionViewCell {
    static let identifier = "AvatarCollectionViewCell"
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        label.layer.shadowOpacity = 0.5
        label.layer.shadowRadius = 2
        return label
    }()
    
    private let nameLabelContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.layer.cornerRadius = 4
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = UIColor.init(hex: "24293F")
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabelContainer)
        nameLabelContainer.addSubview(nameLabel)
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabelContainer.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 120),
            avatarImageView.heightAnchor.constraint(equalToConstant: 120),
            
            nameLabelContainer.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor, constant: 8),
            nameLabelContainer.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: -8),
            nameLabelContainer.trailingAnchor.constraint(lessThanOrEqualTo: avatarImageView.trailingAnchor, constant: -8),
            
            nameLabel.topAnchor.constraint(equalTo: nameLabelContainer.topAnchor, constant: 4),
            nameLabel.bottomAnchor.constraint(equalTo: nameLabelContainer.bottomAnchor, constant: -4),
            nameLabel.leadingAnchor.constraint(equalTo: nameLabelContainer.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: nameLabelContainer.trailingAnchor, constant: -8)
        ])
    }
    
    func configure(with avatar: AIAvatar) {
        avatarImageView.image = UIImage(named: avatar.avatarImageName)
        nameLabel.text = avatar.name
    }
} 
